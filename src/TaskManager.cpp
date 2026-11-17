#include "TaskManager.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QSaveFile>
#include <QSet>
#include <QStandardPaths>
#include <QTime>
#include <QUuid>

#include <algorithm>

TaskManager::TaskManager(
    QObject *parent,
    const QString &filePath
) : QObject(parent)
{
    m_filePath = filePath.isEmpty()
        ? QStandardPaths::writableLocation(
              QStandardPaths::AppDataLocation
          ) + "/tasks.json"
        : filePath;

    load();
}

void TaskManager::fail(const QString &message)
{
    m_error = message;
    emit errorChanged();
}

void TaskManager::clearError()
{
    m_error.clear();
    emit errorChanged();
}

QString TaskManager::dateLabel() const
{
    return QLocale(QLocale::English).toString(
        m_date,
        "dddd, MMMM d, yyyy"
    );
}

int TaskManager::total() const
{
    int count = 0;

    for (const auto &task : m_tasks) {
        if (task.date == selectedDate()) {
            ++count;
        }
    }

    return count;
}

int TaskManager::completed() const
{
    int count = 0;

    for (const auto &task : m_tasks) {
        if (task.date == selectedDate() && task.done) {
            ++count;
        }
    }

    return count;
}

QVariantList TaskManager::tasks() const
{
    std::vector<Task> visible;

    for (const auto &task : m_tasks) {
        if (task.date != selectedDate()) {
            continue;
        }

        if (m_filter == 1 && task.done) {
            continue;
        }

        if (m_filter == 2 && !task.done) {
            continue;
        }

        const bool matchesTitle =
            task.title.contains(m_search, Qt::CaseInsensitive);

        const bool matchesNotes =
            task.notes.contains(m_search, Qt::CaseInsensitive);

        if (!matchesTitle && !matchesNotes) {
            continue;
        }

        visible.push_back(task);
    }

    std::stable_sort(
        visible.begin(),
        visible.end(),
        [](const Task &a, const Task &b) {
            if (a.done != b.done) {
                return !a.done;
            }

            if (a.time.isEmpty() != b.time.isEmpty()) {
                return !a.time.isEmpty();
            }

            if (a.time != b.time) {
                return a.time < b.time;
            }

            return a.priority > b.priority;
        }
    );

    QVariantList result;

    for (const auto &task : visible) {
        result.append(QVariantMap{
            {"id", task.id},
            {"title", task.title},
            {"notes", task.notes},
            {"date", task.date},
            {"time", task.time},
            {"priority", task.priority},
            {"done", task.done}
        });
    }

    return result;
}

bool TaskManager::saveTask(
    const QString &id,
    const QString &title,
    const QString &notes,
    const QString &date,
    const QString &time,
    int priority
)
{
    const QDate parsedDate =
        QDate::fromString(date, Qt::ISODate);

    const bool invalidDate =
        !parsedDate.isValid()
        || parsedDate.toString(Qt::ISODate) != date;

    const bool invalidTime =
        !time.isEmpty()
        && (
            !QTime::fromString(time, "HH:mm").isValid()
            || time.size() != 5
        );

    if (
        title.trimmed().isEmpty()
        || title.trimmed().size() > 120
        || notes.size() > 2000
        || invalidDate
        || invalidTime
        || priority < 0
        || priority > 2
    ) {
        fail(
            "Enter a title (1–120 characters), a valid date "
            "and time (HH:mm). Notes: up to 2000 characters."
        );

        return false;
    }

    const auto previous = m_tasks;

    if (id.isEmpty()) {
        m_tasks.push_back({
            QUuid::createUuid().toString(
                QUuid::WithoutBraces
            ),
            title.trimmed(),
            notes,
            date,
            time,
            priority,
            false
        });
    } else {
        auto it = std::find_if(
            m_tasks.begin(),
            m_tasks.end(),
            [&](const Task &task) {
                return task.id == id;
            }
        );

        if (it == m_tasks.end()) {
            fail("This task no longer exists.");
            return false;
        }

        it->title = title.trimmed();
        it->notes = notes;
        it->date = date;
        it->time = time;
        it->priority = priority;
    }

    return commit(previous);
}

bool TaskManager::removeTask(const QString &id)
{
    const auto previous = m_tasks;

    for (auto it = m_tasks.begin(); it != m_tasks.end(); ++it) {
        if (it->id == id) {
            m_tasks.erase(it);
            return commit(previous);
        }
    }

    fail("This task no longer exists.");

    return false;
}

