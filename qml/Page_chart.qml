import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtCharts 2.0
import QtQuick.Controls.Material 2.2
import "./Charts"

import "database.js" as Db

Page {
    id: page

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
        view_stack.pop()
    }

    onStartChanged: updateChart()
    onEndChanged: updateChart()

    onInitChanged: updateChart()

    function updateChart() {
        var values;
        var shades = [Material.Shade50, Material.Shade100, Material.Shade200, Material.Shade300, Material.Shade400, Material.Shade500, Material.Shade600, Material.Shade700, Material.Shade800, Material.Shade900]

        //console.log(JSON.stringify(chart.chartData))
        //console.log(JSON.stringify(chart.chartData.datasets[0]))

        if (init) {
            if (type === "category") {
                values = Db.getMoneyPerCategory(start, end)
            } else if (type === "subcategory") {
                values = getMoneyPerSubcategory(category, start, end)
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
                //pieSeries.append("Anderes", other)
            }
            //chart.chartData = chartData
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

    Chart {
      id: chart;
      anchors.fill: parent
      anchors.topMargin: dateRow.height
      anchors.bottomMargin: button_back.visible ? button_back.height : 0

      function randomScalingFactor() {
          return Math.round(Math.random() * 100);
      }

      chartData: {
          "datasets": [{
                           "data": [],
                           "backgroundColor": [],
                       }],
                  "labels": []
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
