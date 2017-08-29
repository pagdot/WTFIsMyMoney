#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QFileSelector>
#include <QDebug>

#include "fileio.h"

#ifdef ANDROID
#include "androidfile.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");

#ifdef ANDROID
    qmlRegisterType<AndroidFile, 1>("AndroidFile", 1, 0, "AndroidFile");
#endif

    QQmlApplicationEngine engine;
    QQmlFileSelector* selector = new QQmlFileSelector(&engine);

    qDebug() << selector->selector()->allSelectors();

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
