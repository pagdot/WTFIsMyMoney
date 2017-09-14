/* Page_chart.qml -- Chart and statistic page
 * Displays the statistics and charts of the processed data
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtCharts 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Material.impl 2.2

import "database.js" as Db

Page {
    id: page
    title: "Statistik"

    property date start: new Date()
    property date end: new Date()

    property var type: "category"
    property var category: ""

    property bool init: false

    function reset() {
        var tmp = new Date()
        tmp.setMonth(tmp.getMonth() - 1)
        start = tmp
        end = new Date()
        type = "category"
        updateChart()
    }

    function cancel() {
        view_stack.pop()
    }

    onStartChanged: updateChart()
    onEndChanged: updateChart()

    onInitChanged: updateChart()

    function updateChart() {
        var values;
        if (init) {
            if (type === "category") {
                values = Db.getMoneyPerCategory(start, end)
            } else if (type === "subcategory") {
                values = Db.getMoneyPerSubcategory(category, start, end)
            }

            var other = 0;
            pieSeries.clear()
            for (var i in values) {
                if ((values.length > 10) && (i >= 10)) {
                    other += values[i].money
                } else {
                    pieSeries.append(values[i].name, values[i].money)
                }
            }
            if (values.length > 10) {
                pieSeries.append("Anderes", other)
            }
        }
    }


    Icon {
        id: icon
    }

    Pane {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        Material.elevation: 4
        padding: 0
        z: 1

        background: Rectangle {
            anchors.fill: parent
            color: Material.primary

            layer.enabled: bar.enabled && bar.Material.elevation > 0
            layer.effect: ElevationEffect {
                elevation: bar.Material.elevation
            }
        }

        AbstractButton {
            id: buttonBack
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 16
            implicitWidth: height

            Text {
                anchors.fill: parent
                font.family: icon.family
                text: icon.icons.arrow_left
                color: "white"
                font.pointSize: 32
                fontSizeMode: Text.VerticalFit
            }

            onClicked: cancel()
        }

        Text {
            text: page.title
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }
    }


    RowLayout {
        id: dateRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: bar.bottom
        Button {
            id: bt_startDate
            text: Qt.locale().monthName(start.getMonth(), Locale.ShortFormat) + ", " + start.getDate() + " " + start.getFullYear()

            onClicked: {
                datePickerStart.open()
            }

        }
        Button {
            id: bt_endDate
            text: Qt.locale().monthName(end.getMonth(), Locale.ShortFormat) + ", " + end.getDate() + " " + end.getFullYear()


            onClicked: {
                datePickerEnd.open()
            }

        }
    }

    ChartView {
        id: chart
        anchors.fill: parent
        anchors.topMargin: dateRow.height + bar.height
        antialiasing: true
        backgroundColor: Material.background

        PieSeries {
            property var shades: [Material.Shade50, Material.Shade100, Material.Shade200, Material.Shade300, Material.Shade400, Material.Shade500, Material.Shade600, Material.Shade700, Material.Shade800, Material.Shade900]
            id: pieSeries
            onSliceAdded: {
                slice.color = Material.color(Material.Green, shades[count - 1])
            }

            onClicked: {
                page.category = slice.label
                page.type = "subcategory"
                updateChart()
            }
        }
    }

    DatePicker {
        id: datePickerStart
        objectName: "start"
        selectedDate: start
        onClosed: start = selectedDate
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }

    DatePicker {
        id: datePickerEnd
        objectName: "end"
        selectedDate: end
        onClosed: end = selectedDate
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
        init = true
    }
}
