import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtCharts 2.0
import QtQuick.Controls.Material 2.2

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
    }

    function cancel() {
        if (type === "subcategory") {
            type = "category"
            category = ""
            updateChart()
        } else {
            view_stack.pop()
        }
    }

    onStartChanged: updateChart()
    onEndChanged: updateChart()
    onTypeChanged: updateChart()

    onInitChanged: updateChart()

    function updateChart() {
        var values;
        var shades = [Material.Shade50, Material.Shade100, Material.Shade200, Material.Shade300, Material.Shade400, Material.Shade500, Material.Shade600, Material.Shade700, Material.Shade800, Material.Shade900]

        if (init) {
            if (type === "category") {
                values = Db.getMoneyPerCategory(start, end)
            } else if (type === "subcategory") {
                values = Db.getMoneyPerSubcategory(category, start, end)
            }

            var other = 0;
            chart.chartData.datasets[0].backgroundColor = []
            chart.chartData.datasets[0].data = []
            chart.chartData.labels = []
            for (var i in values) {
                if ((values.length > 10) && (i >= 10)) {
                    other += values[i].money
                } else {
                    chart.chartData.datasets[0].backgroundColor.push(Material.color(Material.Green, shades[i]))
                    chart.chartData.datasets[0].data.push(values[i].money)
                    chart.chartData.labels.push(values[i].name)
                }
            }
            if (values.length > 10) {
                chart.chartData.datasets[0].backgroundColor.push(Material.color(Material.Green, shades[10]))
                chart.chartData.datasets[0].data.push(other)
                chart.chartData.labels.push("Anderes")
            }
            chart.update()
        }
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        Text {
            text: page.title
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        color: Material.primary
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

    Chart {
        id: chart;
        anchors.fill: parent
        anchors.topMargin: dateRow.height + bar.height
        anchors.bottomMargin: button_back.visible ? button_back.height : 0
        chartType: ChartType.pie;

        chartData: {
            "datasets": [{
                             "data": [],
                             "backgroundColor": [],
                         },],
                    "labels": []
        }

        chartOptions: {
            "maintainAspectRatio": false,
            "defaultColor": 'rgba(0,0,0,0.1)',
            "defaultFontFamily": defaultFontFamily,
            "defaultFontSize": defaultFontSize,
            "events": ['click']
        }

        onClick: {
            var activeElement = getElementAtEvent(evt);
            if (activeElement[0]) {
                if (type === "category"){
                    console.log("active: " + activeElement[0]._view.label)
                    category = activeElement[0]._view.label
                    type = "subcategory"
                    updateChart()
                }
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
