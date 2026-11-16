#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "TaskManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Daylight");
    app.setApplicationName("Daylight");

    QQuickStyle::setStyle("Basic");

    TaskManager manager;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "taskManager",
        &manager
    );

    engine.load(QUrl("qrc:/qml/Main.qml"));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}