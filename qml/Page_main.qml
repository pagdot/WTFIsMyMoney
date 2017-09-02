import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.0
import FileIO 1.0

import "database.js" as Db

Page {
    id: page_main

    property bool init: false
    property int entryCount: 0

    onInitChanged: updateEntries()

    function getWeek(date) {
        var onejan = new Date(date.getFullYear(), 0, 1);
        return Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
    }

    Icon {
        id: icon
    }

    function updateEntries() {
        if (init){
            var date = new Date()
            list.model = Db.getEntries(20)
            month.text = Qt.locale().monthName(date.getMonth(), Locale.LongFormat) + ":  "
            week.text = "Woche " + getWeek(date) + ":  "
            var start = new Date(date);
            start.setDate(start.getDate() - start.getDay() + 1)
            var end = new Date(start)
            end.setDate(end.getDate() + 6)
            week.text += Db.getSum(start, end) + " €"
            start = new Date(date)
            start.setDate(1)
            end = new Date(date)
            end.setMonth(end.getMonth() + 1)
            end.setDate(0)
            month.text += Db.getSum(start, end) + " €"
            entryCount = Db.getEntryCount()
        }
    }

    function createCSV(data) {
        var csv = "date,money,subcategory,category,notes\r\n";
        for (var i in data) {
            csv += data[i].datestamp + "," + data[i].money + "," + data[i].subcategory.replace(",", "") + "," + data[i].category.replace(",", "") + "," + data[i].notes + "\r\n"
        }
        return csv;
    }

    function parseCSV(csv) {
        var data = []
        var cols = []
        csv.replace("\r\n", "\n");
        var lines = csv.split("\n")
        for (var i in lines) {
            if (lines[i] === "") continue
            var line = lines[i].split(",")
            if (i === "0") {
                cols = line
            } else {
                var entry = {}
                for (var j in line) {
                    entry[cols[j]] = line[j]
                }
                if (entry.date) entry.date = new Date(entry.date)
                data.push(entry)
            }
        }
        return data;
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        Button {
            id: bt_menu
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 0
            width: height
            flat: true
            font.family: icon.family
            font.pointSize: 48
            text: icon.icons.more_vert
            onClicked: menu.open()

            contentItem: Text {
                anchors.fill: parent
                anchors.margins: 16
                text: parent.text
                font: parent.font
                opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                fontSizeMode: Text.VerticalFit
            }
        }

        Text {
            text: Qt.application.displayName
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        color: Material.primary

        Menu {
            id: menu
            x: bt_menu.x + bt_menu.width - menu.width + bt_menu.anchors.margins / 2
            y: bt_menu.y - bt_menu.anchors.margins/2

            MenuItem {
                text: "Einstellungen"
                onTriggered: {
                    view_stack.push(page_settings)
                }
            }

            MenuItem {
                text: "Über"
                onTriggered: about.open()

                Dialog {
                    id: about
                    parent: page_main
//                    x: (page_main.width - width) /2
//                    y: (page_main.height - height) /2
                    margins: 40
                    width: page_main.width - 2*margins
                    height: page_main.height - 2*margins
                    title: "Über"
                    standardButtons: DialogButtonBox.Ok

                    GridLayout {
                        anchors.centerIn: parent
                        columns: 2

                        Label{text: "Author: "}
                        Label{text: "Paul Götzinger"}

                        Label{text: "Version: "}
                        Label{text: Qt.application.version}

                    }

                    footer: DialogButtonBox {
                        alignment: Qt.AlignHCenter
                        visible: true
                    }
                }
            }
        }
    }

    GridLayout {
        id: grid
        columns: 2
        columnSpacing: 20
        anchors.top: bar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5
        Label {id: month}
        Label {id: week}
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: 10
        anchors.bottomMargin: bottomBar.height
        anchors.topMargin: anchors.margins + grid.height + bar.height
        spacing: 10
        clip: true

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
        footer: Button {
            text: "lade weitere"
            width: list.width
            height: 88
            flat: true
            visible: entryCount > list.count
            onClicked: {
                list.model = Db.getEntries(list.count + 20)
            }
        }


        MouseArea {
            anchors.fill: parent
            onPressAndHold: {
                //var item = list.itemAt(mouse.x, mouse.y)
                var nr = list.indexAt(mouse.x, mouse.y)
                contextMenu.model = list.model[nr]
                contextMenu.x = x + mouse.x - contextMenu.width / 2
                contextMenu.y = y + mouse.y - contextMenu.height - 30
                contextMenu.open()
            }
        }

        Popup {
            id: contextMenu

            property var model;
            padding: 0
            leftPadding: 10
            rightPadding: 10

            RowLayout {

                Button {
                    id: editEntry
                    text: "Bearbeiten"
                    flat: true
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
                        color: Material.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        contextMenu.close()
                        var item = view_stack.push(page_new)
                        item.load(contextMenu.model)
                    }
                }
                Button {
                    id: deleteEntry
                    text: "Löschen"
                    flat: true

                    onClicked: {
                        contextMenu.close()
                        deleteDialog.open()
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
                        color: Material.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Dialog {
                        id: deleteDialog
                        title: "Löschen bestätigen"
                        parent: page_main
                        x: (page_main.width - width) /2
                        y: (page_main.height - height) /2
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        onAccepted: {
                            Db.deleteEntry(contextMenu.model.nr)
                            updateEntries()
                        }
                    }
                }
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
        font.family: icon.family
        text: icon.icons.add
        font.pointSize: 100

        onClicked: {
            var item = view_stack.push(page_new)
            item.reset()
            focus = false
        }

        contentItem: Text {
            anchors.centerIn: parent
            width: 24
            height: 24
            text: parent.text
            font: parent.font
            opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            fontSizeMode: Text.Fit
        }

        background: Rectangle {
            anchors.fill: parent
            radius: width/2
            color: Material.accent
        }
    }

    DropShadow {
        anchors.fill: addButton
        source: addButton
        verticalOffset: 6
        radius: width / 2
        samples: 1 + radius * 2
        opacity: 0.6
        z:1
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
        onClicked: {
            var item = view_stack.push(page_chart)
            item.reset()
            focus = false
        }
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
        init = true
    }
}