bool TaskManager::toggleTask(const QString &id)
{
    const auto previous = m_tasks;

    for (auto &task : m_tasks) {
        if (task.id == id) {
            task.done = !task.done;
            return commit(previous);
        }
    }

    fail("This task no longer exists.");

    return false;
}

bool TaskManager::commit(const std::vector<Task> &previous)
{
    if (!persist()) {
        m_tasks = previous;
        return false;
    }

    clearError();

    emit changed();

    return true;
}

void TaskManager::moveDay(int days)
{
    const QDate next = m_date.addDays(days);

    if (next.isValid()) {
        m_date = next;
        emit changed();
    }
}

void TaskManager::today()
{
    m_date = QDate::currentDate();
    emit changed();
}

void TaskManager::setSearch(const QString &text)
{
    m_search = text.trimmed();
    emit changed();
}

void TaskManager::setFilter(int filter)
{
    m_filter = filter;
    emit changed();
}

bool TaskManager::persist()
{
    if (!m_storageValid) {
        fail(
            "The data file is invalid. Back up and repair "
            "or rename it before restarting: " + m_filePath
        );

        return false;
    }

    QJsonArray array;

    for (const auto &task : m_tasks) {
        array.append(QJsonObject{
            {"id", task.id},
            {"title", task.title},
            {"notes", task.notes},
            {"date", task.date},
            {"time", task.time},
            {"priority", task.priority},
            {"done", task.done}
        });
    }

    const QString directory =
        QFileInfo(m_filePath).absolutePath();

    if (!QDir().mkpath(directory)) {
        fail("Cannot create data directory: " + m_filePath);
        return false;
    }

    // The original file is replaced only after a successful write.
    QSaveFile file(m_filePath);

    const QJsonObject root{
        {"version", 1},
        {"tasks", array}
    };

    const QByteArray bytes =
        QJsonDocument(root).toJson();

    if (
        !file.open(QIODevice::WriteOnly)
        || file.write(bytes) != bytes.size()
        || !file.commit()
    ) {
        fail("Could not save your changes: " + m_filePath);
        return false;
    }

    return true;
}

void TaskManager::load()
{
    QFile file(m_filePath);

    if (!file.exists()) {
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        m_storageValid = false;
        fail("Cannot read data file: " + m_filePath);
        return;
    }

    QJsonParseError parseError;

    const QJsonDocument document =
        QJsonDocument::fromJson(
            file.readAll(),
            &parseError
        );

    auto invalid = [&]() {
        m_tasks.clear();
        m_storageValid = false;

        fail(
            "Data file is invalid; it has been preserved. "
            "Back up and repair or rename it, then restart: "
            + m_filePath
        );
    };

    if (
        parseError.error != QJsonParseError::NoError
        || !document.isObject()
        || document.object().value("version").toInt() != 1
        || !document.object().value("tasks").isArray()
    ) {
        invalid();
        return;
    }

    QSet<QString> ids;

    const QJsonArray array =
        document.object().value("tasks").toArray();

    for (const auto &value : array) {
        const QJsonObject object = value.toObject();

        Task task{
            object["id"].toString(),
            object["title"].toString(),
            object["notes"].toString(),
            object["date"].toString(),
            object["time"].toString(),
            object["priority"].toInt(-1),
            object["done"].toBool()
        };

        const QDate parsedDate =
            QDate::fromString(task.date, Qt::ISODate);

        const bool invalidTime =
            !task.time.isEmpty()
            && (
                task.time.size() != 5
                || !QTime::fromString(
                    task.time,
                    "HH:mm"
                ).isValid()
            );

        if (
            task.id.isEmpty()
            || ids.contains(task.id)
            || task.title.trimmed().isEmpty()
            || task.title.size() > 120
            || task.notes.size() > 2000
            || !parsedDate.isValid()
            || parsedDate.toString(Qt::ISODate) != task.date
            || invalidTime
            || task.priority < 0
            || task.priority > 2
            || !object["priority"].isDouble()
            || object["priority"].toDouble() != task.priority
            || !object["done"].isBool()
            || !object["notes"].isString()
            || !object["time"].isString()
        ) {
            invalid();
            return;
        }

        ids.insert(task.id);
        m_tasks.push_back(task);
    }
}