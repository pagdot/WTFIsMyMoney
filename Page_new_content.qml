import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Page {
    id: page

    property date datum: new Date()
    property int money: 0

    signal done

    RowLayout {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        spacing: 20
        Button {
            id: bt_date_prev

            background: Image {
                anchors.centerIn: parent
                source: "icons/chevron-left.svg"
                width: 24; height: 24
            }

            onClicked: {
                var _date = datum
                _date.setDate(_date.getDate() - 1)
                datum = _date
            }
        }

        Button {
            id: bt_date
            text: Qt.locale().monthName(datum.getMonth(), Locale.ShortFormat) + ", " + datum.getDate() + " " + datum.getFullYear()


            onClicked: {
                datePicker.open()
            }

        }

        Button {
            id: bt_date_next

            background: Image {
                anchors.centerIn: parent
                source: "icons/chevron-right.svg"
                width: 24; height: 24
            }

            onClicked: {
                var _date = datum
                _date.setDate(_date.getDate() + 1)
                datum = _date
            }
        }
    }

    Item {
        anchors.top: row.bottom
        anchors.bottom: button.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20

        Dial {
            id: dial
            from: 0
            to: 30
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 50
            value: money
            onValueChanged: money = value
        }


        TextField {
            focus: false
            anchors.top: parent.top
            anchors.left: parent.left
            width: Math.max(bt_plus.width, bt_minus.width)
            text: focus ? money : money + " €"
            validator: IntValidator{bottom: 0}
            onTextEdited: money = text
            onEditingFinished: focus = false
        }

        Button {
            id: bt_plus
            anchors.top: parent.top
            anchors.right: parent.right
            text: "+5 €"

            onClicked: money = money + 5
        }

        Button {
            id: bt_minus
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: "+5 €"

            onClicked: money = money - 5
        }
    }

    Button {
        id: button
        text: "Fertig"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: done()
    }

    onDatumChanged: datePicker.selectedDate = page.datum

    DatePicker{
        id: datePicker
        selectedDate: page.datum
        onClosed: page.datum = selectedDate
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }

}
