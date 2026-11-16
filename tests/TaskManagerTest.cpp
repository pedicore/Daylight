#include <QtTest>
#include <QTemporaryDir>
#include <QFile>

#include "TaskManager.h"

class TaskManagerTest : public QObject
{
    Q_OBJECT

private slots:
    void lifecycle()
    {
        QTemporaryDir directory;

        const QString path =
            directory.filePath("tasks.json");

        TaskManager manager(nullptr, path);

        const QString day = manager.selectedDate();

        QVERIFY(manager.saveTask(
            "",
            "Read C++",
            "Chapter 2",
            day,
            "09:30",
            2
        ));

        QCOMPARE(manager.total(), 1);

        const QString id =
            manager.tasks()[0].toMap()["id"].toString();

        QVERIFY(manager.toggleTask(id));
        QCOMPARE(manager.completed(), 1);

        QVERIFY(manager.saveTask(
            id,
            "Practice C++",
            "Exercises",
            day,
            "10:30",
            1
        ));

        TaskManager reloaded(nullptr, path);

        QCOMPARE(
            reloaded.tasks()[0].toMap()["title"].toString(),
            QString("Practice C++")
        );

        QCOMPARE(reloaded.completed(), 1);

        QVERIFY(reloaded.removeTask(id));

        TaskManager empty(nullptr, path);

        QCOMPARE(empty.total(), 0);
    }

    void validationAndFilters()
    {
        QTemporaryDir directory;

        TaskManager manager(
            nullptr,
            directory.filePath("tasks.json")
        );

        const QString day = manager.selectedDate();

        QVERIFY(!manager.saveTask(
            "", "  ", "", day, "", 1
        ));

        QVERIFY(!manager.saveTask(
            "", "Task", "", "bad", "", 1
        ));

        QVERIFY(!manager.saveTask(
            "", "Task", "", day, "25:00", 1
        ));

        QVERIFY(!manager.saveTask(
            "missing", "Task", "", day, "", 1
        ));

        QVERIFY(manager.saveTask(
            "", "Read", "C++ book", day, "", 1
        ));

        const QString id =
            manager.tasks()[0].toMap()["id"].toString();

        QVERIFY(manager.saveTask(
            "", "Walk", "", day, "08:00", 0
        ));

        QCOMPARE(
            manager.tasks()[0].toMap()["title"].toString(),
            QString("Walk")
        );

        manager.setSearch("c++");

        QCOMPARE(manager.tasks().size(), 1);

        manager.setSearch("");

        QVERIFY(manager.toggleTask(id));

        manager.setFilter(1);

        QCOMPARE(manager.tasks().size(), 1);
        QCOMPARE(manager.total(), 2);
        QCOMPARE(manager.completed(), 1);

        manager.setFilter(2);

        QCOMPARE(manager.tasks().size(), 1);

        manager.moveDay(1);

        QCOMPARE(manager.total(), 0);

        manager.moveDay(-1);

        QCOMPARE(manager.total(), 2);
    }

    void protectsBadFile()
    {
        QTemporaryDir directory;

        const QString path =
            directory.filePath("tasks.json");

        QFile file(path);

        QVERIFY(file.open(QIODevice::WriteOnly));

        file.write("broken");
        file.close();

        TaskManager manager(nullptr, path);

        QVERIFY(!manager.error().isEmpty());

        QVERIFY(!manager.saveTask(
            "",
            "Task",
            "",
            manager.selectedDate(),
            "",
            1
        ));

        QCOMPARE(manager.total(), 0);

        QVERIFY(file.open(QIODevice::ReadOnly));

        QCOMPARE(
            file.readAll(),
            QByteArray("broken")
        );
    }

    void failedWriteRollsBack()
    {
        QTemporaryDir directory;

        QFile blocker(
            directory.filePath("blocker")
        );

        QVERIFY(blocker.open(QIODevice::WriteOnly));
        blocker.close();

        TaskManager manager(
            nullptr,
            directory.filePath("blocker/tasks.json")
        );

        QVERIFY(!manager.saveTask(
            "",
            "Task",
            "",
            manager.selectedDate(),
            "",
            1
        ));

        QCOMPARE(manager.total(), 0);

        QVERIFY(!manager.error().isEmpty());
    }
};

QTEST_GUILESS_MAIN(TaskManagerTest)

#include "TaskManagerTest.moc"