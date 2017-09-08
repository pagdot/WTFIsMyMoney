/* FileSave.qml -- FileSave wrapper
 * Opens a file save dialog, opens the chosen file and saves the content to the file
 * on android
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
import AndroidFile 1.0

Item {
    id: control
    property string title: "Speichern unter"
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: []
    property string selectedNameFilter : ""
    property bool sidebarVisible : true
    property string content: ""
    property string mime: "text/csv"

    signal accepted()
    signal rejected()

    function open() {
        androidCreateDialog.fileCreateDialog()
    }
    function close() {
    }

    AndroidFile {
        id: androidCreateDialog
        mime: control.mime

        function create() {
            fileCreate();
        }
        onCreated: {
            if (!fileUri) {
                rejected()
                return
            }
            fileCreate(fileUri, control.content);
            accepted()
        }
    }
}
