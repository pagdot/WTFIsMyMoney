/* Page_qr.qml -- QR Reader Page
 * Opens a QR-Code reader to read QR-Codes on austrian bills
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

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Material.impl 2.2
import QtMultimedia 5.5
import QZXing 2.3

Page {
    id: page
    signal cancel()
    signal complete(real money, string date)
    signal error()

    Rectangle
    {
        id: bgRect
        color: "white"
        anchors.fill: videoOutput
    }

    Camera
    {
        id:camera
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
        }
    }

    VideoOutput
    {
        id: videoOutput
        source: camera
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        autoOrientation: true
        fillMode: VideoOutput.Stretch
        filters: [ zxingFilter ]

        Rectangle {
            id: captureZone
            color: "white"
            opacity: 0.2
            width: parent.width / 2
            height: parent.height / 2
            anchors.centerIn: parent
        }
    }

    QZXingFilter
    {
        id: zxingFilter
        captureRect: {
            // setup bindings
            videoOutput.contentRect;
            videoOutput.sourceRect;
            return videoOutput.mapRectToSource(videoOutput.mapNormalizedRectToItem(Qt.rect(
                0.25, 0.25, 0.5, 0.5
            )));
        }

        decoder {
            enabledDecoders: QZXing.DecoderFormat_QR_CODE

            onTagFound: {
                var data = tag.split("_")
                if (data.length != 14) {
                    page.error()
                    return
                }

                var date = data[4]
                var money = parseFloat(data[5].replace(",", "."))
                money += parseFloat(data[6].replace(",", "."))
                money += parseFloat(data[7].replace(",", "."))
                money += parseFloat(data[8].replace(",", "."))
                money += parseFloat(data[9].replace(",", "."))

                complete(money, date)
            }

            tryHarder: false
        }
    }
}
