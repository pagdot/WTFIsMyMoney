import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQml 2.2

Item {
    id: control
    property date selectedDate: new Date()

    width: 200
    height: 500
    Column {
        anchors.fill: parent
        Rectangle {
            anchors.top: parent.top
            color: Material.primary
            Column {
                Label {
                    text: selectedDate.getFullYear()
                    color: Material.foreground
                }
                Label {
                    text: selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                }
            }
        }
    }
}
