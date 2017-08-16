import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0

Page {
    id: page

    property date start: new Date()
    property date end: new Date()

    function reset() {
        var tmp = new Date()
        tmp.setMonth(tmp.getMonth() - 1)
        start = tmp
        end = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            Button {
                id: bt_startDate
                text: Qt.locale().monthName(start.getMonth(), Locale.ShortFormat) + ", " + start.getDate() + " " + start.getFullYear()
                Layout.alignment: Qt.AlignHCenter

                onClicked: {
                    datePickerStart.open()
                }

            }
            Button {
                id: bt_endDate
                text: Qt.locale().monthName(end.getMonth(), Locale.ShortFormat) + ", " + end.getDate() + " " + end.getFullYear()
                Layout.alignment: Qt.AlignHCenter


                onClicked: {
                    datePickerEnd.open()
                }

            }
        }
    }
    DatePicker {
        id: datePickerStart
        selectedDate: start
        onClosed: start = selectedDate
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }

    DatePicker {
        id: datePickerEnd
        selectedDate: end
        onClosed: end = selectedDate
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }
}
