-- Introduction to Relational Databases in SQL

-- CHAPTER 1 - YOUR FIRST DATABASE

-- information_schema is a meta-database that holds information about your current database.

-- Get information on all table names in the current database, while limiting your query to the 'public' table_schema.
-- tables: information about all tables in your current database
-- columns: information about all columns in all of the tables in your current database
-- The 'public' schema holds information about user-defined tables and databases. 

-- Query the right table in information_schema
SELECT table_name 
FROM information_schema.tables
-- Specify the correct table_schema value
WHERE table_schema = 'public';

-- look at the columns in university_professors by selecting all entries in information_schema.columns

-- Query the right table in information_schema to get columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'university_professors' AND table_schema = 'public';

/* has 8 columns in table university_professors */

-- Query the first five rows of our table
SELECT * 
FROM university_professors 
LIMIT 5;

-- CREATE your first few TABLEs

-- Create a table for the professors entity type
CREATE TABLE professors (
 firstname text,
 lastname text
);

-- Print the contents of this table
SELECT * 
FROM professors;

-- Create a table for the universities entity type
CREATE TABLE universities(
    university_shortname text,
    university text,
    university_city text
);

-- Print the contents of this table
SELECT * 
FROM universities;

-- ADD a COLUMN with ALTER TABLE

-- Add the university_shortname column
ALTER TABLE professors
ADD COLUMN university_shortname text;

-- Print the contents of this table
SELECT * 
FROM professors

-- RENAME and DROP COLUMNs in affiliations

-- Rename the organisation column
ALTER TABLE affiliations
RENAME column organisation TO organization;

-- Delete the university_shortname column
ALTER TABLE affiliations
DROP COLUMN university_shortname;

-- Migrate data with INSERT INTO SELECT DISTINCT

-- Insert all DISTINCT professors from university_professors into professors.

-- Insert unique professors into the new table
INSERT INTO professors 
SELECT DISTINCT firstname, lastname, university_shortname 
FROM university_professors;

-- Doublecheck the contents of professors
SELECT * 
FROM professors;

-- Insert all DISTINCT affiliations into affiliations from university_professors.
-- Insert unique affiliations into the new table
INSERT INTO affiliations 
SELECT DISTINCT firstname, lastname, function, organization 
FROM university_professors;

-- Doublecheck the contents of affiliations
SELECT * 
FROM affiliations;

-- Delete tables with DROP TABLE
-- Delete the university_professors table
DROP TABLE university_professors;

-- CHAPTER 2 - ENFORCE DATA CONSISTENCY WITH ATTRIBUTE CONSTRAINTS
-- Conforming with data types

-- Let's add a record to the table
INSERT INTO transactions (
    transaction_date, 
    amount, 
    fee) 
VALUES ('2018-09-24', 5454, '30');

-- Doublecheck the contents
SELECT *
FROM transactions;

-- If you know that a certain column stores numbers as text, you can cast the column to a numeric form, i.e. to integer.

-- Calculate the net amount as amount + fee
SELECT transaction_date, amount + CAST(fee AS int) AS net_amount 
FROM transactions;

-- Change types with ALTER COLUMN

-- Select the university_shortname column
SELECT DISTINCT(university_shortname) 
FROM professors;


-- Specify the correct fixed-length character type
ALTER TABLE professors
ALTER COLUMN university_shortname
TYPE CHAR(3);

-- Change the type of the firstname column to varchar(64).

-- Change the type of firstname
ALTER TABLE professors
ALTER COLUMN firstname
TYPE VARCHAR(64);

-- If you don't want to reserve too much space for a certain varchar column, you can truncate the values before converting its type.

-- Convert the values in firstname to a max. of 16 characters
ALTER TABLE professors 
ALTER COLUMN firstname 
TYPE varchar(16)
USING SUBSTRING(firstname FROM 1 FOR 16)
--  want to reserve only x characters for column_name, you have to retain a SUBSTRING of every value, i.e. the first x characters of it, and throw away the rest

-- Disallow NULL values with SET NOT NULL

-- Disallow NULL values in firstname
ALTER TABLE professors 
ALTER COLUMN firstname SET NOT NULL;

-- Disallow NULL values in lastname
ALTER TABLE professors 
ALTER COLUMN lastname SET NOT NULL;

-- Make your columns UNIQUE with ADD CONSTRAINT

