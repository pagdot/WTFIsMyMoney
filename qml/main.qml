import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0

import "database.js" as Db

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Studenten Finanz - " + view_stack.currentItem.title

    id: window

    header: Label {
            text: view_stack.currentItem.title
            horizontalAlignment: Text.AlignHCenter
    }

    StackView {
        id: view_stack
        anchors.fill: parent
        initialItem: page_main

        onCurrentItemChanged: {
            if (depth === 1) {
                currentItem.updateEntries()
                currentItem.visible = true
            }
        }

    }

    Page_main{
        id: page_main
    }

    Page_new{
        id: page_new
        visible: false
    }

    Page_chart{
        id: page_chart
        visible: false
    }

    onClosing: {
        if (Qt.platform.os === "android") {
            if (view_stack.depth <= 1) {
                close.accepted = true
            } else {
                view_stack.currentItem.cancel()
                close.accepted = false
            }
        }
    }
}
