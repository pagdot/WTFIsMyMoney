/* fileio -- file wrapper
 * Provides functions to open, create, read and write files
 *
 * Copyright (C) 2017 Paul Goetzinger <paul70079@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0
 * License-Filename: LICENSE/GPL-3.0.txt
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

#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QString>
#include <QUrl>

class FileIO : public QObject
{
    Q_OBJECT

public:
    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE QString read(QUrl const &fName);
    Q_INVOKABLE bool write(QUrl const &fName, const QString& data);

signals:
    void error(const QString& msg);
};

#endif // FILEIO_H
