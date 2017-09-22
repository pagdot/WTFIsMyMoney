/* FileOpen.qml -- FileOpen wrapper
 * Opens a file open dialog, opens the chosen file and reads the content
 * on android.
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
 */import QtQuick 2.7
import AndroidFile 1.0

Item {
    id: control
    property string title: qsTr("Öffnen")
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: []
    property string selectedNameFilter : ""
    property bool sidebarVisible : true
    property bool selectMultiple: false
    property bool selectFolder: false
    property string content: ""
    property string mime: "*/*"

    signal accepted()
    signal rejected()

    function open() {
        androidOpenDialog.fileOpenDialog()
    }

    function close() {

    }

    AndroidFile {
        id: androidOpenDialog
        mime: control.mime

        function open() {
            fileOpen();
        }
        onOpened: {
            if ((!fileUri) || (fileUri === "")) {
                rejected()
                return
            }

            control.content = fileOpen(fileUri);
            accepted()
        }
    }
}
