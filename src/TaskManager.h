#pragma once

#include <QObject>
#include <QDate>
#include <QVariantList>

#include <vector>

// Plain task data, independent of the visual interface.
struct Task
{
    QString id;
    QString title;
    QString notes;
    QString date;
    QString time;

    // 0: low, 1: medium, 2: high
    int priority = 1;

    bool done = false;
};

class TaskManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList tasks READ tasks NOTIFY changed)
    Q_PROPERTY(QString selectedDate READ selectedDate NOTIFY changed)
    Q_PROPERTY(QString dateLabel READ dateLabel NOTIFY changed)
    Q_PROPERTY(int total READ total NOTIFY changed)
    Q_PROPERTY(int completed READ completed NOTIFY changed)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit TaskManager(
        QObject *parent = nullptr,
        const QString &filePath = {}
    );

    QVariantList tasks() const;

    QString selectedDate() const
    {
        return m_date.toString(Qt::ISODate);
    }

    QString dateLabel() const;

    int total() const;
    int completed() const;

    QString error() const
    {
        return m_error;
    }

    Q_INVOKABLE bool saveTask(
        const QString &id,
        const QString &title,
        const QString &notes,
        const QString &date,
        const QString &time,
        int priority
    );

    Q_INVOKABLE bool removeTask(const QString &id);
    Q_INVOKABLE bool toggleTask(const QString &id);

    Q_INVOKABLE void moveDay(int days);
    Q_INVOKABLE void today();

    Q_INVOKABLE void setSearch(const QString &text);
    Q_INVOKABLE void setFilter(int filter);
    Q_INVOKABLE void clearError();

signals:
    void changed();
    void errorChanged();

private:
    std::vector<Task> m_tasks;

    QDate m_date = QDate::currentDate();

    QString m_filePath;
    QString m_search;
    QString m_error;

    // 0: all, 1: pending, 2: completed
    int m_filter = 0;

    bool m_storageValid = true;

    void load();
    bool persist();

    bool commit(const std::vector<Task> &previous);

    void fail(const QString &message);
};