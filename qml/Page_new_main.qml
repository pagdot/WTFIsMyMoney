import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Page {
    id: page
    title: "Hauptkategorie"

    signal chosen(string text)

    property var categories: []

    onCategoriesChanged: {
        var model = []
        for (var i in categories) {
            model.push(categories[i])
        }
    }

    function _chosen(text) {
        chosen(text)
    }

    Icon {
        id: icon
    }

    GridLayout {
        rows: 2
        columns: 2
        anchors.centerIn: parent


        Repeater {
            id: repeater
            model: categories

            delegate: Button {
                id: control
                //Layout.alignment: (index % 2) == 1 ? Qt.AlignLeft : Qt.AlignRight
                text: modelData.name
                onClicked: page._chosen(text)
                flat: true
                checkable: true
                checked: false

                contentItem: RowLayout {
                    Item {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: circle.width
                        implicitHeight: circle.height
                        Rectangle {
                            id: circle
                            width: catIcon.width * 2
                            height: width
                            radius: width/2
                            color: Material.accent
                            opacity: 0.26
                            visible: control.checked
                        }

                        Text {
                            id: catIcon
                            anchors.centerIn: circle
                            text: icon.icons[modelData.icon]
                            font.family: icon.family
                            font.pointSize: control.font.pointSize * 2
                            color: Material.accent
                            opacity: 1
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: control.text
                        font: control.font
                        elide: Text.ElideRight
                    }
                }

                background: Item {}
            }
        }
    }
}

