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

var defaultRootTags = [
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

var defaultSettings = {
    enableQR: true,
}

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
            tx.executeSql('SELECT * FROM tags');
        })
    } catch(err) {
        createTagTable();
    }
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM tagTree');
        })
    } catch(err) {
        createTagTreeTable();
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
    try {
        db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM settings');
        })
    } catch(err) {
        sql("CREATE TABLE IF NOT EXISTS settings (\n" +
            "   key TEXT PRIMARY KEY, \n" +
            "   value TEXT\n" +
            ");");
        storeSettings(defaultSettings);
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
    sql("DELETE FROM tags")
    sql("DELETE FROM tagTree")
    sql("DELETE FROM entryTags")
    sql("DELETE FROM entries")

    createTagTable()
    createTagTreeTable();
    createEntryTagTable()
    createEntryTable()
}

function createTagTreeTable() {
    sql("CREATE TABLE IF NOT EXISTS tagTree (\n" +
        "   id INTEGER PRIMARY KEY AUTOINCREMENT, parentId INT, childId INT NOT NULL\n" +
        ");");
}

//todo
function importEntries(entries) {
    for (var i in entries) {
        var tags = [];
        for (var j in entries[i].tags) {
            tags.push({name: entries[i].tags[j].slice(1), category: (entries[i].tags[j].charAt(0) === "l" ? entries[i].category : "")});
        }

        storeEntry(entries[i].category, entries[i].date, entries[i].money, entries[i].note, tags);
    }
}

function createTag(name, icon) {
    if (!icon) {
        icon = ""
    }

    sql("INSERT INTO tags (name, icon) VALUES (?, ?)", [name, icon])
}

function linkTags(childId, parentId) {
    var links = sql("SELECT * FROM tagTree");
    for (var i in links) {
        if ((links[i].parentId === parentId) && (links[i].childId === childId)) {
            return;
        }
    }
    sql("INSERT INTO tagTree (parentId, childId) VALUES (?, ?)", [parentId, childId]);
}

function getTags() {
    var tags = sql("SELECT * FROM tags");
    for (var i in tags) {
        tags[i].childs = getTagChilds(tags[i].id)
        if (tags[i].icon === null) tags[i].icon = "";
    }

    return tags;
}

function getTags(entryId) {
    var tags = sql("SELECT T.name, T.icon\n" +
                   "FROM tags T, entryTags ET\n" +
                   "WHERE (ET.entryID = ?) AND (T.id = ET.tagID)",
                   entryId);
    for (var i in tags) {
        if (tags[i].icon === null) tags[i].icon = "";
    }

    return tags;
}

function getTagChilds(tagId) {
    var childs = sql("SELECT childId AS id FROM tagTree WHERE (parentId = ?)", tags[i].id);
    for (var i in rows) {
        childs[i] = childs[i].id;
    }
    return childs;
}

function getTagsWithUsage() {
    var tags = getTags();
    for (var i in tags) {
        tags[i].usage = getTagUsage(tags[i].id)
    }
    return tags;
}

function createTagEntryLink(entryId, tagId) {
    sql("INSERT INTO entryTags (entryId, tagId) VALUES (?, ?)", [entryId, tagId]);
}

function deleteEntryTagLink(entryId, tagId, depth) {
    if (!depth) {
        depth = 0;
    } else if (depth > 100) {
        console.log("deleteEntryTagLink: Recursion depth limit reached");
        return;
    }

    sql("DELETE FROM entryTags\n" +
        "WHERE (entryID = ?) AND (tagID = ?)", [entryId, tagId]);
    var childs = getTagChilds(tagId);
    for (var i in childs) {
        deleteEntryTagLink(entryId, childs[i], depth+1);
    }
}

function getTagUsage(tagId) {
    var rows = sql("SELECT COUNT(*) AS cnt FROM entryTags\n" +
                   "WHERE (tagID = ?)", [tagId]);
    return rows[0].cnt
}

function getEntries(count) {
    var rows;
    if (count) {
        rows = sql( "SELECT E.id, C.name AS category, E.datestamp, E.money, E.notes, C.icon\n" +
                    "FROM entries E, categories C\n" +
                    "WHERE (E.category = C.name)\n" +
                    "ORDER BY E.datestamp DESC,id DESC\n" +
                    "LIMIT ?", [count]);
    } else {
        rows = sql( "SELECT E.id, C.name AS category, E.datestamp, E.money, E.notes, C.icon\n" +
                    "FROM entries E, categories C\n" +
                    "WHERE (E.category = C.name)\n" +
                    "ORDER BY E.datestamp DESC,id DESC");
    }
    for (var i in rows) {
        rows[i].tags = getTags(rows[i].id)


        if (rows[i].notes === null) {
            rows[i].notes = "";
        }
        rows[i].datestamp = new Date(rows[i].datestamp)
        rows[i].money = rows[i].money / 100
    }

    return rows;
}

