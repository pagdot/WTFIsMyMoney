import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.2

import "database.js" as Db


Page {
    function cancel() {
        view_stack.pop()
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        Text {
            text: "Einstellungen"
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        color: Material.primary
    }


    ColumnLayout {
        anchors.top: bar.bottom
        anchors.bottom: button_back.visible ? button_back.top : parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        ColumnLayout {
            Label {
                text: "Daten:"
            }

            Button {
                text: "Importieren"
                onClicked: {
                    fileOpen.open();
                }

                FileOpen {
                    id: fileOpen
                    visible: false

                    onAccepted: {
                        var data = parseCSV(fileOpen.content)
                        Db.importEntries(data)
                    }
                }
            }

            Button {
                text: "Exportieren"
                onClicked: {
                    fileSave.content = createCSV(Db.getAll());
                    fileSave.open();
                }

                FileSave {
                    id: fileSave
                    visible: false

                    onAccepted: {

                    }
                }
            }

            Button {
                text: "Daten löschen"
                onClicked: deleteDialog.open()

                Dialog {
                    id: deleteDialog
                    title: "Löschen bestätigen"
                    parent: page_main
                    x: (page_main.width - width) /2
                    y: (page_main.height - height) /2
                    standardButtons: Dialog.Ok | Dialog.Cancel

                    onAccepted: {
                        Db.clearDb()
                    }
                }
            }
        }
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
    }
}
