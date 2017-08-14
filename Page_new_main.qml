import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Page {
    id: page
    title: "Hauptkategorie"

    signal chosen(string text)

    property var categories: []

    onCategoriesChanged: {
        var model = []
        for (var i in categories) {
            model.push(categories[i].name)
        }
        //repeater.model = model
        //console.log(JSON.stringify(categories))
    }

    function _chosen(text) {
        chosen(text)
    }

    GridLayout {
        rows: 2
        columns: 2
        anchors.centerIn: parent


        Repeater {
            id: repeater
            model: categories.length

            delegate: Button {
                Layout.alignment: (modelData % 2) == 1 ? Qt.AlignLeft : Qt.AlignRight
                text: categories[modelData].name
                onClicked: page._chosen(text)
            }
        }

        /*Button {
            id: bt_1
            text: defaultMainCategories[0]
            anchors.right: parent.horizontalCenter
            onClicked: page._chosen(text)
        }

        Button {
            id: bt_2
            text: defaultMainCategories[1]
            onClicked: page._chosen(text)
        }

        Button {
            id: bt_3
            text: defaultMainCategories[2]
            anchors.right: parent.horizontalCenter
            onClicked: page._chosen(text)
        }

        Button {
            id: bt_4
            text: defaultMainCategories[3]
            onClicked: page._chosen(text)
        }*/
    }
}