/** Needs to be ported to tags
function getMoneyPerCategory(start, end) {
    var rows = sql("SELECT C.icon, C.name, SUM(money) AS money\n" +
                   "FROM entries E, categories C\n" +
                   "WHERE (E.category = C.name)\n" +
                   "    AND (E.datestamp >= ?) AND (E.datestamp <= ?)\n" +
                   "    AND (money > 0)\n" +
                   "GROUP BY C.name", [dateToISOString(start), dateToISOString(end)])
    for (var i in rows) {
        rows[i].money = rows[i].money / 100
    }
    return rows
}*/

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

//todo
function storeEntry(date, money, note, tags) {

    var ret = sql("INSERT INTO entries (datestamp, money, notes)\n" +
                  "SELECT ?, ?, ?",
                  [dateToISOString(date),  parseInt((money * 100).toFixed(0)), note]);
    var entryId = sql("SELECT id FROM entries ORDER BY id DESC LIMIT 1")[0].id

    var _tags=getTags();

    for (var tag in tags) {
        var found = false;
        for (var _tag in _tags) {
            if ((_tags[_tag].name === tags[tag].name) && (_tags[_tag].category === tags[tag].category)) {
                found = true;
                createTagEntryLink(entryId, _tags[_tag].id)
            }
        }
        if (found == false) {
            createTag(tags[tag].name, tags[tag].category);
            var tagId = sql("SELECT id FROM tags ORDER BY id DESC LIMIT 1")[0].id;
            createTagEntryLink(entryId, tagId);
        }
    }

    return true;
}

function createTagTable() {
    sql("CREATE TABLE IF NOT EXISTS tags (\n" +
        "   id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, icon TEXT\n" +
        ");");
    sql("INSERT INTO tags (name) VALUES (root)");
}

function createEntryTagTable() {
    sql("CREATE TABLE IF NOT EXISTS entryTags (\n" +
        "   entryId INT NOT NULL, tagId INT NOT NULL\n" +
        ");");
}

function createEntryTable() {
    sql("CREATE TABLE IF NOT EXISTS entries (\n" +
        "   id INTEGER PRIMARY KEY AUTOINCREMENT, category INT NOT NULL, \n" +
        "   datestamp DATE NOT NULL, money INT, notes TEXT, extra TEXT\n" +
        "   lastChanged TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n" +
        ");");
}

function reset() {
    var db = getDB()
    try {
        db.transaction(function(tx) {
            tx.executeSql("DROP TABLE tagTree;");
            tx.executeSql("DROP TABLE tags;");
            tx.executeSql("DROP TABLE entryTags;");
            tx.executeSql("DROP TABLE entries;");
        });
    } catch(err) {
        console.log("Error: Could not delete tables: " + err)
    }
    init(localStorage)
}

function deleteEntry(id) {
    sql("DELETE FROM entryTags\n" +
        "WHERE (entryID = ?)", [id]);
    sql("DELETE FROM entries\n" +
        "WHERE (id = ?)", [id]);
}

//TODO
function updateEntry(id, main, date, money, note, tags) {
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

    var _tags = sql("SELECT T.* FROM tags T\n" +
                    "INNER JOIN entryTags ET ON\n" +
                    "   (T.id = ET.tagID) AND (ET.entryID = ?)", [id]);

    for (var i in tags) {
        var found = false;
        for (var j in _tags) {
            if (tags[i].id === _tags[j].id) {
                found = true;
                _tags.splice(j, 1);
                break;
            }
        }
        if (!found) {
            createTag(tags[i].name, tags[i].category);
            var tagId = sql("SELECT id FROM tags ORDER BY id DESC LIMIT 1")[0].id;
            createTagEntryLink(id, tagId);
        }
    }

    for (var i in _tags) {
        deleteEntryTagLink(id, _tags[i].id)
    }

    sql("REPLACE INTO entries (id, category, datestamp, money, notes)\n" +
        "SELECT ?, ?, ?, ?, ?",
        [id, main, dateToISOString(date), parseInt((money * 100).toFixed(0)), note]);
}

function getSettings() {
    var lines = sql("SELECT * FROM settings");
    var data = {};
    for (var i in lines) {
        data[lines[i].key] = lines[i].value;
    }
    if (data.enableQR) data.enableQR = data.enableQR === "1";
    return data;
}

function storeSettings(settings) {
    var old = getSettings();
    for (var key in settings) {
        if (settings[key] !== old[key]) {
            sql("REPLACE INTO settings (key, value)\n" +
                "SELECT ?, ?", [key, settings[key]]);
        }
    }
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
