-- This database is created for demonstration reasons

CREATE TABLE characters (
	id SERIAL PRIMARY KEY,
	name varchar(50) NOT NULL,
	species varchar(50),
	gender varchar(50),
	trademark TEXT,
	favourite_food varchar(50)
);

-- Information from https://hellokitty.fandom.com/wiki/List_of_Sanrio_characters#Hello_Kitty

INSERT INTO characters (name, species, gender, trademark, favourite_food) VALUES
('Hello Kitty', 'Cat', 'Female', 'Red bow', 'Mama''s apple pie'),
('My Melody', 'Rabbit', 'Female', 'Pink hood', 'Almond pound cake'),
('Cinnamoroll', 'Puppy', 'Male', 'Blue bowtie', 'Cinnamon rolls'),
('Badtz-Maru', 'Penguin', 'Male', 'Spiky hair', 'Poripari ramen'),
('Kuromi', 'Rabbit', 'Female', 'Black jester hat', 'Shallots'),
('Keroppi', 'Frog', 'Male', 'V-shaped mouth', 'Rice balls'),
('Pompompurin', 'Dog', 'Male', 'Brown beret', 'Cream caramel pudding'),
('Pochacco', 'Dog', 'Male', 'Athletic attire', 'Banana ice cream'),
('Chococat', 'Cat', 'Male', 'Black fur', 'Chocolate'),
('Tuxedosam', 'Penguin', 'Male', 'Sailor hat', 'Fish');

-- Increasing database size by taking additional characters from Hello Kitty Island Adventure game (logged 49h of game time)

INSERT INTO characters (name, species, gender, trademark, favourite_food) VALUES
('Cogimyun', 'Bread', 'Male', 'Wheatflour head', 'Fluffy dough'),
('Ebi Fry', 'Shrimp', 'Male', 'Golden tail', 'Fried shrimp'),
('Espresso', 'Cat', 'Male', 'Coffee aroma', 'Espresso beans'),
('Cappuccino', 'Cat', 'Female', 'Foamy hair', 'Cappuccino dessert'),
('Mocha', 'Dog', 'Female', 'Warm fur', 'Chocolate cake'),
('Chiffon', 'Dog', 'Male', 'Fluffy mane', 'Vanilla cream'),
('Dear Daniel', 'Cat', 'Male', 'Blue overalls', 'Vanilla pudding'),
('Milk', 'Rabbit', 'Female', 'White fur', 'Milk pudding'),
('Coco', 'Dog', 'Male', 'Brown spots', 'Dog biscuits'),
('Baku', 'Tapir', 'Male', 'Dream eater', 'Dream candy'),
('Melomari', 'Rabbit', 'Female', 'Grey fur', 'Bibimbap, Molly tea');

-- Checking to see if all the characters and other variables have been listed correctly

SELECT * FROM characters;

-- Altering the table to add birthdays, assuming the client wants this variable to be added into the database

ALTER TABLE characters
ADD COLUMN birthday INT;

UPDATE characters
SET birthday = 19741101
WHERE name = 'Hello Kitty';

UPDATE characters
SET birthday = 19750303
WHERE name = 'My Melody';

-- It doesn't look good, I should change the format

ALTER TABLE characters
ALTER COLUMN birthday TYPE DATE
USING TO_DATE(birthday::text, 'DDMMYYYY');

UPDATE characters
SET birthday = TO_DATE(
    CASE name
        WHEN 'Hello Kitty' THEN '01-11-1974'
        WHEN 'My Melody' THEN '03-03-1975'
        WHEN 'Cinnamoroll' THEN '06-03-2001'
        WHEN 'Badtz-Maru' THEN '01-04-1993'
        WHEN 'Kuromi' THEN '17-07-2005'
        WHEN 'Keroppi' THEN '23-07-1988'
        WHEN 'Pompompurin' THEN '16-04-1996'
        WHEN 'Pochacco' THEN '26-06-1989'
        WHEN 'Chococat' THEN '06-09-1996'
        WHEN 'Tuxedosam' THEN '11-07-1979'
        WHEN 'Cogimyun' THEN '12-03-2016'
        WHEN 'Ebi Fry' THEN '15-08-2007'
        WHEN 'Espresso' THEN '15-05-2001'
        WHEN 'Cappuccino' THEN '15-05-2001'
        WHEN 'Mocha' THEN '12-12-2000'
        WHEN 'Chiffon' THEN '12-12-2000'
        WHEN 'Dear Daniel' THEN '01-06-1979'
        WHEN 'Milk' THEN '05-05-2005'
        WHEN 'Coco' THEN '05-05-2005'
        WHEN 'Baku' THEN '03-03-2003'
        WHEN 'Melomari' THEN '12-11-2000'
    END, 'DD-MM-YYYY'
);

-- Checking to see if the dates can be extracted from birthdays to sort the characters

SELECT
    name,
    species,
    gender,
    trademark,
    favourite_food,
    TO_CHAR(birthday, 'DD/MM/YYYY') AS birthday_formatted,
    EXTRACT(YEAR FROM birthday) AS birth_year
