/* main.cpp -- main source file
 * init program and start UI
 *
 * Copyright (C) 2017 Paul Goetzinger
 * All Rights Reserved.
 *
 * This file is part of WTFIsMyMoney.
 *
 * WTFIsMyMoney is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * WTFIsMyMoney is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with WTFIsMyMoney.  If not, see <http://www.gnu.org/licenses/>.
 */

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
