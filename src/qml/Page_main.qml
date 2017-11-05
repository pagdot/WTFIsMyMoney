/* Page_main.qml -- Main page
 * Main Screen of the app
 *
 * Copyright (C) 2017 Paul Goetzinger <paul70079@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0
 * License-Filename: LICENSE/GPL-3.0.txt
 *
 * This file is part of WTFIsMyMoney.
 *
 * WTFIsMyMoney is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * WTFIsMyMoney is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with WTFIsMyMoney.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Material.impl 2.2
import QtQuick.Layouts 1.3

Page {
    id: page_main
    property int entryCount: 0
    property int entryViewCount: 20
    property var db;
    property alias changelog: mChangelog

    function getWeek(date) {
        var onejan = new Date(date.getFullYear(), 0, 1);
        return Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
    }

    Icon {
        id: icon
    }

    function updateEntries() {
        if (db.isInit()){
            var date = new Date()
            list.model = db.getEntries(entryViewCount)
            month.text = Qt.locale().monthName(date.getMonth(), Locale.LongFormat) + ":  "
            week.text = qsTr("Woche") + " " + getWeek(date) + ":  "
            var start = new Date(date);
            start.setDate(start.getDate() - start.getDay() + 1)
            var end = new Date(start)
            end.setDate(end.getDate() + 6)
            week.text += db.getSum(start, end) + " €"
            start = new Date(date)
            start.setDate(1)
            end = new Date(date)
            end.setMonth(end.getMonth() + 1)
            end.setDate(0)
            month.text += db.getSum(start, end) + " €"
            entryCount = db.getEntryCount()
        }
    }

    Pane {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        padding: 0
        z:1

        Material.elevation: 4

        background: Rectangle {
            anchors.fill: parent
            color: Material.primary

            layer.enabled: bar.enabled && bar.Material.elevation > 0
            layer.effect: ElevationEffect {
                elevation: bar.Material.elevation
            }
        }

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
            text: icon.icons.dots_vertical
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
            font.pointSize: 20
            font.weight: Font.Medium
            color: "white"
        }

        Menu {
            id: menu
            parent: page_main
            margins: 16
            x: bt_menu.x
            y: bt_menu.y

            MenuItem {
                text: qsTr("Einstellungen")
                onTriggered: {
                    view_stack.push(page_settings)
                }
            }

            MenuItem {
                text: qsTr("Neuerungen")
                onTriggered: {
                    changelog.open()
                }
            }

            MenuItem {
                text: qsTr("Über")
                onTriggered: about.open()

                Dialog {
                    id: about
                    parent: page_main
                    margins: 40
                    width: page_main.width - 2*margins
                    title: qsTr("Über")
                    standardButtons: DialogButtonBox.Ok

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20

                        GridLayout {
                            columns: 2

                            Label{text: qsTr("Version") + ": "}
                            Label{text: Qt.application.version}

                            Label{text: qsTr("Author") + ": "}
                            Label{text: "Paul Götzinger"}

                            Label{text: qsTr("Kontakt") + ": "}
                            Label{text: "<a href=\"mailto:paul70079@gmail.com\">paul70079@gmail.com</a>"; onLinkActivated: Qt.openUrlExternally(link)}
                        }

                        ColumnLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Lizenz")
                                font.pointSize: 16
                            }
                            ScrollView {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                clip: true
                                contentWidth: width
                                ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff

                                Column {
                                    width: parent.width

                                    Text {
                                        id: gplLicense
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        font.pointSize: 12
                                        wrapMode: Text.WordWrap
                                        onLinkActivated: Qt.openUrlExternally(link)

                                        text:  "<p>WTFIsMyMoney is free software: you can redistribute it and/or modify " +
                                               "it under the terms of the GNU General Public License as published by " +
                                               "the Free Software Foundation, either version 3 of the License, or " +
                                               "(at your option) any later version. </p>" +
                                               "<br></br>" +
                                               "<p>WTFIsMyMoney is distributed in the hope that it will be useful, " +
                                               "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
                                               "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
                                               "GNU General Public License for more details.</p>" +
                                               "<a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>"
                                    }

                                    Text {
                                        id: thirdParty
                                        topPadding: 20
                                        font.pointSize: 14
                                        text: "3rd party librarys:"
                                    }
                                    Text {
                                        id: qtLicense
                                        font.pointSize: 12
                                        onLinkActivated: Qt.openUrlExternally(link)
                                        wrapMode: Text.WordWrap
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        text: "Qt is licensed under the <a href=\"https://www.gnu.org/licenses/lgpl-3.0\">LGPL 3.0</a> (<a href=\"https://www.qt.io/\">qt.io</a>)"
                                    }
                                    Text {
                                        id: materialIconLicense
                                        font.pointSize: 12
                                        onLinkActivated: Qt.openUrlExternally(link)
                                        wrapMode: Text.WordWrap
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        text: "Material Design Icons is licensed under the <a href=\"http://scripts.sil.org/OFL\">SIL Open Font License 1.1</a> (<a href=\"https://materialdesignicons.com/\">materialdesignicons.com</a>)"
                                    }
                                }
                            }

                        }

                        Image {
                            source: Qt.resolvedUrl(qsTr("paypal_donate_de.gif"))

                            AbstractButton {
                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7ZDGNW99QTKJC")
                            }
                        }
                    }

                    footer: DialogButtonBox {
                        alignment: Qt.AlignHCenter
                        visible: true
                    }
                }
            }
        }
    }

    Pane {
        id: mainPane
        anchors.left: parent.left
        anchors.top: bar.bottom
        anchors.right: parent.right
        anchors.bottom: bottomBar.top
        padding: 0

        GridLayout {
            id: grid
            columns: 2
            columnSpacing: 20
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 5

            Label {id: month; font.pointSize: 16}
            Label {id: week; font.pointSize: 16}
        }

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: anchors.margins + grid.height
            spacing: 0
            clip: true

            delegate: MouseArea {
                width: list.width
                height: 72

                Text {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 16
                    height: parent.height - 2 * anchors.margins
                    width: height
                    text: icon.icons[modelData.icon]
                    fontSizeMode: Text.Fit
                    font.family: icon.family
                    color: Material.accent
                    font.pointSize: 100
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 72
                    anchors.rightMargin: 16
                    spacing: 0

                    function getTagString(tags) {
                        var tagString = "";
                        for (var i in tags) {
                            tagString = tagString + tags[i].name + ", ";
                        }
                        return tagString
                    }

                    Text {
                        text: (new String(modelData.money)).replace(".", Qt.locale().decimalPoint) + " €"
                        font.pointSize: 16
                        Layout.alignment: Qt.AlignBottom
                    }

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: qsTranslate("TranslationContext", modelData.category) + ": " + parent.getTagString(modelData.tags)
                        font.pointSize: 16
                        Layout.alignment: Qt.AlignTop
                        color: Material.color(Material.Grey, Material.Shade500)
                    }

                }

                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 16
                    text: Qt.locale().monthName(modelData.datestamp.getMonth(), Locale.ShortFormat) + " " + modelData.datestamp.getDate() + ", " + modelData.datestamp.getFullYear()
                    font.pointSize: 16
                    color: Material.color(Material.Grey, Material.Shade500)
                }

                onPressAndHold: {
                    contextMenu.model = modelData
                    contextMenu.x = x + mouse.x - contextMenu.width / 2
                    contextMenu.y = y + mouse.y - list.contentY + list.y - 30
                    contextMenu.open()
                }
            }
            footer: Button {
                text: qsTr("lade weitere")
                width: list.width
                height: 72
                flat: true
                visible: entryCount > list.count
                onClicked: {
                    var tmpIndex = list.count
                    page_main.entryViewCount = page_main.entryViewCount + 20
                    updateEntries();
                    list.positionViewAtIndex(tmpIndex, ListView.End)
                }
            }

            Popup {
                id: contextMenu
                parent: page_main

                property var model;
                padding: 0
                leftPadding: 10
                rightPadding: 10
                margins: 16

                RowLayout {

                    Button {
                        id: editEntry
                        text: qsTr("Bearbeiten")
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
                        text: qsTr("Löschen")
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
                            title: qsTr("Löschen bestätigen")
                            parent: page_main
                            x: (page_main.width - width) /2
                            y: (page_main.height - height) /2
                            standardButtons: Dialog.Ok | Dialog.Cancel

                            onAccepted: {
                                db.deleteEntry(contextMenu.model.nr)
                                updateEntries()
                            }
                        }
                    }
                }
            }
        }
    }

    RoundButton {
        id: addButton
        z: 8
        width: 56
        height: width
        radius: width /2
        anchors.right: parent.right
        anchors.verticalCenter: bottomBar.top
        anchors.margins: 16
        font.family: icon.family
        text: icon.icons.plus
        font.pointSize: 100
        Material.elevation: 12

        onClicked: {
            var item = view_stack.push(page_new)
            item.reset()
            focus = false
        }

        contentItem: Text {
            z: 1
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

            layer.enabled: addButton.enabled && addButton.Material.elevation > 0
            layer.effect: ElevationEffect {
                elevation: addButton.Material.elevation
            }
        }
    }

    Pane {
        id: bottomBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 56
        z: 4
        padding: 0
        Material.elevation: 8

        Button {
            anchors.fill: parent
            text: qsTr("Statistik")
            Material.elevation: 300


            background: Rectangle {
                anchors.fill: parent
                color: Material.primary
                layer.enabled: parent.enabled && parent.Material.elevation > 0
                layer.effect: ElevationEffect {
                    elevation: parent.Material.elevation
                }
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
            }
        }
    }


    Dialog {
        id: mChangelog
        parent: page_main
        margins: 40
        width: parent.width - 2*margins
        title: qsTr("Neuerungen")
        standardButtons: DialogButtonBox.Ok

        ScrollView {
            anchors.fill: parent
            clip: true
            contentWidth: width
            ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff

            Column {
                width: parent.width

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    font.pointSize: 12
                    text: qsTr(
                                "<h1>1.2</h1>" +
                                "<h2>Neue Funktionen</h2>" +
                                "<ul>" +
                                    "<li>Datum und Kosten kann von QR-Codes auf Österreichischen Belegen gelesen werden</li>" +
                                    "<li>Neuerungen werden in einem Pop-Up angezeigt</li>" +
                                    "<li>Neuerungen werden automatisch nach einem Update angezeigt</li>" +
                                "</ul>" +
                                "<h2>Fehlerbehebungen</h2>" +
                                "<ul><li>Wenn bei einem Eintrag das Datum vom vorgeschlagenem Datum geändert wird, wurde der vorige Tag gespeichert</li></ul>" +
                                "<h2>Bekannte Fehler</h2>" +
                                "<ul><li>Import von einer anderen Sprache funktioniert nicht</li></ul>" +
                                "<h1>1.1</h1>" +
                                "<h2>Neue Funktionen</h2>" +
                                "<ul>" +
                                    "<li>Übersetzungen werden unterstützt</li>" +
                                    "<li>Englische Übersetzung wurde hinzugefügt</li>" +
                                "</ul>" +
                                "<h2>Fehlerbehebungen</h2>" +
                                "<ul>" +
                                    "<li>Filter in der Icon suche beim hinzufügen einer neuen Unterkategorie funktioniert auch mit Großbuchstaben</li>" +
                                    "<li>Groß-Kleinschreibung von Dateinamen wurde korrigiert</li>" +
                                "</ul>" +
                                "<h2>Bekannte Fehler</h2>" +
                                "<ul><li>Import von einer anderen Sprache funktioniert nicht</li></ul>"
                               )
                }
            }
        }

        footer: DialogButtonBox {
            alignment: Qt.AlignHCenter
            visible: true
        }
    }

}
