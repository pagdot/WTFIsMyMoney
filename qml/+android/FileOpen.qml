import QtQuick 2.7
import AndroidFile 1.0

Item {
    id: control
    property string title: "Öffnen"
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: []
    property string selectedNameFilter : ""
    property bool sidebarVisible : true
    property bool selectMultiple: false
    property bool selectFolder: false
    property string content: ""
    property string mime: "text/csv"

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
            if (!fileUri) {
                rejected()
                return
            }

            control.content = fileOpen(fileUri);
            accepted()
        }
    }
}
