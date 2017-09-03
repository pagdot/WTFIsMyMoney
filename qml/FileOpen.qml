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
