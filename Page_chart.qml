import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtCharts 2.0
import QtQuick.Controls.Material 2.2

import "database.js" as Db

Page {
    id: page

    property date start: new Date()
    property date end: new Date()

    property bool init: false

    function reset() {
        var tmp = new Date()
        tmp.setMonth(tmp.getMonth() - 1)
        start = tmp
        end = new Date()
    }

    function cancel() {
        view_stack.pop()
    }

    onStartChanged: updateChart()
    onEndChanged: updateChart()

    onInitChanged: updateChart()

    function updateChart() {
        if (init) {
            var values = Db.getMoneyPerCategory(start, end)
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

    RowLayout {
        id: dateRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
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
        anchors.topMargin: dateRow.height
        anchors.bottomMargin: button_back.visible ? button_back.height : 0
        //theme: ChartView.ChartThemeBrownSand
        antialiasing: true


        PieSeries {
            property var shades: [Material.Shade50, Material.Shade100, Material.Shade200, Material.Shade300, Material.Shade400, Material.Shade500, Material.Shade600, Material.Shade700, Material.Shade800, Material.Shade900]
            id: pieSeries
            onSliceAdded: {
                slice.color = Material.color(Material.Green, shades[count - 1])
                //slice.labelVisible = true
                //slice.labelPosition = PieSlice.LabelInsideHorizontal
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


    Button {
        id: button_back
        visible: Qt.platform.os !== "android"
        text: "Zurück"
        anchors.bottom: parent.bottom
        width: parent.width
        onClicked: cancel()
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
        init = true
    }
}
