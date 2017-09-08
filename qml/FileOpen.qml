/* FileOpen.qml -- FileOpen wrapper
 * Opens a file open dialog, opens the chosen file and reads the content
 *
 * Copyright (C) 2017 Paul Goetzinger
 * All Rights Reserved.
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
import QtQuick.Dialogs 1.0
import FileIO 1.0

Item {
    id: control
    property string title: "Öffnen"
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: ["*.csv"]
    property string selectedNameFilter : ""
    property bool sidebarVisible : true
    property bool selectMultiple: false
    property bool selectFolder: false
    property string content: ""
    property string mime: "*/*"

    signal accepted()
    signal rejected()

    function open() {
        winOpenDialog.open()
    }
    function close() {
        winOpenDialog.close()
    }

    FileDialog {
        id: winOpenDialog
        title: control.title
        selectExisting: true
        nameFilters: control.nameFilters
        selectedNameFilter: control.selectedNameFilter
        sidebarVisible: control.sidebarVisible
        visible: control.visible
        selectMultiple: control.selectMultiple
        selectFolder: control.selectFolder
        onSelectedNameFilterChanged: control.selectedNameFilter = selectedNameFilter

        onAccepted: {
            control.folder = folder
            control.fileUrl = fileUrl
            control.content = file.read(fileUrl)
            control.accepted()
        }
        onRejected: control.rejected()
    }

    FileIO {
        id: file
        onError: console.log("FileIO error: " + msg)
    }
}
