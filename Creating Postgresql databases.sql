-- Creating Postgresql databases

-- CHAPTER 1 - Structure of PostgreSQL Databases

-- Motivation for a new database
/* 
- restaurant loyalty programme to keep track of customer visits and orders
- residential management company to store info about tenants and apartments accross 55 properties which they own
- doctors office to organise a filing cabinent or patient records in electronic format
*/

-- restrictions: max legnth = 31 characters ; begins with letter or underscore

-- Name that table

-- Delete me and command below if this table name is invalid
CREATE TABLE customers (); -- fine

-- Delete me and command below if this table name is invalid
CREATE TABLE orders (); -- fine

-- Delete me and command below if this table name is invalid
CREATE TABLE service_rendered_by_other_provider (); -- delete name too long

-- Delete me and command below if this table name is invalid
CREATE TABLE 2for1 (); -- delete has numbers in table name

-- Two tables and a foreign key connection

-- Define the business_type table below
CREATE TABLE business_type (
	id serial PRIMARY KEY,
  	description TEXT NOT NULL
);

-- Define the applicant table below
CREATE TABLE applicant (
	id serial PRIMARY KEY,
  	name TEXT NOT NULL,
  	zip_code CHAR(5) NOT NULL,
  	business_type_id INTEGER references business_type(id) -- FOREIGN KEY
);

-- CREATING SCHEMAS
-- to organise components of a db > data to be housed in a single db while havving compnents of a business that are represented in the db spereated form each other through use of no: of schemas
-- restrictions: length 32 < ; begins with letter or underscore ; cannot begin with pg

-- Create 3 schemas, one for web developer Ann Simmons, one for data analyst Ty Beck, and one for production data (named production). Use a name_lastname format to name the employee schemas.

-- Add a schema for Ann Simmons
CREATE SCHEMA Ann_Simmons;

-- Add a schema for Ty Beck
CREATE SCHEMA ty_beck;

-- Add a schema for production data
CREATE SCHEMA production;

-- The public schema
-- The public schema of a PostgreSQL database is created by default when a new database is created. All users by default have access to this schema unless this access is explicitly restricted.
-- Create a table named users (to represent listeners of podcasts on the platform) to the pod database such that it is added to the public schema.

-- Add users table to the public schema for the pod database
CREATE TABLE public.users ( -- can also just use CREATE TABLE users as it will go to public schema by default
  id serial PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  hashed_password CHAR(72) NOT NULL
);

-- Creating tables in existing schemas

-- The SBA provides twelve different funding opportunities. Two popular programs are the 7a and 504 programs. 
-- These loans have different purposes where 504 loans are typically used for real estate purchases and 7a loans are typically for general business needs.
-- tasked with the creation of tables which share a name but allow for different structures within their respective schemas.
-- The schemas for these loans have already been created for you (named loan_7a and loan_504, respectively).
-- You will now put your knowledge to use to add new tables to these existing schemas.

-- Create a table named 'bank' in the 'loan_504' schema
CREATE TABLE loan_504.bank (
    id serial PRIMARY KEY,
    name VARCHAR (100) NOT NULL
);

-- Create a table named 'bank' in the 'loan_7a' schema
CREATE TABLE loan_7a.bank (
    id serial PRIMARY KEY,
    name VARCHAR (100) NOT NULL,
  	express_provider BOOLEAN
);

-- Create a table named 'borrower' in the 'loan_504' schema
CREATE TABLE loan_504.borrower (
    id serial PRIMARY KEY,
    full_name VARCHAR (100) NOT NULL
);

-- Create a table named 'borrower' in the 'loan_7a' schema
  CREATE TABLE loan_7a.borrower (
    id serial PRIMARY KEY,
    full_name VARCHAR (100) NOT NULL,
  	individual BOOLEAN
);

-- CHAPTER 2 - PostgreSQL Data Types

-- TEXT
-- NUMERIC
-- TEMPORAL (date timestamp data)
-- BOOLEAN
-- OTHER

-- Matching data representations and categories

/* 

numeric:
- height of customer for clothing business
- amount fo coffee ordered from distributer

bolean:
- whether bakery is vegan or not
- whether plastic is recyclable or not

temporal:
- length of a movie
- customers wedding anniversary

*/

-- Choosing data types at table creation
-- Complete the CREATE TABLE command for the project table using the correct data type from the following choices: TEXT, BOOLEAN, and NUMERIC.