FROM characters
ORDER BY birth_year ASC;

-- Creating a separate table for querying family relations of different characters

CREATE TABLE character_family (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL REFERENCES characters(id),
    relative_id INT NOT NULL REFERENCES characters(id),
    relationship_type VARCHAR(50) NOT NULL
);

-- Hello Kitty
INSERT INTO character_family (character_id, relative_id, relationship_type) VALUES
((SELECT id FROM characters WHERE name='Hello Kitty'), (SELECT id FROM characters WHERE name='Dear Daniel'), 'boyfriend'),
((SELECT id FROM characters WHERE name='Dear Daniel'), (SELECT id FROM characters WHERE name='Hello Kitty'), 'girlfriend');

-- Cinnamoroll
INSERT INTO character_family (character_id, relative_id, relationship_type) VALUES
((SELECT id FROM characters WHERE name='Cinnamoroll'), (SELECT id FROM characters WHERE name='Mocha'), 'sibling'),
((SELECT id FROM characters WHERE name='Cinnamoroll'), (SELECT id FROM characters WHERE name='Chiffon'), 'sibling'),
((SELECT id FROM characters WHERE name='Cinnamoroll'), (SELECT id FROM characters WHERE name='Espresso'), 'sibling'),
((SELECT id FROM characters WHERE name='Cinnamoroll'), (SELECT id FROM characters WHERE name='Cappuccino'), 'sibling'),

-- Cinnamoroll bidirectional links
((SELECT id FROM characters WHERE name='Mocha'), (SELECT id FROM characters WHERE name='Cinnamoroll'), 'sibling'),
((SELECT id FROM characters WHERE name='Chiffon'), (SELECT id FROM characters WHERE name='Cinnamoroll'), 'sibling'),
((SELECT id FROM characters WHERE name='Espresso'), (SELECT id FROM characters WHERE name='Cinnamoroll'), 'sibling'),
((SELECT id FROM characters WHERE name='Cappuccino'), (SELECT id FROM characters WHERE name='Cinnamoroll'), 'sibling');

-- Testing if the new table works

SELECT sanrio1.name AS character, sanrio2.name AS relative, sanriof.relationship_type
FROM character_family sanriof
JOIN characters sanrio1 ON sanriof.character_id = sanrio1.id
JOIN characters sanrio2 ON sanriof.relative_id = sanrio2.id
WHERE sanrio1.name IN ('Cinnamoroll', 'Hello Kitty')
ORDER BY sanrio1.name, sanrio2.name;

-- My very simple database is now complete! Time to run some queries.

SELECT name, species
FROM characters
ORDER BY name;

SELECT species, COUNT(*) AS count
FROM characters
GROUP BY species
ORDER BY count DESC;

SELECT name, TO_CHAR(birthday, 'DD/MM/YYYY') AS birthday_formatted
FROM characters
ORDER BY birthday;

SELECT *
FROM characters
WHERE name LIKE 'C%';

SELECT name, TO_CHAR(birthday, 'DD/MM/YYYY') AS birthday
FROM characters
WHERE birthday > DATE '2000-11-12'
ORDER BY birthday;

SELECT sanrio1.name, COUNT(sanrio2.id) AS sibling_count
FROM characters sanrio1
LEFT JOIN character_family sanriof ON sanrio1.id = sanriof.character_id AND sanriof.relationship_type = 'sibling'
LEFT JOIN characters sanrio2 ON sanriof.relative_id = sanrio2.id
GROUP BY sanrio1.name
ORDER BY sibling_count DESC;

SELECT 
    sanrio.name,
    sanrio.species,
    sanrio.gender,
    sanrio.trademark,
    sanrio.favourite_food,
    TO_CHAR(sanrio.birthday, 'DD/MM/YYYY') AS birthday,
    COALESCE(family.family_members, 'No family recorded') AS family_members
FROM characters sanrio
LEFT JOIN (
    SELECT sanriof.character_id,
           STRING_AGG(sanrio2.name || ' (' || sanriof.relationship_type || ')', ', ') AS family_members
    FROM character_family sanriof
    JOIN characters sanrio2 ON sanriof.relative_id = sanrio2.id
    GROUP BY sanriof.character_id
) AS family ON sanrio.id = family.character_id
WHERE sanrio.name = 'Hello Kitty';

SELECT 
    sanrio.name,
    sanrio.species,
    sanrio.gender,
    sanrio.trademark,
    sanrio.favourite_food,
    TO_CHAR(sanrio.birthday, 'DD/MM/YYYY') AS birthday,
    COALESCE(family.family_members, 'No family recorded') AS family_members
FROM characters sanrio
LEFT JOIN (
    SELECT sanriof.character_id,
           STRING_AGG(sanrio2.name || ' (' || sanriof.relationship_type || ')', ', ') AS family_members
    FROM character_family sanriof
    JOIN characters sanrio2 ON sanriof.relative_id = sanrio2.id
    GROUP BY sanriof.character_id
) AS family ON sanrio.id = family.character_id
WHERE sanrio.name = 'Pompompurin';