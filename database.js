var localStorage;

function getDB() {
    try {
        var db = localStorage.openDatabaseSync("financeData", "", "", 4096);
    } catch (err) {
        console.log("Error opening database: " + err)
    };
    return db;
}

function init(_localStorage) {
    localStorage = _localStorage;
    var db = getDB();


    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM categories');
        })
    } catch(err) {
        createCategories();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM subcategories');
        })
    } catch(err) {
        createSubcategories();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM entries');
        })
    } catch(err) {
        createEntryTable();
    }
}

function storeEntry(main, sub, date, money, note) {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("INSERT INTO entries (category, date, money, notes)
                SELECT S.nr, ?, ?, ?
                FROM (
                    SELECT S.nr FROM subcategories S
                    INNER JOIN categories C ON (S.catNr = C.nr) AND (C.name = ?)
                    WHERE S.name = ?
            ) S;", date, money, note, main, sub);
        });
    } catch (err) {
        console.log("Error: Could not create subcategory table: " + err)
    }
}


function createCategories() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE categories (
                nr INT AUTO_INCREMENT PRIMARY KEY,
                name TEXT NOT NULL
            );");
            //load categories
        });
    } catch (err) {
        console.log("Error: Could not create category table: " + err)
    }
}

function createSubcategories() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("nr, name, catIndex
                CREATE TABLE subcategories (
                nr INT AUTO_INCREMENT PRIMARY KEY,
                name TEXT NOT NULL,
                catNr INT NOT NULL
            );");
            //load subcategories
        });
    } catch (err) {
        console.log("Error: Could not create subcategory table: " + err)
    }
}

function createEntryTable() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("index, date, subcat, money, note, change
                CREATE TABLE entries (
                nr INT AUTO_INCREMENT PRIMARY KEY,
                category INT NOT NULL,
                date DATE NOT NULL,
                money INT,
                change TIMESTAMP
            );");
        });
    } catch (err) {
        console.log("Error: Could not create entry table: " + err)
    }

}