-- Create the project table
CREATE TABLE project (
	-- Unique identifier for projects
	id SERIAL PRIMARY KEY,
    -- Whether or not project is franchise opportunity
	is_franchise BOOLEAN DEFAULT FALSE,
	-- Franchise name if project is franchise opportunity
    franchise_name TEXT DEFAULT NULL,
    -- State where project will reside
    project_state TEXT,
    -- County in state where project will reside
    project_county TEXT,
    -- District number where project will reside
    congressional_district NUMERIC,
    -- Amount of jobs projected to be created
    jobs_supported NUMERIC
);

-- Defining text columns
-- TEXT = most flexible any amount of characters of string
-- VARCHAR(N) = varying amount of characters (N) of string
-- CHAR(N) = strings right padded with spaces to ensure it is exactly N characters i.e. CHAR(8) JORDAN BECOMES JORDAN__

/*
Matching text types

CHAR(N)
- 2 character code for storage locations in warehouse
- 9 digit employee identification number assigned to businesses

VARCHAR(N)
- 75 max character length title of podcasts
- 100 max character length for community programmes

TEXT
- column to store searchable text of court transcripts
- column to represent the content of emails for email service provider
*/

-- SBA appeals table
-- Create a table named appeal which includes a unique identifier,id, as well as a column named content allowing the storage of as much text as required for the applicant to make her case.

-- Create the appeal table
CREATE TABLE appeal (
    -- Specify the unique identifier column
	id SERIAL PRIMARY KEY,
    -- Define a column for holding the text of the appeals
    content TEXT NOT NULL
);

-- Using integer types
-- Complete the definition of the client table using the most appropriate integer type to support the range of possible data values for the column.

-- Create the client table
CREATE TABLE client (
	-- Unique identifier column
	id serial PRIMARY KEY,
    -- Name of the company
    name VARCHAR(50),
	-- Specify a text data type for variable length urls
	site_url VARCHAR(50),
    -- Number of employees (max of 1500 for small business)
    num_employees SMALLINT,
    -- Number of customers
    num_customers INTEGER
);

-- Supporting an SBA marketing campaign
/*
 - an id column to assign a unique identifier to each campaign
 - a name column restricted to 50 characters in length
 - a budget column that is restricted to monetary values less than $100,000
 - a num_days column to indicate the length in days of the campaign (typically 180 days or less)
 - a goal_amount column to track the target number of applications
 - a num_applications column to track the number applications received
*/

-- Create the campaign table
CREATE TABLE campaign (
  -- Unique identifier column
  id serial PRIMARY KEY,
  -- Campaign name column
  name VARCHAR(50),
  -- The campaign's budget
  budget NUMERIC(7, 2), -- I.E. 99,999.99 has precision of 7 and scale of 2 NUMERIC(Precision (num total digits), Scale (dp))
  -- The duration of campaign in days
  num_days SMALLINT DEFAULT 30,
  -- The number of new applications desired
  goal_amount INTEGER DEFAULT 100,
  -- The number of received applications
  num_applications INTEGER DEFAULT 0
);

-- Revisiting the appeals table

CREATE TABLE appeal (
	id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
  	-- Add received_on column
    received_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	
  	-- Add approved_on_appeal column
  	approved_on_appeal BOOLEAN DEFAULT NULL,
  	
  	-- Add reviewed column
    reviewed DATE
);

-- Boolean defaults
-- For each of the BOOLEAN data values described below, choose the best default value for the column when defining a table including this column.

/*

DEFAULT = TRUE
-- poisonous column of a table in a db of exotic plants

DEFAULT = FALSE
-- is_recyclable col of db for household materials
-- is_closed col of course table in a uni catalog db idicating if course is full

*/

-- Choosing data types representations

-- Create the loan table
CREATE TABLE loan (
    borrower_id INTEGER REFERENCES borrower(id),
    bank_id INTEGER REFERENCES bank(id),
  	-- 'approval_date': the loan approval date
    approval_date DATE NOT NULL DEFAULT CURRENT_DATE,
    -- 'gross_approval': amounts up to $5,000,000.00
  	gross_approval DECIMAL(9, 2) NOT NULL,
  	-- 'term_in_months': total # of months for repayment
    term_in_months SMALLINT NOT NULL,
    -- 'revolver_status': TRUE for revolving line of credit
  	revolver_status BOOLEAN NOT NULL DEFAULT FALSE,
  	initial_interest_rate DECIMAL(4, 2) NOT NULL
);

-- CHAPTER 3 - Database Normalisation

