/* FileSave.qml -- FileSave wrapper
 * Opens a file save dialog, opens the chosen file and saves the content to the file
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
import QtQuick.Dialogs 1.0
import FileIO 1.0

Item {
    id: control
    property string title: qsTr("Speichern unter")
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: ["*.csv"]
    property string selectedNameFilter : ""
    property bool sidebarVisible : true
    property string content: ""
    property string mime: "*/*"

    signal accepted()
    signal rejected()

    function open() {
        winSaveDialog.open()
    }
    function close() {
        winSaveDialog.close()
    }

    FileDialog {
        id: winSaveDialog
        title: control.title
        selectExisting: false
        selectMultiple: false
        selectFolder: false
        nameFilters: control.nameFilters
        selectedNameFilter: control.selectedNameFilter
        sidebarVisible: control.sidebarVisible
        visible: control.visible

        onSelectedNameFilterChanged: control.selectedNameFilter = selectedNameFilter

        onAccepted: {
            control.folder = folder
            control.fileUrl = fileUrl;
            file.write(fileUrl, content)
            control.accepted()
        }
        onRejected: control.rejected()
    }

    FileIO {
        id: file
        onError: console.log("FileIO error: " + msg)
    }
}
