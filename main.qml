import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0

import "database.js" as Db

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Studenten Finanz - " + view_stack.currentItem.title

    id: window

    header: Label {
            text: view_stack.currentItem.title
            horizontalAlignment: Text.AlignHCenter
    }

    StackView {
        id: view_stack
        anchors.fill: parent
        initialItem: page_main

        onCurrentItemChanged: {
            if (depth === 1) {
                currentItem.updateEntries()
            }
        }

    }

    Page_main{
        id: page_main
    }


    /*
    Component {
        id: page_main

        Page {
            property bool init: window.init

            onInitChanged: updateEntries()

            function updateEntries() {
                if (init) {
                    list.model = Db.getEntries(20)
                }
            }

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 10
                anchors.bottomMargin: anchors.margins + bottomBar.height
                onModelChanged: console.log("updatedModel")
                spacing: 10


                delegate: Item {
                    width: list.width
                    height: 88

                    Item {
                        z: 1
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        Text{
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40
                            height: 40
                            verticalAlignment: Qt.AlignVCenter
                            font.bold: true
                            font.pointSize: 24
                            fontSizeMode: Text.HorizontalFit
                            text: modelData.money + " €"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 56
                            spacing: 10

                            Text{
                                font.bold: true
                                font.pointSize: 12
                                text: modelData.category + ": " + modelData.subcategory
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text{
                                font.pointSize: 12
                                color: Material.color(Material.Grey)
                                text: Qt.locale().monthName(modelData.datestamp.getMonth(), Locale.ShortFormat) + ", " + modelData.datestamp.getDate() + " " + modelData.datestamp.getFullYear()
                                Layout.alignment: Qt.AlignVCenter
                            }

                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        border.color: "black"
                        radius: 10
                    }
                }
            }

            Button {
                id: addButton
                z: 1
                width: 56
                height: width
                anchors.right: parent.right
                anchors.verticalCenter: bottomBar.top
                anchors.margins: 16
                onClicked: {
                    var item = view_stack.push("Page_new.qml")
                    item.reset()
                    focus = false
                }

                background: Rectangle {
                    Image {
                        source: "icons/add.svg"
                        anchors.fill: parent
                        anchors.margins: (parent.width - 24)/2
                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: parent.focus ? Material.color(Material.Grey) : Material.background
                        }

                    }
                    anchors.fill: parent
                    radius: width/2
                    color: parent.focus ? "white" : Material.accent
                    }
                }

                DropShadow {
                    anchors.fill: addButton
                    source: addButton
                    verticalOffset: 6
                    radius: width / 2
                    samples: 1 + radius * 2
                    opacity: 0.8
                }

            Button {
                id: bottomBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 56
                text: "Statistik"
                background: Rectangle {
                    anchors.fill: parent
                    color: Material.primary
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }


            ColumnLayout {
                visible: false
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
                    id: sql_bt
                    text: "sql"
                    Layout.alignment: Qt.AlignCenter

                    onClicked: dialog.open()

                    Dialog {
                        id: dialog
                        width: 250
                        height: 150

                        onOpened: query_text.focus = true

                        TextField {
                            id: query_text
                            anchors.centerIn: parent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            onAccepted: dialog.accept()
                        }

                        x: sql_bt.width/2 - width/2
                        y: -300

                        standardButtons: Dialog.Ok | Dialog.Cancel

                        Dialog {
                            id: response
                            property string text: ""
                            Text {
                                text: response.text
                            }
                            standardButtons: Dialog.Close
                        }

                        onAccepted: {
                            response.text = JSON.stringify(Db.sql(query_text.text))
                            response.open()
                        }
                    }
                }
            }
        }
    }
    */

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
}