-- normalisation = ensures data integrity and protect from data anaomolies
-- duplication of data in different tables can be problematic i.e. if 2 different entities have the same name in 2 different tables. 
-- i.e. different football team but have same acronym (abbreviation) difficult to determine which team is referenced in one of the tables
-- also name changes will be difficult to monitor as you have to do this is all the tables where they exist

-- Reducing data redundancy

-- A previous employee of the Small Business Administration developed an initial version of the database. 
-- Location information is utilized throughout the database for borrowers, banks, and projects. 
-- Each of the corresponding tables for these entities utilizes city, state, and zip_code columns creating redundant data. 
-- It is your responsibility to normalize this location data. You will have the opportunity to put your data normalization knowledge to work for you by creating a place table to consolidate location data.

-- Create the place table
CREATE TABLE place (
  -- Define zip_code column
  zip_code CHAR(5) PRIMARY KEY,
  -- Define city column
  city VARCHAR(50) NOT NULL,
  -- Define state column
  state CHAR(2) NOT NULL
);

CREATE TABLE borrower (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  approved BOOLEAN DEFAULT NULL,
  -- Remove zip_code column (defined below) 
  -- Remove city column (defined below)
  -- Remove state column (defined below)
  -- Add column referencing place table
  place_id CHAR(5) references place(zip_code)
);

-- Improving object-to-data mapping

-- The Small Business Development Center client table was previously defined without the inclusion of a point of contact for the client. 
-- The initial instinct of the database team was to simply add contact_name and contact_email columns to the client table. 
-- However, you object to this plan due to your instincts regarding proper data organization. In the future, a contact might be referenced in multiple tables. 
-- In this exercise, you will define table structures for the client and contact information that better separates the client and contact objects.

-- Create the contact table
CREATE TABLE contact (
  	-- Define the id primary key column
	id SERIAL PRIMARY KEY,
  	-- Define the name column
  	name VARCHAR(50) NOT NULL,
    -- Define the email column
  	email VARCHAR(50) NOT NULL
);

-- Add contact_id to the client table
ALTER TABLE client ADD contact_id INTEGER NOT NULL;

-- Add a FOREIGN KEY constraint to the client table
ALTER TABLE client ADD CONSTRAINT fk_c_id FOREIGN KEY (contact_id) REFERENCES contact(id);

-- 1ST NORMAL FORM 

