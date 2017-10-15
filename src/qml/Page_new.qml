/* Page_new.qml -- New Entry page
 * Page to add new entries into the storage
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
import QtQuick.Controls.Material.impl 2.2

Page {
    title: qsTr("Neu")
    id: page
    objectName: "create_new"

    property var db;

    property var categories: []
    property var main_category: categories[mainCombo.currentIndex];
    property bool newEntry: true
    property date datum;
    property real money;
    property int nr;
    property var tags: []
    property var availableTags: []
    property bool globalTags: true
    property bool localTags: true

    function reset() {
        var tmp_categories = []
        tags = []
        availableTags = ["abc", "def", "ghi", "jkl"];
        var tmp = db.getCategories();
        for (var i in tmp) {
            tmp_categories.push({
                name: tmp[i].name,
                icon: tmp[i].icon,
                sub: db.getSubcategoriesOrderedPerUse(tmp[i].name)
            });
        }
        money = 0.0
        categories = tmp_categories
        newEntry = true;
        datum = new Date()
    }

    function load(item) {
        if (!item) {
            return
        }

        var tmp_categories = []
        var tmp = db.getCategories();
        for (var i in tmp) {
            tmp_categories.push({
                name: tmp[i].name,
                icon: tmp[i].icon,
                sub: db.getSubcategoriesOrderedPerUse(tmp[i].name)
            });
        }

        for (var i in categories) {
            if (item.category === categories[i].name) {
                main_category = categories[i]
                break
            }
        }

//        for (var i in main_category.sub) {
//            if (item.subcategory === main_category.sub[i].name) {
//                sub_category = main_category.sub[i]
//                break
//            }
//        }

        money = item.money
        datum = item.datestamp
        categories =  tmp_categories

        nr = item.nr
        newEntry = false
    }

    function cancel() {
        if (loader.status != Loader.Null) {
            loader.close()
        } else if (datePicker.visible) {
            datePicker.close()
        } else {
            dialog.open()
        }
    }

    function generateModel(size) {
        var tmp = []
        for (var i = 0; i < size; i++) {
            tmp.push(i)
        }
        return tmp
    }

    Icon {
        id: icon
    }

    Pane {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        padding: 0
        Material.elevation: 4
        z:1

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

            onClicked: dialog.open()
        }

        Text {
            text: page.title
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        background: Rectangle {
            anchors.fill: parent
            color: Material.primary

            layer.enabled: bar.enabled && bar.Material.elevation > 0
            layer.effect: ElevationEffect {
                elevation: bar.Material.elevation
            }
        }
    }

    ColumnLayout {
        anchors.top: bar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 20

        ColumnLayout {
            id: moneyLayout
            Layout.fillWidth: true

            Label {
                id: moneyLabel
                text: qsTr("Geld") + ":"
            }

            Item {
                Layout.fillWidth: true
//                Layout.fillHeight: true
                implicitHeight: dial.implicitHeight
                onWidthChanged: console.log("w: " + width)
                onImplicitHeightChanged: console.log("ih: " + implicitHeight)
                onHeightChanged: console.log("h: " + parent.height)

                Component.onCompleted: {
                    console.log("w: " + width)
                    console.log("ih: " + implicitHeight)
                    console.log("h: " + parent.height)
                }

                Dial {
                    id: dial
                    from: 0
                    to: 30
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 0
                    value: money
                    snapMode: Dial.SnapAlways
                    stepSize: 0.5
                    implicitHeight: parent.width - moneyInput.width - Math.max(bt_plus.width, bt_minus.width)

                    onValueChanged: {
                        if (pressed) {
                            money = value
                        }
                    }
                }

                Button {
                    anchors.centerIn: dial
                    flat: true
                    width: dial.width/2
                    height: dial.height/2
                    visible: Qt.platform.os === "android"

                    text: icon.icons["qrcode"]
                    font.family: icon.family
                    font.pointSize: 200
                    padding: 0

                    contentItem: Text {
                        anchors.margins: 0
                        anchors.fill: parent
                        text: parent.text
                        font: parent.font
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    onClicked: {
                        loader.sourceComponent= qr
                    }

                    background: Rectangle {
                        visible: false
                    }
                    Loader {
                        id: loader
                        parent: page

                        anchors.fill: parent

                        function close() {
                            sourceComponent = undefined
                        }

                        Component {
                            id: qr
                            Page_qr {
                                anchors.fill: parent

                                onCancel: loader.close()
                                onError: {
                                    console.log("Invalid tag")
                                    loader.close()
                                }
                                onComplete: {
                                    page.money = money
                                    page.datum = new Date(date)
                                    loader.close()
                                }
                            }
                        }
                    }

                }

                TextField {
                    id: moneyInput
                    focus: false
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: 60
                    text: focus ? money.toFixed(2).replace('.', Qt.locale().decimalPoint) : money.toFixed(2).replace('.', Qt.locale().decimalPoint) + " €"
                    validator: RegExpValidator{ regExp: /\d*[\.,]{0,2}\d*/}
                    onTextEdited: {
                        var tmp = text.replace(/(\d*)[\.,]*(\d{0,2})\d*/ ,"$1.$2")
                        var val = parseFloat(tmp)
                        var tmpPos = cursorPosition;
                        var oldText = text
                        var beforeFirstDigit = text.search(/[1-9]?/)
                        var beforeFirstSeparatorPos = text.search(/[\.,]/)
                        var beforeLastSeparatorPos = text.length - text.split('').reverse().join('').search(/[\.,]/) -1
                        money = -1
                        if (!isNaN(val)) {
                            money = val
                            var afterSeparatorPos = text.search(/[\.,]/)

                            if (beforeFirstSeparatorPos == -1) {
                                cursorPosition = tmpPos - beforeFirstDigit
                            } else {
                                cursorPosition = afterSeparatorPos +
                                        (tmpPos - (tmpPos <= beforeLastSeparatorPos ? beforeFirstSeparatorPos : beforeLastSeparatorPos))
                            }
                        } else {
                            money = 0.0
                            cursorPosition = 0
                        }
                    }
                    inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                }

                Button {
                    id: bt_plus
                    anchors.top: parent.top
                    anchors.right: parent.right
                    flat: true
                    text: "+5 €"

                    onClicked: money = money + 5
                }

                Button {
                    id: bt_minus
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    flat: true
                    text: "-5 €"

                    onClicked: money = money >= 5 ? money - 5 : 0
                }
            }
        }

        ColumnLayout {
            id: mainLayout
            Layout.fillWidth: true

            property bool opened: false;

            Label {
                id: mainLabel
                text: qsTr("Kategorie") + ":"
            }

            ComboBox {
                id: mainCombo
                model: categories

                displayText: model[currentIndex] ? model[currentIndex].name : ""

                contentItem: Text {
                    leftPadding: 12 + iconLabel.width + 12
                    rightPadding: parent.indicator.width + parent.spacing

                    text: parent.displayText
                    font: parent.font
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    Label {
                        id: iconLabel
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: parent.font.pointSize
                        font.family: icon.family
                        color: "white"
                        text: mainCombo.model[mainCombo.currentIndex] ? icon.icons[mainCombo.model[mainCombo.currentIndex].icon] : ""
                        background: Rectangle{height: parent.height + 5; width: height; radius: height/2; color: Material.accent; anchors.centerIn: parent}
                    }
                }

                delegate: ItemDelegate {
                    id: control
                    Label {
                        id: iconLabel
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: parent.font.pointSize
                        font.family: icon.family
                        color: "white"
                        text: icon.icons[modelData.icon]
                        background: Rectangle{height: parent.height + 5; width: height; radius: height/2; color: Material.accent; anchors.centerIn: parent}
                    }


                    leftPadding: 16 + iconLabel.width + 8
                    rightPadding: 16
                    width: parent.width
                    text: modelData.name
                    font.weight: mainCombo.currentIndex === index ? Font.DemiBold : Font.Normal
                    highlighted: mainCombo.highlightedIndex === index
                    hoverEnabled: mainCombo.hoverEnabled
                }
            }

        }

        ColumnLayout {
            id: tagLayout
            Layout.fillWidth: true
//            Layout.fillHeight: true

            Label {
                id: tagsLabel
                text: qsTr("Tags") + ":"
            }

            AbstractButton {
                Layout.fillWidth: true
                Layout.minimumHeight: 32
                Layout.fillHeight: true
                property alias menu: mTagMenu
                enabled: !mTagMenu.visible

                Flow {
                    id: chosenTagFlow
                    spacing: 10
                    anchors.fill: parent

                    Repeater {
                    id: chosenRepeater
                    model: tags.length

                    delegate: AbstractButton {
                        id: rect
                        implicitHeight: 32

                        background: Rectangle {
                            anchors.fill: parent
                            radius: height/2
                            color: Material.color(Material.Grey, Material.Shade200)
                        }

                        RowLayout {
                            spacing: 4
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 12
                            anchors.rightMargin: 4
                            implicitWidth: chipText.metrics.width + spacing + chipClose.width
                            onImplicitWidthChanged: parent.implicitWidth = anchors.leftMargin + implicitWidth + anchors.rightMargin

                            Text {
                                id: chipText
                                font.family: icon.family
                                color: "black"
                                font.pointSize: 13
                                text: tags[modelData]
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                property alias metrics: mMetrics
                                opacity: 87

                                onFontChanged: if (font != undefined) metrics.font = font

                                FontMetrics {
                                    id: mMetrics
                                    property real width: boundingRect(parent.text).width
                                }
                            }

                            AbstractButton {
                                id: chipClose
                                implicitHeight: 24
                                implicitWidth: 24

                                onClicked: {
                                    var chosen = tags
                                    var available = availableTags

                                    available.push(chosen[modelData])
                                    chosen.splice(modelData, 1)

                                    availableTags = available
                                    tags = tags
                                }

                                contentItem: Text {
                                    font.family: icon.family
                                    fontSizeMode: Text.VerticalFit
                                    text: icon.icons["close_circle"]
                                    verticalAlignment: Text.AlignVCenter
                                    font.pointSize: 100
                                    opacity: 0.54
                                }
                            }
                        }
                    }
                }
                }

                Popup {
                    id: mTagMenu
                    margins: 16
                    y: parent.height

                    onVisibleChanged: {
                        if(visible) {
                            filter.contentItem.focus = true
                            contentItem.forceActiveFocus()
                        }
                    }

                    contentItem: FocusScope {
                        anchors.fill: parent
                        implicitHeight: layout.implicitHeight

                        ColumnLayout {
                            id: layout
                            anchors.fill: parent
                            spacing: list.spacing
                            implicitHeight: filter.implicitHeight + spacing + list.implicitHeight

                            property var filteredTags: filterTags(availableTags, filter.contentItem.text)

                            function filterTags(tags, filter) {
                                var filtered = []
                                for (var i in tags) {
                                    if (tags[i].toLowerCase().indexOf(filter.toLowerCase()) !== -1) {
                                        filtered.push({index: parseInt(i), tag: tags[i]})
                                    }
                                }
                                return filtered
                            }

                            ItemDelegate {
                                id: filter
                                clip: true
                                font.italic: true
                                Layout.fillWidth: true
                                contentItem: TextInput {
                                    text: ""
                                    font: parent.font
                                    inputMethodHints: Qt.ImhNoPredictiveText
                                }
                            }

                            ListView {
                                id: list
                                Layout.fillWidth: true
                                clip: true
                                implicitWidth: Math.max(contentItem.implicitWidth, footerItem.implicitWidth)
                                implicitHeight: contentHeight

                                model: layout.filteredTags.length

                                onCountChanged: {
                                    if ((!count) || (!footerItem)) {
                                        return
                                    }

                                    if ((count == 0) && (footerItem.y != 0)) {
                                        footerPositioning = ListView.OverlayFooter
                                        footerPositioning = ListView.InlineFooter
                                    }
                                }

                                delegate: ItemDelegate {
                                    width: parent.width
                                    text: availableTags[layout.filteredTags[modelData].index]
                                    onClicked: {
                                        var chosen = tags
                                        var available = availableTags

                                        chosen.push(available[layout.filteredTags[modelData].index])
                                        available.splice(layout.filteredTags[modelData].index, 1)

                                        tags = chosen
                                        availableTags = available
                                    }
                                }

                                footer: Item {
                                    implicitHeight: visible ? ((localItem.visible ? localItem.height : 0) + (globalItem.visible ? globalItem.height : 0)) : 0
                                    width: parent.width
                                    implicitWidth: localItem.visible ? (globalItem.visible ? Math.max(localItem.implicitWidth, globalItem.implicitWidth) : localItem.implicitWidth) : globalItem.visible ? globalItem.implicitWidth : 0
                                    visible: (filter.contentItem.text !== "") && (!arrayContains(layout.filteredTags, filter.contentItem.text))  && (!arrayContains(tags, filter.contentItem.text))

                                    function arrayContains(array, element) {
                                        for (var i in array) {
                                            if ((array[i].tag === element) || (array[i] === element)) {
                                                return true
                                            }
                                        }
                                        return false
                                    }

                                    ItemDelegate {
                                        id: localItem
                                        visible: localTags
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top

                                        text: qsTr("Hinzufügen")

                                        onClicked: {
                                            var chosen = tags
                                            chosen.push(filter.contentItem.text)
                                            tags = chosen
                                        }
                                    }

                                    ItemDelegate {
                                        id: globalItem
                                        visible: globalTags
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom

                                        text: localTags ? qsTr("Global Hinzufügen") : qsTr("Hinzufügen")

                                        onClicked: {
                                            var chosen = tags
                                            chosen.push(filter.contentItem.text)
                                            //TODO push to global tag array
                                            tags = chosen
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                onClicked: {
                    menu.open()
                }
            }
        }

        ColumnLayout {
            id: dateLayout

            property bool opened;

            Label {
                id: dateLabel
                text: qsTr("Datum") + ":"
            }

            Button {
                id: dateChip
                implicitHeight: 32

                onClicked: {
                    dateLayout.opened = true
                }

                contentItem: RowLayout {
                    spacing: 0
                    anchors.fill: parent


                    Rectangle {
                        height: parent.height
                        width: height
                        radius: height/2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Material.accent

                        Text {
                            anchors.centerIn: parent
                            font.family: icon.family
                            color: "white"
                            font.pointSize: 13
                            text: icon.icons.calendar
                        }
                    }

                    Text {
                        padding: 8
                        rightPadding: 12
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter

                        text: Qt.locale().monthName(datum.getMonth(), Locale.ShortFormat) + " " + datum.getDate() + ", " + datum.getFullYear()
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: height/2
                    color: Material.color(Material.Grey, Material.Shade200)
                }
            }
            onOpenedChanged: {
                if (opened) {
                    datePicker.open()
                }
            }

            DatePicker{
                id: datePicker
                selectedDate: page.datum
                parent: page
                onClosed: {
                    dateLayout.opened = false
                    page.datum = selectedDate
                }
                x: (page.width - width) / 2
                y: (page.height - height) / 2
            }
        }

        Button {
            id: buttonDone
            text: qsTr("Fertig")
            Layout.alignment: Qt.AlignHCenter
            flat: true

            onClicked: {
                if (newEntry) {
                    db.storeEntry(main_category.name, sub_category.name, datum, money, "", sub_category.icon, {}, [])
                } else {
                    db.updateEntry(nr, main_category.name, sub_category.name, datum, money, "", sub_category.icon, {}, [])
                }
                view_stack.pop()
            }
        }
    }

    Dialog {
        id: dialog
        title: qsTr("Abbrechen")
        parent: page
        standardButtons: Dialog.Ok | Dialog.Cancel
        Material.elevation: 24

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        onAccepted: view_stack.pop()
    }
}
