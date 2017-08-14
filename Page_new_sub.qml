import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    title: "Unterkategorie"
    property var model: []

    signal chosen(string text)

    function _chosen(text) {
        chosen(text)
    }

    ComboBox {
        id: control

        anchors.centerIn: parent
        editable: true

        model: page.model

        onAccepted: {
            page._chosen(displayText)
            page.model.push(displayText)
        }
        onActivated: page._chosen(displayText)

        baselineOffset: contentItem.baselineOffset + (Qt.platform.os == "android" ? 0.5 : 0)

        contentItem: TextField {
            anchors.fill: parent
            anchors.rightMargin: spacing + control.indicator.width

            text: parent.displayText
            TextMetrics{id: textmetrics; text: control.text ? control.text : ""; font: control.font ? control.font : null}
            width: textmetrics.width + rightPadding

            enabled: control.editable
            readOnly: control.popup.visible
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            opacity: control.focus ? 1 : 0.3

            onFocusChanged: {
                if (focus) {
                    parent.popup.open()
                }
            }

            onTextChanged: {
                textmetrics.text = text
                implicitWidth = textmetrics.width + spacing + control.indicator.width
                control.width = implicitWidth + control.indicator.width
            }
        }

        popup: Popup {
            y: control.height - 1
            width: control.width
            implicitHeight: contentItem.implicitHeight
            padding: 0

            contentItem: ListView {
                id: list
                clip: true
                model: control.popup.visible ? control.delegateModel : null
                implicitHeight: contentHeight
                currentIndex: control.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }
}
