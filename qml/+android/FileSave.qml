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
