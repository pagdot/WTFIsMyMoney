/* Database.js -- Database API
 * API to wrap SQL functions in easy to use JS functions
 *
 * Copyright (C) 2017 Paul Goetzinger <paul70079@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0
 * License-Filename: LICENSE/GPL-3.0.txt
 *
 * This file is part of WTFIsMyMoney.
 *
 * WTFIsMyMoney is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * WTFIsMyMoney is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with WTFIsMyMoney.  If not, see <http://www.gnu.org/licenses/>.
 */

var localStorage;

var defaultCategories = [
    {
        name: "Essen & Trinken",
        icon: "silverware",
        sub: [
            {name:"Essen (eigenes)", icon: "food"},
            {name:"Essen (extern)", icon: "store"},
            {name:"Trinken (eigenes)", icon: "store"},
            {name:"Trinken (extern)", icon: "martini"}
        ],
    },
    {
        name: "Leben & Wohnen",
        icon: "home",
        sub: [
            {name:"Wohnen", icon: "home"},
            {name:"Gewand", icon: "tshirt_crew"},
            {name:"Freizeit", icon: "readability"}
        ],
    },
    {
        name: "Transport",
        icon: "car",
        sub: [
            {name:"Öffentlich", icon: "bus"},
            {name:"Auto", icon: "car"}
        ],
    },
    {
        name: "Anderes",
        icon: "plus",
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

function clearDb() {
    sql("DELETE FROM categories")
    sql("DELETE FROM subcategories")
    sql("DELETE FROM entries")

    createCategories()
    createSubcategories()
    createEntryTable()
}

function importEntries(entries) {
    for (var i in entries) {
        storeEntry(entries[i].category, entries[i].subcategory, entries[i].date, entries[i].money, entries[i].note, entries[i].icon, entries[i].extra, entries[i].tags)
    }
}

function getCategories() {
    var categories = []
    var rows = sql("SELECT * FROM categories");
    for (var i in rows) {
        categories.push(rows[i])
    }
    return categories;
}

function getSubcategoriesOrderedPerUse(category) {
    var subcategories = [];
    var rows = sql("SELECT S.*, COUNT(E.nr) as cnt FROM subcategories S, (\n" +
                   "    SELECT * FROM entries\n" +
                   "    ORDER BY nr DESC\n" +
                   "    LIMIT 20\n" +
                   ") E\n" +
                   "INNER JOIN categories C ON\n" +
                   "(S.catNr = C.nr) AND (C.name = ?)\n" +
                   "WHERE E.category = S.nr\n" +
                   "GROUP BY E.category\n" +
                   "ORDER BY cnt DESC", category)
    for (var i in rows) {
        subcategories.push(rows[i])
    }

    rows = sql("SELECT S.* FROM subcategories S\n" +
               "INNER JOIN categories C ON\n" +
               "(S.catNr = C.nr) AND (C.name = ?)", category)
    for (var i in rows) {
        var found = false;
        for (var j in subcategories) {
            if (subcategories[j].name === rows[i].name) {
                found = true
            }
        }
        if (!found) {
            subcategories.push(rows[i])
        }
    }
    return subcategories
}

function getSubcategories(category) {
    var subcategories = [];
    var rows = sql("SELECT S.* FROM subcategories S\n" +
                   "INNER JOIN categories C ON\n" +
                   "(S.catNr = C.nr) AND (C.name = ?)", category)
    for (var i in rows) {
        subcategories.push(rows[i])
    }
    return subcategories
}

function getEntries(count) {
    var rows;
    if (count) {
        rows = sql( "SELECT E.nr, C.name AS category, S.name AS subcategory, E.datestamp, E.money, E.notes, S.icon\n" +
                    "FROM entries E, categories C, subcategories S\n" +
                    "WHERE (E.category = S.nr) AND (S.catNr = C.nr)\n" +
                    "ORDER BY E.datestamp DESC\n" +
                    "LIMIT ?", [count])
    } else {
        rows = sql( "SELECT E.nr, C.name AS category, S.name AS subcategory, E.datestamp, E.money, E.notes, S.icon\n" +
                    "FROM entries E, categories C, subcategories S\n" +
                    "WHERE (E.category = S.nr) AND (S.catNr = C.nr)\n" +
                    "ORDER BY E.datestamp DESC")
    }
    for (var i in rows) {
        rows[i].datestamp = new Date(rows[i].datestamp)
        rows[i].money = rows[i].money / 100
    }

    return rows;
}

function getMoneyPerCategory(start, end) {
    var subcategories = [];
    var rows = sql("SELECT C.icon, C.name, SUM(money) AS money\n" +
                   "FROM entries E, subcategories S, categories C\n" +
                   "WHERE (E.category = S.nr) AND (S.catNr = C.nr)\n" +
                   "    AND (E.datestamp >= ?) AND (E.datestamp <= ?)\n" +
                   "GROUP BY C.name", [dateToISOString(start), dateToISOString(end)])
    for (var i in rows) {
        rows[i].money = rows[i].money / 100
    }
    return rows
}

function getMoneyPerSubcategory(category, start, end) {
    var subcategories = [];
    var rows = sql("SELECT S.name, SUM(money) AS money, S.icon\n" +
                   "FROM entries E, subcategories S, categories C\n" +
                   "WHERE (E.category = S.nr) AND (S.catNr = C.nr) AND (C.name = ?)\n" +
                   "    AND (E.datestamp >= ?) AND (E.datestamp <= ?)\n" +
                   "GROUP BY S.name", [category, dateToISOString(start), dateToISOString(end)])
    for (var i in rows) {
        rows[i].money = rows[i].money / 100
    }
    return rows
}

function getAll() {
    var subcategories = [];
    var rows = sql("SELECT E.datestamp, E.money, S.name AS subcategory, C.name AS category, E.notes, S.icon\n" +
                   "FROM entries E, subcategories S, categories C\n" +
                   "WHERE (E.category = S.nr) AND (S.catNr = C.nr)\n" +
                   "ORDER BY E.datestamp ASC\n")

    for (var i in rows) {
        rows[i].money = rows[i].money / 100
    }
    return rows
}

function getSum(start, end) {
    var rows = sql("SELECT SUM(E.money) AS money\n" +
                   "FROM entries E\n" +
                   "WHERE (E.datestamp >= ?) AND (E.datestamp <= ?)",
                   [dateToISOString(start), dateToISOString(end)])
    return rows[0].money / 100
}

function getEntryCount() {
    var rows = sql("SELECT COUNT(*) AS cnt FROM entries")
    return rows[0].cnt
}

function storeEntry(main, sub, date, money, note, icon, extra, tags) {
    var cats = getCategories()
    var found = false;
    for (var i in cats) {
        if (cats[i].name === main) {
            found = true
        }
    }
    if (!found) {
        console.log("Unknown category \"" +  main + "\"")
        return false
    }

    if (extra) {
        extra = JSON.stringify(extra)
    } else {
        extra = "";
    }

    if (tags) {
        tags = JSON.stringify(tags)
    } else {
        tags = ""
    }

    cats = getSubcategories(main)
    found = false
    for (var i in cats) {
        if(cats[i].name === sub) {
            found = true
        }
    }
    if (!found) {
        var ret = addSubcategory(sub, main, icon)
        if (ret === false) {
            return false
        }
    }

    var ret = sql("INSERT INTO entries (category, datestamp, money, notes, extra, tags)\n" +
                  "SELECT S.nr, ?, ?, ?, ?, ? FROM (\n" +
                  "   SELECT S.nr FROM subcategories S \n" +
                  "   INNER JOIN categories C ON (S.catNr = C.nr) AND (C.name = ?) WHERE S.name = ?\n" +
                  ") S;", [dateToISOString(date), parseInt(money * 100), note, main, sub, extra, tags]);
    return ret === false ? false : true;
}

function addSubcategory(name, category, icon) {
    if ((!icon) || (icon === "")) {
        icon = "android"
    }

    sql("INSERT INTO subcategories (name, catNr, icon)\n" +
        "SELECT ?, nr, ? FROM categories\n" +
        "WHERE name = ?;", [name, icon, category]);
}

function createCategories() {
    sql("CREATE TABLE IF NOT EXISTS categories (\n" +
        "   nr INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, icon TEXT NOT NULL\n" +
        ");");
    for (var c in defaultCategories) {
        sql("INSERT INTO categories (name, icon) VALUES (?, ?)", [defaultCategories[c].name, defaultCategories[c].icon])
    }
}

function createSubcategories() {
    sql("CREATE TABLE IF NOT EXISTS subcategories (\n" +
        "   nr INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, catNr INT NOT NULL, icon TEXT NOT NULL\n" +
        ");");
    for (var c in defaultCategories) {
        for (var s in defaultCategories[c].sub) {
            addSubcategory(defaultCategories[c].sub[s].name, defaultCategories[c].name, defaultCategories[c].sub[s].icon);
        }
    }
}

function createEntryTable() {
    sql("CREATE TABLE IF NOT EXISTS entries (\n" +
        "   nr INTEGER PRIMARY KEY AUTOINCREMENT, category INT NOT NULL, \n" +
        "   datestamp DATE NOT NULL, money INT, notes TEXT, \n" +
        "   tags TEXT, extra TEXT\n" +
        "   lastChanged TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n" +
        ");");
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

function deleteEntry(nr) {
    sql("DELETE FROM entries\n" +
        "WHERE (nr = ?)", [nr])
}

function updateEntry(nr, main, sub, date, money, note, extra, tags) {
    var cats = getCategories()
    var found = false;
    for (var i in cats) {
        if (cats[i].name === main) {
            found = true
        }
    }
    if (!found) {
        console.log("Unknown category \"" +  main + "\"")
        return false
    }

    if (extra) {
        extra = JSON.stringify(extra)
    } else {
        extra = "";
    }

    if (tags) {
        tags = JSON.stringify(tags)
    } else {
        tags = ""
    }

    cats = getSubcategories(main)
    found = false
    for (var i in cats) {
        if(cats[i].name === sub) {
            found = true
        }
    }
    if (!found) {
        var ret = addSubcategory(sub, main)
        if (ret === false) {
            return false
        }
    }

    sql("REPLACE INTO entries (nr, category, datestamp, money, notes, extra tags)\n" +
        "SELECT ?, S.nr, ?, ?, ? FROM (\n" +
        "   SELECT S.nr FROM subcategories S \n" +
        "   INNER JOIN categories C ON (S.catNr = C.nr) AND (C.name = ?) WHERE S.name = ?\n" +
        ") S;", [nr, dateToISOString(date), parseInt(money * 100), note, main, sub, extra, tags]);
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
    if (!db) return [];
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
    return rows;
}

function dateToISOString(date) {
    return date.getUTCFullYear() +
        '-' + pad(date.getUTCMonth() + 1) +
        '-' + pad(date.getUTCDate())
};