/*
High school wants to maintain student records in a database
You have following table: 
*/ 
CREATE TABLE student (
id SERIAL PRIMARY KEY,
name VARCHAR(50) NOT NULL,
courses VARCHAR(50) NOT NULL,
home_room SMALLINT NOT NULL
/*
update errors
insertion errors
deletion errors

courses column must be updated if student want to take a different course > duplciate entries of same course may have been entered
i.e. maths, chemistry, spanish, chemistry
also if someone wanted to study 5 subjects this may exceed col length defined in the data type structure of VARCHAR(50)
also, student wants to drop a course (chemistry) > deleting a value from the course col could fail before the value of the col is updated > can lose all values within that col
*/ 

-- 1NF = each record must be unique - no duplicate rows, each cell must hold 1 value

-- satisifes 1NF 

CREATE TABLE student (
student_id INTEGER,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
course VARCHAR(50) NOT NULL,
home_room SMALLINT NOT NULL
);

-- Simplifying database records
-- would like to organize student grades in his courses
-- teacher proposes table structure
CREATE TABLE test_grades (
    student_id INTEGER NOT NULL,
    course_name VARCHAR(50) NOT NULL,
    grades TEXT NOT NULL
);
-- The teacher finds that managing the database with this structure is difficult. 
-- Inserting new grades requires a complex query. 
-- In addition, doing calculations on the grades is not very easy. In this exercise, you will help to put this table in 1st Normal Form (1NF).

-- Create the test_grade table
CREATE TABLE test_grade (
    -- Include a column for the student id
    student_id INTEGER NOT NULL,
  	-- Include a column for the course name
    course_name VARCHAR(50) NOT NULL,
  	-- Add a column to capture a single test grade
    grade NUMERIC NOT NULL
);

-- Too much normalization

-- Recall the definition of the loan table.

CREATE TABLE loan (
    borrower_id INTEGER REFERENCES borrower(id),
    bank_id INTEGER REFERENCES bank(id),
    approval_date DATE NOT NULL DEFAULT CURRENT_DATE,
    gross_approval DECIMAL(9, 2) NOT NULL,
    term_in_months SMALLINT NOT NULL,
    revolver_status BOOLEAN NOT NULL DEFAULT FALSE,
    initial_interest_rate DECIMAL(4, 2) NOT NULL
);

-- A new design for this table has been suggested to satisfy 1NF. The revised table definition replaces approval_date with approval_month, approval_day, and approval_year:

CREATE TABLE loan (
    ...
    approval_month SMALLINT,
    approval_day SMALLINT,
    approval_year SMALLINT,
    ...
);

-- This exercise demonstrates how too much normalization can allow for the insertion of invalid data.
-- FOLLOWING CODE NEEDS TO BE DELETED COMMENT
INSERT INTO loan (
  	borrower_id, bank_id, approval_month, approval_day, -- APPROVAL DAY = 42 MAKES NO SENSE AS NO MONTHS HAVE 42 DAYS IN THEM
  	approval_year, gross_approval, term_in_months,
  	revolver_status, initial_interest_rate
) VALUES (3, 201, 6, 42, 2017, 30015, 60, true, 3.25);

-- KEPT LINES OF CODE 

INSERT INTO loan (
  	borrower_id, bank_id, approval_month, approval_day,
  	approval_year, gross_approval, term_in_months,
  	revolver_status, initial_interest_rate
) VALUES (12, 14, 12, 1, 2013, 421115, 120, false, 4.42);

INSERT INTO loan (
  	borrower_id, bank_id, approval_month, approval_day,
  	approval_year, gross_approval, term_in_months,
  	revolver_status, initial_interest_rate
) VALUES (19, 5, 8, 19, 2018, 200000, 120, false, 6.3);

-- 2NF 

-- SCHOOL ADMIN WOULD LIKE TO MANAGE TEXTBOOKS USED IN EACH CLASSES
CREATE TABLE textbook (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
publishername VARCHAR(100) NOT NULL,
publisher_site VARCHAR(50),
quantity SMALLINT NOT NULL DEFAULT 0
);

-- problems:

/*
1. if url is changed then multiple values in the publisher_site colm will need to be updated = inconsistency
2. if school admin wants to carry new texbooks by different publishers you cannot add it because no titles are currently carried by the school relating to that publisher
3. removing data has problems causing data anomolies i.e. school no longer wants to use a particualr book by a particular publisher but its the only book by that publisher which will delete all records of that publsuher
*/

-- 2NF = satisfies 1NF + if Primary key is 1 column then table is 2NF, if there is a composite key (PK mad eup of 2+ columns) then each non-key column must be dependent on all keys
-- need to seperate textbook from publisher

CREATE TABLE textbook (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
quantity SMALLINT NOT NULL DEFAULT 0,
publisher_id INTEGER REFERENCES publisher(id)
);

CREATE TABLE publisher (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
site VARCHAR(50)
);

-- Designing a course table

-- The school's administration decides to use its database to store course details. 
-- Given that this is the first attempt at building the database, they are unsure of which columns to include in the course table. 
-- Below is a list of possible columns and a description of the data type for each. 
-- In this exercise, you will choose the appropriate columns for this table from the list of possible column choices:

/*
id = PK
name = COURSE NAME
meeting_time = MEETING TIME OF COURSE
student_name = NAME
max_students = MAX STUDENT ENROL
*/

-- each record must be unique - no duplicate rows, each cell must hold 1 value
-- Primary key is 1 column

-- student_name should be in different table as students can take multiple courses so id will have same values in different rows
-- meeting_time could technically be in the course table

-- Create the course table
CREATE TABLE course (
    -- Add a column for the course table
	  id SERIAL PRIMARY KEY,
  	-- Add a column for the course table
  	name VARCHAR(50) NOT NULL,
  	-- Add a column for the course table
  	max_students SMALLINT
);

-- Streamlining meal options

-- The cafeteria staff hears about all of the great work happening at the high school to organize data for important aspects of school operations. 
-- This group now wants to join these efforts. In particular, the staff wants to keep track of the different meal options that are available throughout the school year. 
-- With the help of the IT staff, the following table is defined for this purpose:

CREATE TABLE meal (
    id INTEGER,
    name VARCHAR(50) NOT NULL
    ingredients VARCHAR(150), -- comma seperated list
    avg_student_rating NUMERIC,
    date_served DATE,
    total_calories SMALLINT NOT NULL
);

-- Using your knowledge of database normalization, you will provide a better design for the meal table.

CREATE TABLE ingredient (
  -- Add PRIMARY KEY for table
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE meal (
    -- Make id a PRIMARY KEY
	id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
	-- Remove the 2 columns (below) that do not satisfy 2NF
    avg_student_rating NUMERIC,
    total_calories SMALLINT NOT NULL
);

/*
removed:
ingredients VARCHAR(150), -- comma separated list = should already be in ingredients name (duplication)
date_served DATE, = can lead to data redundancy if same meal served multiple times duplciating rows

*/

CREATE TABLE meal_date (
    -- Define a column referencing the meal table
  	meal_id INTEGER REFERENCES meal(id),
    date_served DATE NOT NULL
);

CREATE TABLE meal_ingredient (
  	meal_id INTEGER REFERENCES meal(id),
    -- Define a column referencing the ingredient table
    ingredient_id INTEGER REFERENCES ingredient(id)
);

-- 3NF

-- 3NF = satisfies 2NF + no transitive dependencies = non-primary key columns cant depend on other non-key columns
-- Identifying transitive dependencies
-- Imagine that a nation-wide database of schools exists. Someone who is unfamiliar with database normalization proposes the following structure for the school table:

CREATE TABLE school (
    id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code INTEGER NOT NULL
)

-- Identify the transitive dependency introduced by this table definition.
-- zip_code determines city and state.

-- Table definitions for 3rd Normal Form

-- Recall the definition of the school table from the previous exercise:

CREATE TABLE school (
    id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code INTEGER NOT NULL
)

-- We can define a new table called zip to help satisfy 3rd Normal Form.

-- Complete the definition of the table for zip codes
CREATE TABLE zip (
	code INTEGER PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL
);

-- Complete the definition of the "zip_code" column
CREATE TABLE school (
	id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    zip_code INTEGER REFERENCES zip(code)
);

-- Working through the normalization process

-- practice normalizing database tables related to the Small Business Association loan program:
/*
 - a borrower table will be altered to satisfy the requirements for 1st Normal Form (1NF)
 - a bank and a loan table will be altered to satisfy the requirements for 2nd Normal Form (2NF)
 - the loan table will be altered again to satisfy the requirements for 3rd Normal Form (3NF)
*/

-- the borrower table is not currently in 1NF

CREATE TABLE borrower (
    id serial PRIMARY KEY,
    full_name VARCHAR (100) NOT NULL
);

-- Add new columns to the borrower table
ALTER TABLE borrower
ADD COLUMN first_name VARCHAR (50) NOT NULL,
ADD COLUMN last_name VARCHAR (50) NOT NULL;

-- Remove column from borrower table to satisfy 1NF
ALTER TABLE borrower
DROP COLUMN full_name;

-- The loan table contains a bank_zip column. The bank table is defined below:

CREATE TABLE bank (
    id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Add a new column named 'zip' to the 'bank' table 
ALTER TABLE bank
ADD COLUMN zip VARCHAR(10) NOT NULL;

-- Remove corresponding column from 'loan' to satisfy 2NF
ALTER TABLE loan
DROP COLUMN bank_zip;

-- Define 'program' table with max amount for each program
CREATE TABLE program (
  	id serial PRIMARY KEY,
  	description text NOT NULL,
  	max_amount DECIMAL(9,2) NOT NULL

-- The max_amount of a loan depends only on the loan's program. 
-- The max_amount of a loan can be determined using a foreign key reference to the program table, program_id, removing the need for the program column. 
-- Alter loan to satisfy 3NF.


-- Alter the 'loan' table to satisfy 3NF
ALTER TABLE loan
ADD COLUMN program_id INTEGER REFERENCES program (id), 
DROP COLUMN program,
DROP COLUMN max_amount;

-- CHAPTER 4 - Access Control in PostgreSQL

-- Superuser = administers the DB / create DB / Drop DB / Inserting and deleting records

-- Creating a new user

-- Create sgold with a temporary password
CREATE USER sgold WITH PASSWORD 'changeme';

-- Update the password for sgold
ALTER USER sgold WITH PASSWORD 'kxqr478-?egH%&FQ';

-- Roles and Privaliges
-- users can be given access to database objects such as tables and schemas
-- when creating db object, the user that created the object owns it > they can grant priviliges to access it
-- modifying structure of the table requires ownership of the table unless grant superuser privilige >> ALTER TABLE tablename OWNER TO username

-- Granting user privileges

-- Grant the INSERT privilege on the loan table to the sgold role.
GRANT INSERT ON loan TO sgold; -- to insert data in the table

-- Grant the UPDATE privilege on the loan table to the sgold role.
GRANT UPDATE ON loan TO sgold; -- to update table properties

-- Grant the SELECT privilege on the loan table to the sgold role.
GRANT SELECT ON loan TO sgold; -- to perform select queries on db

-- Grant the DELETE privilege on the loan table to the sgold role.
GRANT DELETE ON loan TO sgold; -- to delet records from db

-- Using the granted privileges
-- now that INSERT, UPDATE, SELECT AND DELETE PRIVILIGE Sandra nowrequires to alter the loan table such that
ALTER TABLE loan DROP COLUMN approval_date;
ALTER TABLE loan ADD COLUMN approval_dt DATETIME;

-- Make sgold the owner of the loan table so that Sandra can execute the ALTER TABLE commands above.
ALTER TABLE loan OWNER TO sgold;

-- HIERACHICAL ACCESS CONTROL

-- While a role is a type of individual the group role manages priilages for sets of users

-- Working with users and groups

/*
Sandra is now leading the team and recently hired 3 new developers. 
Before the new developers begin their first days on the job, Sandra would like to create database accounts for each user and give each account the same access privileges.
*/

-- Create a user account for Ronald Jones
CREATE USER rjones WITH PASSWORD 'changeme';

-- Create a user account for Kim Lopez
CREATE USER klopez WITH PASSWORD 'changeme';

-- Create a user account for Jessica Chen
CREATE USER jchen WITH PASSWORD 'changeme';

-- Create the dev_team group
CREATE GROUP dev_team;

-- Grant privileges to dev_team group on loan table
GRANT INSERT, UPDATE, DELETE, SELECT ON loan TO dev_team;

-- Add the new user accounts to the dev_team group
ALTER GROUP dev_team ADD USER rjones, klopez, jchen;

-- Schema privileges

/*
The new software development team members are eager to get started on the loan management project. 
But Sandra, as the team lead, is not comfortable with so many people having direct access to the production version of the loan database (in the public schema).
set up a development environment that is separated from the production environment. 
*/

-- Create the development schema
CREATE SCHEMA development;

-- Grant usage privilege on new schema to dev_team
GRANT USAGE ON SCHEMA development TO dev_team;

-- Create a loan table in the development schema
CREATE TABLE development.loan (
	borrower_id INTEGER,
	bank_id INTEGER,
	approval_date DATE,
	program text NOT NULL,
	max_amount DECIMAL(9,2) NOT NULL,
	gross_approval DECIMAL(9, 2) NOT NULL,
	term_in_months SMALLINT NOT NULL,
	revolver_status BOOLEAN NOT NULL,
	bank_zip VARCHAR(10) NOT NULL,
	initial_interest_rate DECIMAL(4, 2) NOT NULL
);

-- Grant privileges on development schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA development TO dev_team;

-- REMOVING PRIVILIGES

-- Remove the specified privileges for Kim
REVOKE INSERT, UPDATE, DELETE ON development.loan FROM klopez;

-- Rescinding group membership

/*
The technology team at the SBA would like to be more proactive in assigning database access by group. 
Each user account must belong to at least one group. All project managers will be members of a project_management group. 
Therefore, Kim Lopez, should be added to this account and removed from the dev_team group
*/

-- Create the project_management group
CREATE GROUP project_management;

-- Grant project_management SELECT privilege
GRANT SELECT ON loan TO project_management;

-- Add Kim's user to project_management group
ALTER GROUP project_management ADD USER klopez;

-- Remove Kim's user from dev_team group
REVOKE dev_team FROM klopez;

-- Implementing access control for teams

/*
While your team members are likely responsible individuals, accidents can happen. You should only give these team members as much control over the database as required to do their job. These team members will have access to data on loans that have not been approved.

The schema analysis will be created.
The table unapproved_loan will be defined in this new schema.
User data_scientist will be created.
The user will be restricted to reading from the new table.
*/

-- Create the new analysis schema
CREATE SCHEMA analysis;

-- Create a table unapproved loan under the analysis schema
CREATE TABLE analysis.unapproved_loan (
    id serial PRIMARY KEY,
    loan_id INTEGER REFERENCES loan(id),
    description TEXT NOT NULL
);

-- Create 'data_scientist' user with password 'changeme'
CREATE USER data_scientist WITH PASSWORD 'changeme';

-- Give 'data_scientist' ability to use 'analysis' schema
GRANT USAGE ON SCHEMA analysis TO data_scientist;

-- Grant read-only access to table for 'data_scientist' user
GRANT SELECT ON analysis.unapproved_loan TO data_scientist;