Tables
======

## categories

nr, name
CREATE TABLE categories (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL
);

## sub-categories

nr, name, catIndex
CREATE TABLE subcategories (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    catNr INT NOT NULL
);

## entry

index, date, subcat, money, note, change
CREATE TABLE entries (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    category INT NOT NULL,
    datestamp DATE NOT NULL,
    money INT,
    change TIMESTAMP
);

Queries
=======

## Count of entries per subcategory of one category by name of last 20 entries

SELECT COUNT(E.category) AS cnt, S.name
FROM entries E
INNER JOIN (
    SELECT COUNT(*) AS cnt FROM entries
) cnt
ON E.nr > (cnt.cnt - 20)
INNER JOIN (
    SELECT S.nr 
    FROM subcategories S, categories C
    WHERE (S.catNr = C.nr) AND (C.name = "cat1")
) Sub
ON E.category = Sub.nr,
subcategories S
WHERE E.category = S.nr
GROUP BY category 
ORDER BY cnt DESC;

## Last 100 entries

SELECT * FROM entries E
INNER JOIN (
    SELECT COUNT(*) AS cnt FROM entries
) cnt
ON E.nr > (cnt.cnt - 100)

## Insert Entry by Category names

INSERT INTO entries (category, datestamp, money, notes)
SELECT S.nr, "2018-09-15", "10", "note" 
FROM (
    SELECT S.nr FROM subcategories S
    INNER JOIN categories C ON (S.catNr = C.nr) AND (C.name = "cat3")
    WHERE S.name = "subcat33"
) S;

## Add new subcategory by category name

INSERT INTO subcategories (name, catNr) SELECT "subcat14", C.nr
FROM (
    SELECT nr FROM categories
    WHERE name = "cat1"
) C;

## Get entries by Date-range

SELECT * FROM entries
WHERE (datestamp >= "2017-08-16")
AND (datestamp <= "2017-08-20")

## Get Category names

SELECT * FROM categories

## Get Subcategory names of category

SELECT * FROM subcategories S
INNER JOIN categories C ON
(S.catNr = C.nr) AND
(C.name = "cat1")


Testbench
=========

CREATE TABLE categories (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL
);
INSERT INTO categories (name) VALUES("cat1");
INSERT INTO categories (name) VALUES("cat2");
INSERT INTO categories (name) VALUES("cat3");

CREATE TABLE subcategories (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    catNr INT NOT NULL,
    INDEX(catNr)
);
INSERT INTO subcategories (name, catNr) VALUES("subcat11", 1);
INSERT INTO subcategories (name, catNr) VALUES("subcat12", 1);
INSERT INTO subcategories (name, catNr) VALUES("subcat13", 1);

INSERT INTO subcategories (name, catNr) VALUES("subcat21", 2);
INSERT INTO subcategories (name, catNr) VALUES("subcat22", 2);
INSERT INTO subcategories (name, catNr) VALUES("subcat23", 2);

INSERT INTO subcategories (name, catNr) VALUES("subcat31", 3);
INSERT INTO subcategories (name, catNr) VALUES("subcat32", 3);
INSERT INTO subcategories (name, catNr) VALUES("subcat33", 3);

CREATE TABLE entries (
    nr INT AUTO_INCREMENT PRIMARY KEY,
    category INT NOT NULL,
    datestamp DATE NOT NULL,
    money INT,
    notes TEXT,
    lastChanged TIMESTAMP,
    INDEX(category),
    INDEX(datestamp)
);

INSERT INTO entries (category, datestamp) VALUES(1, "2017-08-14");
INSERT INTO entries (category, datestamp) VALUES(2, "2017-08-15");
INSERT INTO entries (category, datestamp) VALUES(2, "2017-08-16");
INSERT INTO entries (category, datestamp) VALUES(3, "2017-08-17");
INSERT INTO entries (category, datestamp) VALUES(3, "2017-08-18");
INSERT INTO entries (category, datestamp) VALUES(3, "2017-08-19");

INSERT INTO entries (category, datestamp) VALUES(4, "2017-08-20");
INSERT INTO entries (category, datestamp) VALUES(5, "2017-08-21");
INSERT INTO entries (category, datestamp) VALUES(6, "2017-08-22");
