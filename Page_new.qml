import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0

Page {
    title: view_new_swipe.currentItem ? view_new_swipe.currentItem.title : ""
    objectName: "create_new"

    property var defaultMainCategories: [
        "Essen & Trinken",
        "Leben & Wohnen",
        "Transport",
        "Anderes"
    ]

    property var categories: ({})
    property var main_category: ""
    property var sub_category: ""

    function reset() {
        view_new_swipe.setCurrentIndex(0)
        main_category = ""
        sub_category = ""
        view_new_swipe.removeItem(2)
        view_new_swipe.removeItem(1)
        dbInit()
    }

    function cancel() {
        view_stack.pop()
    }

    function getDB() {
        try {
            var db = LocalStorage.openDatabaseSync("financeData", "", "", 4096);
        } catch (err) {
            console.log("Error opening database: " + err)
        };
        return db;
    }

    function dbInit() {
        var db = getDB();
        try {
            db.transaction(function (tx) {
                tx.executeSql('CREATE TEMP TABLE IF NOT EXISTS tmp_categories (category TEXT,subcategory TEXT)');

                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[0], "Essen (eigenes)"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[0], "Essen (extern)"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[0], "Trinken (eigenes)"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[0], "Trinken (extern)"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[1], "Wohnen"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[1], "Gewand"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[2], "Öffentlich"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[2], "Auto"]);
                tx.executeSql('INSERT INTO tmp_categories (category, subcategory) VALUES (?,?)', [defaultMainCategories[3], "Test123"]);

                tx.executeSql('CREATE TABLE IF NOT EXISTS categories AS SELECT * FROM tmp_categories');
            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
            return;
        };
        try {
            db.transaction(function (tx) {
                var results = tx.executeSql('SELECT * FROM categories');
                categories = {};
                for (var i = 0; i < results.rows.length; i++) {
                    if (!(results.rows.item(i).category in categories)) {
                        categories[results.rows.item(i).category] = [];
                    }
                    categories[results.rows.item(i).category].push(results.rows.item(i).subcategory);
                }
            });
        } catch (err) {
            console.log("Error reading table in database: " + err);
            return;
        };
    }

    SwipeView {
        id: view_new_swipe
        anchors.fill: parent
        anchors.bottom: pageIndicator_new.top
        currentIndex: 1

        function next() {
            if (currentIndex == 0) {
                if (view_new_swipe.count == 1) {
                    view_new_swipe.addItem(page_sub)
                }

                var tmp = []
                for (var i = 0; i < categories[main_category].length; i++) {
                    tmp.push(categories[main_category][i]);
                }
                page_sub.model = tmp;
            } else if (currentIndex == 1) {
                if (view_new_swipe.count == 2) {
                    view_new_swipe.addItem(page_content)
                }
            }

            view_new_swipe.incrementCurrentIndex()
        }

        Page_new_main {
            onChosen: {
                main_category = text
                view_new_swipe.next()
            }
        }
        Page_new_sub {
            id: page_sub
            onChosen: {
                sub_category = text
                view_new_swipe.next()
            }
        }
        Page_new_content {
            id: page_content
        }

    }
    PageIndicator {
        id: pageIndicator_new
        count: view_new_swipe.count
        currentIndex: view_new_swipe.currentIndex
        anchors.bottom: button_new_cancel.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Button {
        id: button_new_cancel
        text: "Abbrechen"
        anchors.bottom: parent.bottom
        width: parent.width
        onClicked: cancel()
    }
}
