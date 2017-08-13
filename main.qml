import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Studenten Finanz - " + view_stack.currentItem.title

    header: Label {
            text: view_stack.currentItem.title
            horizontalAlignment: Text.AlignHCenter
    }

    StackView {
        id: view_stack
        anchors.fill: parent
        initialItem: page_main

    }

    Component {
        id: page_main
        Page {
            Button {
                id: bt_new
                anchors.centerIn: parent
                text: "New entry"
                onClicked: {
                    var item = view_stack.push("Page_new.qml")
                    item.reset()
                }
            }

            DatePicker{}
        }
    }

    onClosing: {
        if (Qt.platform.os == "android") {
            if (view_stack.depth <= 1) {
                close.accepted = true
            } else {
                view_stack.currentItem.cancel()
                close.accepted = false
            }
        }
    }
}