-- Make universities.university_shortname unique
ALTER TABLE universities
ADD CONSTRAINT university_shortname_unq UNIQUE(university_shortname);

-- Make organizations.organization unique
ALTER TABLE organizations
ADD CONSTRAINT organization_unq UNIQUE(organization);

-- CHAPTER 3 - INUQUELY IDENTIFY WITH KEY CONSTRIANTS

-- There's a simple way of finding out whether a certain column (or a combination) contains only unique values – and thus identifies the records in the table.

-- Count the number of distinct values in the university_city column
SELECT COUNT(DISTINCT(university_city)) 
FROM universities;


-- The table professors has 551 rows. It has only one possible candidate key, which is a combination of two attributes. 

-- Try out different combinations
SELECT COUNT(DISTINCT(firstname, lastname)) 
FROM professors;

-- ADD key CONSTRAINTs to the tables

-- Rename the organization column to id
ALTER TABLE organizations
RENAME COLUMN organization TO id;

-- Make id a primary key
ALTER TABLE organizations
ADD CONSTRAINT organization_pk PRIMARY KEY (id);

-- Rename the university_shortname column to id
ALTER TABLE universities
RENAME COLUMN university_shortname TO id;

-- Make id a primary key
ALTER TABLE universities
ADD CONSTRAINT university_pk PRIMARY KEY(id);

-- surrogate keys

-- surrogate keys = based on a column that just exists for the sake of having a primary key
-- ideally a pk is constructed from as few columns as possible. pk of a record should never change over time

-- Add a SERIAL surrogate key

-- Add the new column to the table
ALTER TABLE professors 
ADD COLUMN id serial;

-- Make id a primary key
ALTER TABLE professors 
ADD CONSTRAINT professors_pkey PRIMARY KEY (id);

-- Have a look at the first 10 rows of professors
SELECT *
FROM professors
LIMIT 10;

-- CONCATenate columns to a surrogate key
-- In the course of the following exercises, you will combine make and model into such a surrogate key.

-- Count the number of distinct rows with columns make, model
SELECT COUNT(DISTINCT(make, model)) 
FROM cars;

-- Add the id column
ALTER TABLE cars
ADD COLUMN id varchar(128);

-- Update id with make + model
UPDATE cars
SET id = CONCAT(make, model);

-- Make id a primary key
ALTER TABLE cars
ADD CONSTRAINT id_pk PRIMARY KEY(id);

-- Have a look at the table
SELECT * FROM cars;

-- Let's think of an entity type "student". A student has:

-- a last name consisting of up to 128 characters (required),
-- a unique social security number, consisting only of integers, that should serve as a key,
-- a phone number of fixed length 12, consisting of numbers and characters (but some students don't have one).

-- Create the table
CREATE TABLE students (
  last_name VARCHAR(128) NOT NULL,
  ssn INTEGER PRIMARY KEY,
  phone_no CHAR(12)
);

-- CHAPTER 4 - GLUE TOGETHER TABLES WITH FOREIGN KEYS

-- Foreign keys:
-- domain and data type must be same as one of the PK
-- only foreign key values are allowed to exist as values in the PK referenced table = referential integrity
-- duplicates and Null values are allowed

-- In your database, you want the professors table to reference the universities table. You can do that by specifying a column in professors table that references a column in the universities table.

-- Rename the university_shortname column
ALTER TABLE professors
RENAME COLUMN university_shortname TO university_id;

-- Add a foreign key on professors referencing universities
ALTER TABLE professors
ADD CONSTRAINT professors_fkey FOREIGN KEY (university_id) REFERENCES universities (id);

-- Explore foreign key constraints

-- Correct the university_id so that it actually reflects where Albert Einstein wrote his dissertation and became a professor – at the University of Zurich (UZH)!
-- Try to insert a new professor
INSERT INTO professors (firstname, lastname, university_id)
VALUES ('Albert', 'Einstein', 'UZH');

-- JOIN tables linked by a foreign key

-- Select all professors working for universities in the city of Zurich
SELECT professors.lastname, universities.id, universities.university_city
FROM professors
LEFT JOIN universities
ON professors.university_id = universities.id
WHERE universities.university_city = 'Zurich';

-- At the moment, the affiliations table has the structure {firstname, lastname, function, organization}. 
-- Turn this table into the form {professor_id, organization_id, function}, with professor_id and organization_id being foreign keys that point to the respective tables
-- Add foreign keys to the "affiliations" table

-- Add a professor_id column
ALTER TABLE affiliations
ADD COLUMN professor_id integer REFERENCES professors (id);

-- Rename the organization column to organization_id
ALTER TABLE affiliations
RENAME organization TO organization_id;

-- Add a foreign key on organization_id
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_fkey FOREIGN KEY(organization_id) REFERENCES organizations (id);

-- Populate the "professor_id" column

-- Now it's time to also populate professors_id. You'll take the ID directly from professors.

-- Have a look at the 10 first rows of affiliations
SELECT *
FROM affiliations
LIMIT 10;

-- Update professor_id to professors.id where firstname, lastname correspond to rows in professors
UPDATE affiliations
SET professor_id = professors.id
FROM professors
WHERE affiliations.firstname = professors.firstname AND affiliations.lastname = professors.lastname;

-- Have a look at the 10 first rows of affiliations again
SELECT *
FROM affiliations
LIMIT 10;

-- Drop "firstname" and "lastname"

-- The firstname and lastname columns of affiliations were used to establish a link to the professors table in the last exercise
-- his only worked because there is exactly one corresponding professor for each row in affiliations
-- Because professors are referenced by professor_id now, the firstname and lastname columns are no longer needed, so it's time to drop them.

-- Drop the firstname column
ALTER TABLE affiliations
DROP COLUMN firstname;

-- Drop the lastname column
ALTER TABLE affiliations
DROP COLUMN lastname;

-- REFERENTIAL INTEGRITY

-- DEALING WITH CIOLATIONS ON DELETE (2 CTABLES THAT ARE BEING REFERENCED TO ONE ANOTHER)
-- NO ACTION: throw and error
-- CASCADE: delete all referencing tables
-- RESTRICT: throw and error
-- SET NULL: set the referencing column to NULL
-- SET DEFAULT: set the referencing column to its default value


DELETE FROM universities WHERE id = 'EPF';
-- will not execute - throws an error

-- update or delete on table "universities" violates foreign key constraint "professors_fkey" on table "professors"
-- DETAIL:  Key (id)=(EPF) is still referenced from table "professors".
-- EXPLANATION: You defined a foreign key on professors.university_id that references universities.id, so referential integrity is said to hold from professors to universities.

-- Change the referential integrity behavior of a key
-- So far, you implemented three foreign key constraints:

/*
professors.university_id to universities.id
affiliations.organization_id to organizations.id
affiliations.professor_id to professors.id

These foreign keys currently have the behavior ON DELETE NO ACTION. 
Here, you're going to change that behavior for the column referencing organizations from affiliations. If an organization is deleted, all its affiliations (by any professor) should also be deleted.

*/

-- Identify the correct constraint name
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY';

-- Drop the right foreign key constraint
ALTER TABLE affiliations
DROP CONSTRAINT affiliations_organization_id_fkey;

-- Add a new foreign key constraint from affiliations to organizations which cascades deletion
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id) ON DELETE CASCADE;

-- Delete an organization 
DELETE FROM organizations 
WHERE id = 'CUREM';

-- Check that no more affiliations with this organization exist
SELECT * FROM affiliations
WHERE organization_id = 'CUREM';

-- Count affiliations per university

/* 
Now that your data is ready for analysis, let's run some exemplary SQL queries on the database. You'll now use already known concepts such as grouping by columns and joining tables.
*/

--  find out which university has the most affiliations (through its professors).

-- Count the total number of affiliations per university
SELECT COUNT(*), professors.university_id 
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
-- Group by the university ids of professors
GROUP BY professors.university_id 
ORDER BY count DESC;

--  find the university city of the professor with the most affiliations in the sector "Media & communication".

-- STEP 1 
-- Join all tables
SELECT *
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id;

-- STEP 2

-- Group the table by organization sector, professor ID and university city
SELECT COUNT(*), organizations.organization_sector, 
professors.id, universities.university_city
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id
GROUP BY organizations.organization_sector, 
professors.id, universities.university_city;

-- STEP 3

-- Only retain rows with "Media & communication" as organization sector, and sort the table by count, in descending order.

-- Filter the table and sort it
SELECT COUNT(*), organizations.organization_sector, 
professors.id, universities.university_city
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id
WHERE organizations.organization_sector = 'Media & communication'
GROUP BY organizations.organization_sector, 
professors.id, universities.university_city
ORDER BY COUNT DESC;






