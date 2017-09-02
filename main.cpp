#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtGlobal>

#ifdef Q_OS_WIN
#include "fileio.h"
#endif

#ifdef Q_OS_ANDROID
#include "androidfile.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

#ifdef Q_OS_WIN
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
#endif

#ifdef Q_OS_ANDROID
    qmlRegisterType<AndroidFile, 1>("AndroidFile", 1, 0, "AndroidFile");
#endif

    QQmlApplicationEngine engine;

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
