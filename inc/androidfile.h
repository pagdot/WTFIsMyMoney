/* androidfile -- android file wrapper
 * Provides functions to open, create, read and write files on android
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

#ifndef ANDROIDFILE_H
#define ANDROIDFILE_H

#include <QObject>
#include <QAndroidActivityResultReceiver>
#include <QAndroidJniObject>
#include <QUrl>
#include <QString>

class AndroidFile : public QObject, QAndroidActivityResultReceiver
{
    Q_OBJECT
public:
    explicit AndroidFile(QObject *parent = nullptr);

    Q_PROPERTY(QString mime MEMBER m_mime NOTIFY mimeChanged)

    Q_INVOKABLE void fileOpenDialog();
    Q_INVOKABLE void fileCreateDialog();

    Q_INVOKABLE static QString fileOpen(QUrl fileUrl);
    Q_INVOKABLE static void fileCreate(QUrl fileUrl, QString content);

    virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) override;

protected:

private:
    QString m_mime = "*/*";

signals:
    void opened(QString fileUri);
    void created(QString fileUri);
    void mimeChanged();

public slots:
};

#endif // ANDROIDFILE_H
