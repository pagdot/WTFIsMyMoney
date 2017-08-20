#include <QApplication>
#include <QQmlApplicationEngine>
#include <iostream>
#include <QStringList>
#include <QString>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    auto imports = engine.importPathList();
    for (int i = 0; i < imports.length(); i++) {
        std::cout << "   " << imports.at(i).toStdString() << std::endl;
    }

    return app.exec();
}
