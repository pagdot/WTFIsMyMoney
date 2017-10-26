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
        name: "food_drinks",
        icon: "silverware"
    },
    {
        name: "life_home",
        icon: "home"
    },
    {
        name: "hobbies",
        icon: "sofa"
    },
    {
        name: "transport",
        icon: "car"
    },
    {
        name: "other",
        icon: "plus"
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

function init(_localStorage, version) {
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
            tx.executeSql('SELECT * FROM tags');
        })
    } catch(err) {
        createTagTable();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM entryTags');
        })
    } catch(err) {
        createEntryTagTable();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM entries');
        })
    } catch(err) {
        createEntryTable();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM info');
        })
    } catch(err) {
        sql("CREATE TABLE IF NOT EXISTS info (\n" +
            "   key TEXT PRIMARY KEY, \n" +
            "   value TEXT\n" +
            ");");
    }

    if (getVersion() === version) {
        return false
    }
    setVersion(version)
    return true
}

function getVersion() {
    var rows = sql("SELECT value FROM info WHERE key = 'version'")
    if (rows.length == 0) {
        return false
    }
    return rows[0].value
}

function setVersion(version) {
    sql(
                "INSERT OR REPLACE INTO info (key, value)\n" +
                "SELECT 'version', ?", [version]
        )
}

function isInit() {
    if (localStorage) {
        return true;
    } else {
        return false;
    }
}

function clearDb() {
    sql("DELETE FROM categories")
    sql("DELETE FROM tags")
    sql("DELETE FROM entryTags")
    sql("DELETE FROM entries")

    createCategories()
    createTagTable()
    createEntryTagTable()
    createEntryTable()
}

function importEntries(entries) {
    for (var i in entries) {
        //update import
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

function createTag(name, category) {
    if (!category) {
        category = ""
    }

    sql("INSERT INTO tags (name, category) VALUES (?, ?)", [name, category])
}

function getTags() {
    return sql("SELECT * FROM tags")
}

function getTagsWithUsage() {
    var tags = getTags();
    for (var i in tags) {
        tags[i].usage = getTagUsage(tags[i].nr)
    }
    return tags;
}

function createTagEntryLink(entryId, tagId) {
    sql("INSERT INTO entryTags (entryId, tagId) VALUES (?, ?)", [entryId, tagId]);
}

function deleteEntryTagLink(entryId, tagId) {
    sql("DELETE FROM entryTags\n" +
        "WHERE (entryID = ?) AND (tagID = ?)", [entryId, tagId])
}

function getTagUsage(tagId) {
    var rows = sql("SELECT COUNT(*) AS cnt FROM entryTags\n" +
                   "WHERE (tagID = ?)", [tagId]);
    return rows[0].cnt
}

function getEntries(count) {
    var rows;
    if (count) {
        rows = sql( "SELECT E.nr, C.name AS category, E.datestamp, E.money, E.notes, C.icon\n" +
                    "FROM entries E, categories C\n" +
                    "WHERE (E.category = C.name)\n" +
                    "ORDER BY E.datestamp DESC\n" +
                    "LIMIT ?", [count]);
    } else {
        rows = sql( "SELECT E.nr, C.name AS category, E.datestamp, E.money, E.notes, C.icon\n" +
                    "FROM entries E, categories C\n" +
                    "WHERE (E.category = C.name)\n" +
                    "ORDER BY E.datestamp DESC");
    }
    for (var i in rows) {
        rows[i].tags = sql("SELECT T.name\n" +
                           "FROM tags T, entryTags ET\n" +
                           "WHERE (ET.entryID = ?) AND (T.nr = ET.tagID)",
                           [rows[i].nr]);

        if (rows[i].notes === null) {
            rows[i].notes = "";
        }
        rows[i].datestamp = new Date(rows[i].datestamp)
        rows[i].money = rows[i].money / 100
    }

    return rows;
}

function getMoneyPerCategory(start, end) {
    var rows = sql("SELECT C.icon, C.name, SUM(money) AS money\n" +
                   "FROM entries E, categories C\n" +
                   "WHERE (E.category = C.name)\n" +
                   "    AND (E.datestamp >= ?) AND (E.datestamp <= ?)\n" +
                   "GROUP BY C.name", [dateToISOString(start), dateToISOString(end)])
    for (var i in rows) {
        rows[i].money = rows[i].money / 100
    }
    return rows
}

function getMoneyPerMonth(start, end) {
    var tmpStart = new Date(start)
    var tmpEnd = lastDayOfMonth(tmpStart)
    var array = [];
    while (tmpEnd <= end) {
        var tmp = getSum(tmpStart, tmpEnd)
        array.push({month: new Date(tmpStart), money: tmp})
        tmpStart.setMonth(tmpStart.getMonth() + 1)
        tmpEnd = lastDayOfMonth(tmpStart)
    }
    if (isSameDate(tmpEnd, end)) {
        var tmp = getSum(tmpStart, end)
        array.push({month: new Date(tmpStart), money: tmp})
    }
    return array
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

function storeEntry(main, date, money, note, icon, tags) {
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

    var ret = sql("INSERT INTO entries (category, datestamp, money, notes)\n" +
                  "SELECT ?, ?, ?, ?",
                  [main, dateToISOString(date), parseInt(money * 100), note]);
    var entryId = sql("SELECT nr FROM entries ORDER BY nr DESC LIMIT 1")[0].nr

    var _tags=getTags();

    console.log(JSON.stringify(tags))

    for (var tag in tags) {
        var found = false;
        for (var _tag in _tags) {
            if ((_tags[_tag].name === tags[tag].name) && (_tags[_tag].category === tags[tag].category)) {
                found = true;
                createTagEntryLink(entryId, _tags[_tag].nr)
            }
        }
        if (found == false) {
            createTag(tags[tag].name, tags[tag].category);
            var tagId = sql("SELECT nr FROM tags ORDER BY nr DESC LIMIT 1")[0].nr;
            createTagEntryLink(entryId, tagId);
        }
    }

    return true;
}

function createCategories() {
    sql("CREATE TABLE IF NOT EXISTS categories (\n" +
        "   name TEXT PRIMARY KEY, icon TEXT NOT NULL\n" +
        ");");
    for (var c in defaultCategories) {
        sql("INSERT INTO categories (name, icon) VALUES (?, ?)", [defaultCategories[c].name, defaultCategories[c].icon])
    }
}

function createTagTable() {
    sql("CREATE TABLE IF NOT EXISTS tags (\n" +
        "   nr INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT\n" +
        ");");
}

function createEntryTagTable() {
    sql("CREATE TABLE IF NOT EXISTS entryTags (\n" +
        "   entryId INT NOT NULL, tagId INT NOT NULL\n" +
        ");");
}

function createEntryTable() {
    sql("CREATE TABLE IF NOT EXISTS entries (\n" +
        "   nr INTEGER PRIMARY KEY AUTOINCREMENT, category INT NOT NULL, \n" +
        "   datestamp DATE NOT NULL, money INT, notes TEXT, extra TEXT\n" +
        "   lastChanged TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n" +
        ");");
}

function reset() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("DROP TABLE categories;");
            tx.executeSql("DROP TABLE tags;");
            tx.executeSql("DROP TABLE entryTags;");
            tx.executeSql("DROP TABLE entries;");
        });
    } catch(err) {
        console.log("Error: Could not delete tables: " + err)
    }
    init(localStorage)
}

