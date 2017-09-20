/* MonthPicker.qml -- Month Picker
 * QML Dialog that allows choosing a month of a specific year
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

Dialog {
    id: dialog
    property date selectedDate: new Date()

    margins: 40

    standardButtons: Dialog.Ok | Dialog.Cancel

    onOpened: {
        yearTumbler.contentItem.positionViewAtIndex(selectedDate.getFullYear() - yearTumbler.start, ListView.Center)
        monthTumbler.contentItem.positionViewAtIndex(selectedDate.getMonth(), ListView.Center)
    }

    RowLayout {
        anchors.fill: parent

        Tumbler {
            id: yearTumbler
            model: calcModel(start, end)
            property int start: 1900
            property int end: 2100
            Layout.fillHeight: true
            visibleItemCount: 5

            delegate: Text {
                height: yearTumbler.height / yearTumbler.visibleItemCount - yearTumbler.spacing
                id: yearLabel
                text: modelData
                color: Material.foreground
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: (1.0 - Math.abs(Tumbler.displacement) / (yearTumbler.visibleItemCount / 2)) * (yearTumbler.enabled ? 1 : 0.6)
            }

            contentItem: ListView {
                model: parent.model
                delegate: parent.delegate
                anchors.fill: parent

                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height / 2 - (height / parent.visibleItemCount / 2)
                preferredHighlightEnd: height / 2 + (height / parent.visibleItemCount / 2)
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                clip: true
            }

            onCurrentIndexChanged: {
                var tmpDate = new Date(selectedDate)
                tmpDate.setFullYear(currentIndex + start)
                selectedDate = tmpDate
            }
            function calcModel(start, end) {
                var tmp = [];
                if (start > end) {
                    model = [];
                    return;
                }
                for (var i = start; i <= end; i++) {
                    tmp.push(i);
                }
                model = tmp;
            }
        }

        Tumbler {
            id: monthTumbler
            model: 12
            visibleItemCount: 5
            Layout.fillHeight: true

            delegate: Text {
                id: monthLabel
                text: Qt.locale().monthName(modelData, Locale.LongFormat)
                color: Material.foreground
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: (1.0 - Math.abs(Tumbler.displacement) / (monthTumbler.visibleItemCount / 2)) * (monthTumbler.enabled ? 1 : 0.6)

                Component.onCompleted: {
                    if (monthTumbler.implicitWidth < contentWidth) {
                        monthTumbler.implicitWidth = contentWidth
                    }
                }
            }

            contentItem: ListView {
                model: parent.model
                delegate: parent.delegate
                anchors.fill: parent

                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height / 2 - (height / parent.visibleItemCount / 2)
                preferredHighlightEnd: height / 2 + (height / parent.visibleItemCount / 2)
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                clip: true
            }

            onCurrentIndexChanged: {
                var tmpDate = new Date(selectedDate)
                tmpDate.setMonth(currentIndex)
                selectedDate = tmpDate
            }
        }

        Material.elevation: 24
    }

}
