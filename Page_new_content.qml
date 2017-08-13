import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as Quick
import QtQuick.Controls 2.2

Page {
    id: page

    property date datum: new Date()

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: bt_date_prev
                anchors.right: bt_date.left
                anchors.rightMargin: 20

                background: Image {
                    source: "icons/arrow-left.svg"
                    width: height
                }

                onClicked: {
                    datum.setDate(datum.getDate() - 1)
                }
            }

            Button {
                id: bt_date
                anchors.horizontalCenter: parent.horizontalCenter
                text: datum.toLocaleDateString(Qt.locale("de_DE"))

                onClicked: {
                    calendar.selectedDate = datum
                    popup_date.open()
                }
            }
            Popup {
                id: popup_date
                contentItem: Column {
                    anchors.centerIn: page
                    Quick.Calendar {
                        id: calendar
                    }
                }
            }
        }


    }

}