function deleteEntry(nr) {
    sql("DELETE FROM entryTags\n" +
        "WHERE (entryID = ?)", [nr]);
    sql("DELETE FROM entries\n" +
        "WHERE (nr = ?)", [nr]);
}

function updateEntry(nr, main, sub, date, money, note, tags) {
    //update to tags
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

    var _tags = sql("SELECT T.* FROM tags T\n" +
                    "INNER JOIN entryTags ET ON\n" +
                    "   (T.nr = ET.tagID) AND (ET.entryID = ?)", [nr]);

    for (var i in tags) {
        var found = false;
        for (var j in _tags) {
            if (tags[i].nr === _tags[j].nr) {
                found = true;
                _tags.splice(j, 1);
                break;
            }
        }
        if (!found) {
            createTag(tags[tag].name, tags[tag].category);
            var tagId = sql("SELECT nr FROM tags ORDER BY nr DESC LIMIT 1")[0].nr;
            createTagEntryLink(entryId, tagId);
        }
    }

    for (var i in _tags) {
        deleteEntryTagLink(nr, _tags[i].nr)
    }

    sql("REPLACE INTO entries (nr, category, datestamp, money, notes)\n" +
        "SELECT ?, ?, ?, ?, ?",
        [nr, dateToISOString(date), parseInt(money * 100), note, extra, tags, main, sub]);
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
    return date.getFullYear() +
        '-' + pad(date.getMonth() + 1) +
        '-' + pad(date.getDate())
}

function copy(object) {
    var objString = JSON.stringify(object)
    var obj = JSON.parse(objString)
    return obj
}

function lastDayOfMonth(month) {
    var tmp = new Date(month)
    tmp.setMonth(tmp.getMonth() + 1)
    tmp.setDate(0)
    return tmp
}

function isSameDate(date1, date2) {
    return (
      date1.getFullYear() === date2.getFullYear() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getDate() === date2.getDate()
    );
  }
