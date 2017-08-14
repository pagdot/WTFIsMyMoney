import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0
import QtQuick.LocalStorage 2.0

import "database.js" as Db

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Studenten Finanz - " + view_stack.currentItem.title

    header: Label {
            text: view_stack.currentItem.title
            horizontalAlignment: Text.AlignHCenter
    }

    StackView {
        id: view_stack
        anchors.fill: parent
        initialItem: page_main

    }


    Component {
        id: page_main
        Page {
            ColumnLayout {
                anchors.fill: parent

                Button {
                    id: bt_new
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignCenter
                    text: "New entry"
                    onClicked: {
                        var item = view_stack.push("Page_new.qml")
                        item.reset()
                    }
                }

                Button {
                    id: bt_reset
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignCenter
                    text: "Reset Database"
                    onClicked: Db.reset()
                }

                Button {
                    text: "sql"
                    Layout.alignment: Qt.AlignCenter

                    onClicked: dialog.open()

                    Dialog {
                        id: dialog
                        width: 300
                        height: 150

                        onOpened: query_text.focus = true

                        TextField {
                            id: query_text
                            anchors.centerIn: parent
                            onAccepted: dialog.accept()
                        }

                        x: 0
                        y: -400

                        standardButtons: Dialog.Ok

                        onAccepted: console.log("ROWS: " + JSON.stringify(Db.sql(query_text.text)))
                    }
                }
            }
        }
    }

    onClosing: {
        if (Qt.platform.os == "android") {
            if (view_stack.depth <= 1) {
                close.accepted = true
            } else {
                view_stack.currentItem.cancel()
                close.accepted = false
            }
        }
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
    }
}
