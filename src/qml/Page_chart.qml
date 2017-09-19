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
import QtQml 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Material.impl 2.2

import "database.js" as Db

Page {
    id: page
    title: "Statistik"

    property date start: new Date()
    property date end: new Date()

    property bool init: false

    onStartChanged: update();
    onEndChanged: update();

    function reset() {
        var tmp = new Date()
        tmp.setMonth(tmp.getMonth() - 5)
        tmp.setDate(1);
        start = tmp
        tmp = new Date()
        tmp.setMonth(tmp.getMonth()+1)
        tmp.setDate(0)
        end = tmp
        update();
    }

    function cancel() {
        view_stack.pop()
    }

    function update() {
        if (!init) {
            return
        }

        var monthMoney = Db.getMoneyPerMonth(start, end)
        var max;
        var min;
        var avg
        var sum = 0;
        for (var i in monthMoney) {
            sum += monthMoney[i].money
            if ((!max) || (max.money < monthMoney[i].money)) {
                max = monthMoney[i]
            }
            if ((!min) || (min.money > monthMoney[i].money)) {
                min = monthMoney[i]
            }
        }
        avg = sum / monthMoney.length
        mostExpensiveMonthName.text = Qt.locale().monthName(max.month.getMonth(), Locale.LongFormat)
        mostExpensiveMonthMoney.text = String(max.money).replace(".", Qt.locale().decimalPoint) + " €"
        leastExpensiveMonthName.text = Qt.locale().monthName(min.month.getMonth(), Locale.LongFormat)
        leastExpensiveMonthMoney.text = String(min.money).replace(".", Qt.locale().decimalPoint) + " €"
        averageMonth.text = String(avg.toFixed(2)).replace(".", Qt.locale().decimalPoint) + " €"
        list.model = monthMoney
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

    ColumnLayout {
        id: mainLayout
        anchors.top: bar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        RowLayout {
            id: dateRow
            implicitHeight: 100
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: bt_startDate
                text: Qt.locale().monthName(start.getMonth(), Locale.ShortFormat) + ", " + start.getFullYear()

                onClicked: {
                    datePickerStart.selectedDate = start
                    datePickerStart.open()
                }

            }
            Button {
                id: bt_endDate
                text: Qt.locale().monthName(end.getMonth(), Locale.ShortFormat) + ", " + end.getFullYear()


                onClicked: {
                    datePickerEnd.selectedDate = end
                    datePickerEnd.open()
                }

            }

            MonthPicker {
                id: datePickerStart
                parent: page
                objectName: "start"
                onAccepted: {
                    page.start = selectedDate
                    if (page.start > page.end) {
                        page.end = Db.lastDayOfMonth(page.start)
                    }
                }
                x: (page.width - width) / 2
                y: (page.height - height) / 2
            }

            MonthPicker {
                id: datePickerEnd
                parent: page
                objectName: "end"
                onAccepted: {
                    page.end = Db.lastDayOfMonth(selectedDate)
                    if (page.start > page.end) {
                        var tmp = new Date(page.end)
                        tmp.setDate(1)
                        page.start = tmp
                    }
                }
                x: (page.width - width) / 2
                y: (page.height - height) / 2
            }
        }

        GridLayout {
            id: grid
            columns: 3
            columnSpacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 5

            Label {
                id: mostExpensiveMonthLabel;
                font.pointSize: 16
                text: "Teuerstes Monat:"
            }
            Label {
                id: mostExpensiveMonthName
                font.pointSize: 16
            }
            Label {
                id: mostExpensiveMonthMoney
                font.pointSize: 16
            }
            Label {
                id: leastExpensiveMonthLabel;
                font.pointSize: 16
                text: "Günstigster Monat:"
            }
            Label {
                id: leastExpensiveMonthName
                font.pointSize: 16
            }
            Label {
                id: leastExpensiveMonthMoney
                font.pointSize: 16
            }
            Label {
                id: averageMonthLabel;
                font.pointSize: 16
                text: "Durchschnitt:"
            }
            Label {
                id: averageMonth
                font.pointSize: 16
            }
        }

        ListView {
            id: list
            anchors.left: parent.left
            anchors.right: parent.right
            Layout.fillHeight: true
            anchors.margins: 8
            spacing: 8
            clip: true

            header: Item{height: 8}
            footer: Item{height: 8}

            delegate: Pane {
                padding: 16
                topPadding: 24
                bottomPadding: 24
                Material.elevation: 2
                width: parent.width
                implicitHeight: money.height + monthAndYear.height + 2*padding
                AbstractButton {
                    anchors.fill: parent
                    onClicked: {
                        if (modelData.money > 0) {
                            dialog.openDialog(modelData.month)
                        }
                    }

                    Text {
                        id: money
                        text: (new String(modelData.money)).replace(".", ",") + " €"
                        anchors.top: parent.top
                        anchors.left: parent.left
                        font.pointSize: 24
                    }

                    Text {
                        id: monthAndYear
                        anchors.top: money.bottom
                        anchors.left: parent.left
                        font.pointSize: 14
                        color: Material.color(Material.Grey, Material.Shade500)
                        text: Qt.locale().monthName(modelData.month.getMonth(), Locale.ShortFormat) + " " + modelData.month.getFullYear()
                    }

                    Dialog {
                        id: dialog
                        parent: page
                        x: (page.width - width)/2
                        y: (page.height - height)/2
                        margins: 50
                        width: page.width - leftMargin - rightMargin
                        height: page.height - topMargin - bottomMargin

                        property date start;
                        property date end;

                        function openDialog(month) {
                            start = new Date(month)
                            end = Db.lastDayOfMonth(month)
                            chart.type = "category"
                            updateChart()
                            open()
                        }

                        function updateChart() {
                            var values;
                            if (chart.type === "category") {
                                values = Db.getMoneyPerCategory(start, end)
                            } else if (chart.type === "subcategory") {
                                values = Db.getMoneyPerSubcategory(chart.category, start, end)
                            } else {
                                return
                            }

                            pieSeries.clear()

                            for (var i in values) {
                                pieSeries.append(values[i].name, values[i].money)
                            }
                            repeater.model = values
                        }

                        title: Qt.locale().monthName(modelData.month.getMonth(), Locale.LongFormat)

                        ColumnLayout {
                            id: legendBox
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 0

                            Repeater {
                                id: repeater
                                Rectangle {
                                    implicitHeight: 32

                                    Rectangle {
                                        id: rect
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 16
                                        height: 16
                                        color: Material.color(Material.Green, chart.shades[index])
                                    }

                                    Text {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 32

                                        verticalAlignment: Text.AlignVCenter

                                        text: modelData.name + " " + (new String(modelData.money)).replace(".", ",") + " €"
                                        font.pointSize: 14

                                    }
                                }
                            }
                        }

                        ChartView {
                            id: chart

                            property string category;
                            property string type;

                            property var shades: [Material.Shade50, Material.Shade100, Material.Shade200, Material.Shade300, Material.Shade400, Material.Shade500, Material.Shade600, Material.Shade700, Material.Shade800, Material.Shade900]
                            height: width
                            //anchors.top: legendBox.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            antialiasing: true
                            legend.visible: false

                            PieSeries {
                                id: pieSeries
                                onSliceAdded: {
                                    slice.color = Material.color(Material.Green, chart.shades[count - 1])
                                }
                                size: 1

                                onClicked: {
                                    if (chart.type === "category") {
                                        chart.category = slice.label
                                        chart.type = "subcategory"
                                    } else if (chart.type == "subcategory") {
                                        chart.category = "";
                                        chart.type = "category"
                                    } else {
                                        return;
                                    }

                                    dialog.updateChart()
                                }
                            }
                        }

                        standardButtons: Dialog.Ok
                    }
                }
            }

        }
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
        init = true
    }
}
