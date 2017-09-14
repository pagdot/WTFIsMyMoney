/* Datepicker.qml -- Material like datepicker
 * QML Dialog that mimics the Android Material Themed datepicker
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
import QtQml 2.2
import Qt.labs.calendar 1.0
import QtQuick.Controls.Material 2.2

Dialog{
    id: dialog
    property date selectedDate: new Date()

    standardButtons: Dialog.Ok | Dialog.Cancel

    Icon {
        id: icon
    }

    Material.elevation: 24

    width: 300
    height: 500
    padding: 0
    topPadding: 0

    onAccepted: selectedDate = stack.tmp_date

    Page {
        id: column

        anchors.fill: parent
        anchors.margins: 0

        Rectangle {
            id: rectangle
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
            color: Material.primary

            Button {
                id: bt_year
                flat: true
                text: stack.tmp_date.getFullYear()
                anchors.top: parent.top
                anchors.left: parent.left

                enabled: stack.depth === 1

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    opacity: parent.enabled ? 1 : 0.5
                }
                background.opacity: down ? 1 : 0

                onClicked: stack.push(year_view, StackView.Immediate)
            }
            Button {
                id: bt_date
                anchors.top: bt_year.bottom
                anchors.left: parent.left
                flat: true
                enabled: stack.depth === 2

                contentItem: Text {
                    text: parent.text
                    font.pointSize: 20
                    font.weight: Font.DemiBold
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    opacity: parent.enabled ? 1 : 0.5
                }
                background.opacity: down ? 1 : 0
                onClicked: stack.pop(null, StackView.Immediate)

                text: Qt.locale().dayName(stack.tmp_date.getDay(), Locale.ShortFormat) + ", " + Qt.locale().monthName(stack.tmp_date.getMonth(), Locale.ShortFormat) + " " + stack.tmp_date.getFullYear()
            }
        }


        StackView {
            id: stack
            property date tmp_date: selectedDate

            initialItem: calendar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle.bottom
            anchors.bottom: parent.bottom
        }

        Component {
            id: calendar
            Page {
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 0
                id: calendar_view

                RowLayout {
                    id: controls

                    z: 1

                    anchors.top: parent.top
                    anchors.topMargin: 25
                    anchors.left: listview.left
                    anchors.right: listview.right

                    height: children.height

                    AbstractButton {
                        height: 20; width: 20;
                        Layout.alignment: Qt.AlignLeft
                        onClicked: listview.decrementCurrentIndex()
                        Text {
                            anchors.fill: parent
                            fontSizeMode: Text.Fit
                            font.pointSize: 32
                            font.family: icon.family
                            text: icon.icons.chevron_left
                        }
                    }


                    AbstractButton {
                        height: 20; width: 20;
                        Layout.alignment: Qt.AlignRight
                        onClicked: listview.incrementCurrentIndex()
                        Text {
                            anchors.fill: parent
                            fontSizeMode: Text.Fit
                            font.pointSize: 32
                            font.family: icon.family
                            text: icon.icons.chevron_right
                        }
                    }
                }

                ListView {
                    id: listview

                    property var currentYear: model.yearAt(currentIndex)
                    property var currentMonth: model.monthAt(currentIndex)

                    anchors.fill: parent

                    spacing: 20

                    snapMode: ListView.SnapOneItem
                    orientation: ListView.Horizontal
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    clip: true
                    currentIndex: monthDiff(from, stack.tmp_date)

                    function monthDiff(date1, date2) {
                        return (date2.getFullYear() * 12 + date2.getMonth()) - (date1.getFullYear() * 12 + date1.getMonth())
                    }

                    property date from: new Date(1900, 0, 1)
                    property date to: new Date(2099, 11, 31)

                    highlightMoveDuration: 0

                    model: CalendarModel {
                        id: model
                        from: listview.from
                        to: listview.to
                    }

                    delegate: Page {

                        width: listview.width
                        height: listview.height

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.locale().monthName(model.month) + " " + model.year
                            anchors.topMargin: 25
                            anchors.top: parent.top
                            font: grid.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        DayOfWeekRow {
                            locale: model.locale
                            anchors.bottom: grid.top
                            anchors.left: grid.left
                            anchors.right: grid.right
                            Layout.alignment: Qt.AlignBottom

                            delegate: Text {
                                text: model.narrowName
                                color: Material.color(Material.Grey)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MonthGrid {
                            id: grid
                            month: model.month
                            year: model.year
                            locale: model.locale
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom

                            height: Math.min(Layout.width, Layout.height)
                            width: Math.min(Layout.width, Layout.height)

                            delegate: RadioButton {
                                opacity: model.month === grid.month ? 1 : 0
                                text: model.day
                                font: grid.font
                                width: 32
                                height: 32
                                checked: (stack.tmp_date.getDate() === model.day) && (stack.tmp_date.getFullYear() === model.year) && (stack.tmp_date.getMonth() === model.month)

                                //Component.onCompleted: checked = (stack.tmp_date.getDate() === model.day) && (stack.tmp_date.getFullYear() === model.year) && (stack.tmp_date.getMonth() === model.month) ? true : false

                                indicator: Rectangle {
                                    anchors.fill: parent
                                    radius: Math.max(width, height)/2
                                    visible: parent.checked
                                    color: Material.primary
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: parent.checked ? "white" : Material.foreground
                                    z: 1
                                }

                                onClicked: {
                                    if (checked) {
                                        stack.tmp_date = model.date
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        Component {
            id: year_view

            Page {
                id: page
                Tumbler {
                    id: yearTumbler
                    model: calcModel(start, end)
                    property int start: 1900
                    property int end: 2100
                    visibleItemCount: 5
                    wrap: false
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height

                    delegate: Text {
                        id: label
                        text: modelData
                        color: Material.foreground
                        font.pointSize: 16
                        opacity: 1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    currentIndex: stack.tmp_date.getFullYear() - start

                    onCurrentIndexChanged: {
                        var _date = stack.tmp_date
                        _date.setFullYear(currentIndex + start)
                        stack.tmp_date = _date
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
            }
        }
    }
}
