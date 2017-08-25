import QtQuick 2.7
import QtQuick.Dialogs 1.0

Item {
    id: control
    property string title: "Speichern unter"
    property url folder: ""
    property url fileUrl: ""
    property var nameFilters: []
    property string selectedNameFilter : ""
    property bool sidebarVisible : true

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
            control.accepted()
        }
        onRejected: control.rejected()
    }
}
