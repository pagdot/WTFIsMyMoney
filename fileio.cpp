/* fileio.cpp -- file wrapper
 * Provides functions to open, create, read and write files
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

#include "fileio.h"
#include <QFile>
#include <QTextStream>

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

QString FileIO::read(QUrl const &fName)
{
    if (fName.isEmpty()){
        emit error("file name is empty");
        return QString();
    }

    QFile file(fName.toLocalFile());
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line + "\n";
         } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

bool FileIO::write(QUrl const &fName, const QString& data)
{
    if (fName.isEmpty())
        return false;

    QFile file(fName.toLocalFile());
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}
