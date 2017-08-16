var localStorage;

var defaultCategories = [
    {
        name: "Essen & Trinken",
        sub: ["Essen (eigenes)", "Essen (extern)", "Trinken (eigenes)", "Trinken (extern)"],
    },
    {
        name: "Leben & Wohnen",
        sub: ["Wohnen", "Gewand", "Freizeit"],
    },
    {
        name: "Transport",
        sub: ["Öffentlich", "Auto"],
    },
    {
        name: "Anderes",
        sub: [],
    }
]

function getDB() {
    if (!localStorage) {
        return false;
    }

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

function getCategories() {
    var categories = []
    var rows = sql("SELECT * FROM categories");
    for (var i in rows) {
        categories.push(rows[i].name)
    }
    return categories;
}

function getSubcategoriesOrderedPerUse(category) {
    var rows = sql("SELECT COUNT(E.category) AS cnt, S.name\n"
                 + "FROM entries E INNER JOIN (\n"
                 +     "SELECT COUNT(*) AS cnt FROM entries\n"
                 + ") cnt ON E.nr > (cnt.cnt - 20) INNER JOIN (\n"
                 +     "SELECT S.nr FROM subcategories S, categories C\n"
                 +     "WHERE (S.catNr = C.nr) AND (C.name = ?)\n"
                 + ") Sub ON E.category = Sub.nr, subcategories S\n"
                 + "WHERE E.category = S.nr\n"
                 + "GROUP BY category ORDER BY cnt DESC", [category]);
    console.log(JSON.stringify(rows))
}

function getSubcategories(category) {
    var subcategories = [];
    var rows = sql("SELECT S.* FROM subcategories S\n"
                 + "INNER JOIN categories C ON\n"
                 + "(S.catNr = C.nr) AND (C.name = ?)", category)
    //console.log(JSON.stringify(rows))
    for (var i in rows) {
        subcategories.push(rows[i].name)
    }
    return subcategories
}

function getEntries(count) {
    var rows;
    if (count) {
        rows = sql( "SELECT C.name AS category, S.name AS subcategory, datestamp, money, notes\n" +
                    "FROM entries, categories C, subcategories S\n" +
                    "WHERE (category = S.nr) AND (S.catNr = C.nr)\n" +
                    "ORDER BY datestamp DESC\n" +
                    "LIMIT 10")
    } else {
        rows = sql( "SELECT C.name AS category, S.name AS subcategory, datestamp, money, notes\n" +
                    "FROM entries, categories C, subcategories S\n" +
                    "WHERE (category = S.nr) AND (S.catNr = C.nr)\n" +
                    "ORDER BY datestamp DESC")
    }
    for (var i in rows) {
        rows[i].datestamp = new Date(rows[i].datestamp)
        rows[i].money = rows[i].money / 100
    }

    return rows;
}

function storeEntry(main, sub, date, money, note) {
    var cats = getCategories()
    var found = false;
    for (var i in cats) {
        if (cats[i] === main) {
            found = true
        }
    }
    if (!found) {
        console.log("Unknown category \"" +  main + "\"")
        return false
    }

    cats = getSubcategories(main)
    found = false
    for (var i in cats) {
        if(cats[i] === sub) {
            found = true
        }
    }
    if (!found) {
        var ret = addSubcategory(sub, main)
        if (ret === false) {
            return false
        }
    }

    var ret = sql("INSERT INTO entries (category, datestamp, money, notes)\n"
      + "SELECT S.nr, ?, ?, ? FROM (\n"
      +     "SELECT S.nr FROM subcategories S \n"
      +     "INNER JOIN categories C ON (S.catNr = C.nr) AND (C.name = ?) WHERE S.name = ?\n"
      + ") S;", [dateToISOString(date), parseInt(money * 100), note, main, sub]);
    return ret === false ? false : true;
}

function addSubcategory(name, category) {
    sql("INSERT INTO subcategories (name, catNr) SELECT ?, nr FROM categories WHERE name = ?;", [name, category]);
}


function createCategories() {
    sql("CREATE TABLE categories (nr INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL);");
    for (var c in defaultCategories) {
        sql("INSERT INTO categories (name) VALUES (?)", [defaultCategories[c].name])
    }
}

function createSubcategories() {
    sql("CREATE TABLE subcategories (nr INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, catNr INT NOT NULL);");
    for (var c in defaultCategories) {
        for (var s in defaultCategories[c].sub) {
            addSubcategory(defaultCategories[c].sub[s], defaultCategories[c].name);
        }
    }
}

function createEntryTable() {
    sql("CREATE TABLE entries (nr INTEGER PRIMARY KEY AUTOINCREMENT, category INT NOT NULL, datestamp DATE NOT NULL, money INT, notes TEXT, lastChanged TIMESTAMP DEFAULT CURRENT_TIMESTAMP);");
}

function reset() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("DROP TABLE categories;");
            tx.executeSql("DROP TABLE subcategories;");
            tx.executeSql("DROP TABLE entries;");
        });
    } catch(err) {
        console.log("Error: Could not delete tables: " + err)
    }
    init(localStorage)
}

function pad(number) {
    if (number < 10) {
        return '0' + number;
    }
    return number;
}

function sql(query, parameter) {
    if (!parameter) {
        parameter = []
    }

    var db = getDB();
    var rows = [];
    try {
        db.transaction(function(tx) {
            var result = tx.executeSql(query, parameter)
            for (var i = 0; i < result.rows.length; i++) {
                rows.push(result.rows.item(i))
            }
        })
    } catch(err) {
        console.log("ERROR: Could not execute: \"" + query + "\" with parameter: " + JSON.stringify(parameter));
        console.log("  " + err)
        return false
    }
    //console.log("Query: " + query)
    //console.log("Rows: " + JSON.stringify(rows))
    return rows;
}

function dateToISOString(date) {
    return date.getUTCFullYear() +
        '-' + pad(date.getUTCMonth() + 1) +
        '-' + pad(date.getUTCDate())
};

