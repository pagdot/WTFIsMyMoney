/* Page_settings.qml -- Settings page
 * Provides import and export of data and removing all data
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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Page {

    property var db;

    function createCSV(data) {
        var csv = "date,money,category,notes,tags\r\n";
        for (var i in data) {
            var tags = [];
            for (var j in data[i].tags) {
                tags.push((data[i].tags[j].category === "" ? "g" : "l") + data[i].tags[j].name.replace("\"", "").replace(",", ""))
            }

            csv += db.dateToISOString(data[i].datestamp) + "," + data[i].money + "," +
                   data[i].category + "," + data[i].notes + "," +
                   '"' + tags.join(",") + '"' + "\r\n"
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

            var line = [];
            var start = 0;
            var pos = 0;
            var state = false;

            if (i === "0") {
                cols = lines[i].split(",");
            } else {
                for (pos = 0; pos < lines[i].length; pos++) {
                    if ((lines[i].charAt(pos) === ",") && (state === false)) {
                        if (start !== pos) {
                            line.push(lines[i].slice(start, pos));
                            start = pos+1;
                        } else {
                            line.push("");
                            start=pos+1;
                        }
                    } else if (lines[i].charAt(pos) === "\"") {
                        state = !state;
                    }
                }
                if (start !== pos) {
                    line.push(lines[i].slice(start, pos));
                    start = pos+1;
                } else {
                    line.push("");
                    start=pos+1;
                }

                var entry = {}
                for (var j in line) {
                    entry[cols[j]] = line[j]
                }
                if (entry.date) entry.date = new Date(entry.date);
                if (entry.tags) {
                    var tmp = entry.tags.replace(/\"/g, "")
                    if (tmp !== "") {
                        entry.tags = tmp.split(",");
                    } else {
                        entry.tags = [];
                    }
                }
                if (entry.subcategory) {
                    entry.tags = ["l" + entry.subcategory]
                    switch (entry.category) {
                    case qsTranslate("OldTranslationContext", "food & drinks"):
                        entry.category = "food_drinks";
                        break;
                    case qsTranslate("OldTranslationContext", "life & live"):
                        entry.category = "life_home";
                        break;
                    case qsTranslate("OldTranslationContext", "spare time"):
                        entry.category = "hobbies";
                        break;
                    case qsTranslate("OldTranslationContext", "transport"):
                        entry.category = "transport";
                        break;
                    case qsTranslate("OldTranslationContext", "other"):
                        entry.category = "other";
                        break;
                    default:
                        console.log("Can't find category \"" + entry.category + "\"")
                    }
                };
                data.push(entry);
            }
        }
        return data;
    }

    function cancel() {
        view_stack.pop()
    }

    Icon {
        id: icon
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        AbstractButton {
            id: buttonBack
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 16
            implicitWidth: height

            Text {
                anchors.fill: parent
                font.family: icon.family
                text: icon.icons.arrow_left
                color: "white"
                font.pointSize: 32
                fontSizeMode: Text.VerticalFit
            }

            onClicked: cancel()
        }

        Text {
            text: qsTr("Einstellungen")
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
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        ColumnLayout {
            Label {
                text: qsTr("Daten") + ":"
            }

            Button {
                text: qsTr("Importieren")
                onClicked: {
                    fileOpen.open();
                }

                FileOpen {
                    id: fileOpen
                    visible: false

                    onAccepted: {
                        var data = parseCSV(fileOpen.content)
                        db.importEntries(data)
                    }
                }
            }

            Button {
                text: qsTr("Exportieren")
                onClicked: {
                    fileSave.content = createCSV(db.getEntries());
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
                text: qsTr("Daten löschen")
                onClicked: deleteDialog.open()

                Dialog {
                    id: deleteDialog
                    title: qsTr("Löschen bestätigen")
                    parent: page_settings
                    x: (page_main.width - width) /2
                    y: (page_main.height - height) /2
                    standardButtons: Dialog.Ok | Dialog.Cancel

                    onAccepted: {
                        db.clearDb()
                    }
                }
            }
        }
    }
}
