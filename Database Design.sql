-- DATABASE DESIGN

-- CHAPTER 1 - PROCESSING, STORING AND ORGANISING DATA

/* 

Q) how should we manage and use our data?

schemas = how should data by logically organised
normalisation = should data have mnimal dependency and redundancy
views = what joins will be done most often
access controls = should all users of data have same level of access
DBMS = how do i pick between SQL and noSQL options and more..


APPROACHES TO PROCESSING DATA, THE WAY DATA IS GOING TO FLOW, STRUCTURED AND STORED
OLTP = ONLINE TRANSACTION PROCESSING (find price of books)
1. typically uses an operational database
2. data is inserted and updated more often
3. most likely to have data from the past hour

OLAP = ONLINE ANALYTICAL PROCESSING (calculate books with best profit margin)
1. typically uses a data warehouse
2. helps businesses with deciion making and solving problems
3. queries a larger amount of data

*/

/* 
The city of Chicago receives many 311 service requests throughout the day. 
311 service requests are non-urgent community requests, ranging from graffiti removal to street light outages. 
Chicago maintains a data repository of all these services organized by type of requests.

Data Processing approach = OLTP because table structure appears to require frequent updates
*/

/*
Storing Data
1. structured data =  follows a schema, defined data types and relationships e.g. sql 
relational db with latest withdrawals and deposits made by clients

2. unstructured data = schemaless - data in its rawess form - makes up most of data in the world i.e. photos, chat logs
zip file of all text msg ever received
to do notes in text editor
images in photo library

3. semi-structured data = does not follow a larger schema, has ad-hoc self describing structure e.g. nosql, json, xml
json object outputted in real-time
csv of open data downloaded from local gov website
<note><from>Lis/from><heading>Thanks Ruanne</heading><body>you rock</body></note

Traditional DB = storing real-time reltional structured data OLTP
Data Warehouses = analysing archived structured data OLAP
Data Lakes = storing data of all structures = flexibility and scalability, analysing big data

ETL = Extract transform load

i.e. ecom API outputs real time data transactions > python script drops null rows and clean data > datafram is written into AWS redshift warehouse

ELT = Extract load transform


Data modelling:

1. conceptional data model - entities, attributes and relationships, gathers business requirements
2. logical data model - defines tables, columns and relationships
3. physical data model - defines physical storage
*/

/* 
DIMENSIONAL MODELLING

Fact table - i.e. song table = artist_id, album_id, label_id, genre_id, song_title

- decided by busienss use case
- holds records of a metric
- changes reguarly
- connects to dimenions via foreign keys

Dimension table - i.e. atrist table = artist_id, artist_name, age, gender, nationality

- holds descriptions of attirbutes
- does not change often


EXAMPLE:

Schema:

table name = runs

duration_mins - float
week - int
month - varchar(160)
year - int
park_name - varchar(160)
city_name - varchar(160)
distance_km - float
route_name - varchar(160)

*/

-- Create a route dimension table
CREATE TABLE route(
	route_id INTEGER PRIMARY KEY,
    park_name VARCHAR(160) NOT NULL,
    city_name VARCHAR(160) NOT NULL,
    distance_km FLOAT NOT NULL,
    route_name VARCHAR(160) NOT NULL
);
-- Create a week dimension table
CREATE TABLE week(
	week_id INTEGER PRIMARY KEY,
    week INTEGER NOT NULL,
    month VARCHAR(160) NOT NULL,
    year INTEGER NOT NULL
);

-- Querying the dimensional model

SELECT 
	-- Get the total duration of all runs
	SUM(duration_mins)
FROM 
	runs_fact
-- Get all the week_id's that are from July, 2019
INNER JOIN week_dim ON week_dim.week_id = runs_fact.week_id
WHERE week_dim.month = 'July' and week_dim.year = '2019';

-- CHAPTER 2 - Database, Schemas and Normalisation

/* 
STAR schema = fact table with dimension tables driven off it by 1 demension
i.e. for every field in the fact table there is exactly 1 corresponding dimension table relating to that field

SNOWFLAKE schema = extension of a star schema in that it has more than 1 demnsion this is because the dimension tables are normalised
i.e. demnsion table that has:

dim_store
- store_id
- store_address
- city_id

and a connecting dimensional table called dim_city

dim_city
- city_id
- city
_ state_id

hence 2 dimension here

normalised = technique to reduce redundency by dividing tables into smaller tables and connect them via relationships i.e. above ^
- idea is to identify repeating groups of data and create new tables for them

example where this might be the case
dim_book table
- book_id
- title
- author
- publisher
- genre

Here you are most likley going to have repeated values for:
- author
- publisher
- genre

so you can create dimensional tables for them in a snowwflake schema

*/

-- Running from star to snowflake

-- Adding foreign keys

-- The fact_booksales table has three foreign keys: book_id, time_id, and store_id. 
-- In this exercise, the four tables that make up the star schema below have been loaded. However, the foreign keys still need to be added.

-- Add the book_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_book
    FOREIGN KEY (book_id) REFERENCES dim_book_star (book_id);
    
-- Add the time_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_time
    FOREIGN KEY (time_id) REFERENCES dim_time_star (time_id);
    
-- Add the store_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_store
    FOREIGN KEY (store_id) REFERENCES dim_store_star (store_id);


-- extend the star schema to meet part of the snowflake schema's criteria.
-- Create dim_author with an author column
CREATE TABLE dim_author (
    author VARCHAR(256) NOT NULL
);

-- Insert all the distinct authors from dim_book_star into dim_author.

INSERT INTO dim_author
SELECT DISTINCT author FROM dim_book_star;

-- Create a new table for dim_author with an author column
CREATE TABLE dim_author (
    author varchar(256)  NOT NULL
);

-- Insert authors 
INSERT INTO dim_author
SELECT DISTINCT author FROM dim_book_star;

-- Alter dim_author to have a primary key called author_id.
ALTER TABLE dim_author ADD COLUMN author_id SERIAL PRIMARY KEY;

-- Output the new table
SELECT * FROM dim_author;

-- If  you wanted to get the quantity of all books by Octavia E. Butler sold in Vancouver in Q4 of 2018.
-- On the denormalised schema (star schema) this would require 3 joins
-- On the normalised schema (snowflake schema) this would require 8 joins
-- More joins > slower quiries
-- However, normalisation saves space and reduces daat redundancy as a result as lack of repeated values

-- Other benefits of normlalisation include:
-- Normalisation enforces data consisistancy due to referntial integrity i.e. each state stored once i.e. California not CA or california so eliminated misspelled values
-- Safer updating, removing and inserting i.e. less data redundancy means less records to alter
-- Easier to redesign by entending as smaller tables are easier to extend than larger tables

-- so choosing between normalisation/denormalisation comes down to how read/write intensive your database is going to be
-- OLTP is prefential to normalisation (write intensive as youa re constantly updating information - quicker and safer insertion fo data)
-- OLAP is prefential to denormalisation (read intensive as priorty to analyse data for analytics so faster queries)

-- Querying the star schema

-- Output each state and their total sales_amount
SELECT dim_store_star.state, SUM(sales_amount)
FROM fact_booksales
	-- Join to get book information
    JOIN dim_book_star ON dim_book_star.book_id = fact_booksales.book_id
	-- Join to get store information
    JOIN dim_store_star ON dim_store_star.store_id = fact_booksales.store_id
-- Get all books with in the novel genre
WHERE  
    dim_book_star.genre = 'novel'
-- Group results by state
GROUP BY
    dim_store_star.state;

-- Querying the snowflake schema

-- Output each state and their total sales_amount
SELECT dim_state_sf.state, SUM(fact_booksales.sales_amount)
FROM fact_booksales
    -- Joins for genre
    JOIN dim_book_sf on dim_book_sf.book_id = fact_booksales.book_id
    JOIN dim_genre_sf on dim_genre_sf.genre_id = dim_book_sf.genre_id
    -- Joins for state 
    JOIN dim_store_sf on fact_booksales.store_id = dim_store_sf.store_id 
    JOIN dim_city_sf on dim_city_sf.city_id = dim_store_sf.city_id
	JOIN dim_state_sf on  dim_state_sf.state_id = dim_city_sf.state_id
-- Get all books with in the novel genre and group the results by state
WHERE  
    dim_genre_sf.genre = 'novel'
GROUP BY
    dim_state_sf.state;

-- Updating countries

-- Going through the company data, you notice there are some inconsistencies in the store addresses. 
-- These probably occurred during data entry, where people fill in fields using different naming conventions. 
-- compare the records that need to be updated in order to do this task on the star and snowflake schema
-- The only countries in the database are Canada and the United States, which should be represented as USA and CA

-- Output records that need to be updated in the star schema
SELECT * FROM dim_store_star
WHERE country != 'USA' AND country !='CA';

-- 18 records shown but only 1 record needs to be updated in snowflake schema due to min data redundancy

-- Extending the snowflake schema
-- The company is thinking about extending their business beyond bookstores in Canada and the US. Particularly, they want to expand to a new continent.
-- Luckily, you have a snowflake schema in this scenario.
--  Along with dim_country_sf, a table called dim_continent_sf has been loade

-- Add a continent_id column with default value of 1
ALTER TABLE dim_country_sf
ADD continent_id int NOT NULL DEFAULT(1);

-- Add the foreign key constraint
ALTER TABLE dim_country_sf ADD CONSTRAINT country_continent
   FOREIGN KEY (continent_id) REFERENCES dim_continent_sf(continent_id);
   
-- Output updated table
SELECT * FROM dim_country_sf;

-- normalisation recap = identify repeated groups of data and create new tables for them
-- Normal form levels
-- 1NF = each record must be unique - no duplicate rows, each cell must hold 1 value
-- 2NF = satisfies 1NF + if Primary key is 1 column then table is 2NF, if there is a composite key (PK mad eup of 2+ columns)then each non-key column must be dependent on all keys
-- 3NF = satisfies 2NF + no transitive dependencies = non-primary key columns cant depend on other non-key columns

/* a db that isn't normalised enough is prone to data anolomies
1. update anomaly - i.e. may need to update multiple records associated with student id to update their emila address if studentid is not unique in table, as we scale its harder to keep track of these redundancies
2. insertion anomaly - unable to add a record due to missing attributes unless null values are allowed in other columns within the same table
3. deletion anomaly - delete a record and unintentionally delete other data
*/

-- Converting to 1NF

-- in customers table we have row with multiple values in cars_rented and invoice_id so does not conform to 1NF

-- Create a new table to hold the cars rented by customers
CREATE TABLE cust_rentals (
  customer_id INT NOT NULL,
  car_id VARCHAR(128) NULL,
  invoice_id VARCHAR(128) NULL
);

-- Drop a column from customers table to satisfy 1NF
ALTER TABLE customers
DROP COLUMN cars_rented,
DROP COLUMN invoice_id;

-- Converting to 2NF
-- you created a table holding customer_ids and car_ids. This has been expanded upon and the resulting table, customer_rentals
-- does not conform to 2NF as there are non-key attributes describing the car that only depend on one PK, car_id i.e. model, manurfacturer, type_car, condition, color, these don't depend on customer_id

-- Create a new table to satisfy 2NF
CREATE TABLE cars (
  car_id VARCHAR(256) NULL,
  model VARCHAR(128),
  manufacturer VARCHAR(128),
  type_car VARCHAR(128),
  condition VARCHAR(128),
  color VARCHAR(128)
);

-- Drop columns in customer_rentals to satisfy 2NF
ALTER TABLE customer_rentals
DROP COLUMN model,
DROP COLUMN manufacturer, 
DROP COLUMN type_car,
DROP COLUMN condition,
DROP COLUMN color;

-- Converting to 3NF

-- you created a table holding car_idss and car attributes. 
-- This has been expanded upon. For example, car_id is now a primary key. The resulting table, rental_cars, has been loaded

-- rental_cars does not conform to 3NF as non-primary key columns cant depend on other non-key columns
-- for instance manufacturer and type_car are related to the non-key coloumn model

-- Create a new table to satisfy 3NF
CREATE TABLE car_model(
  model VARCHAR(128),
  manufacturer VARCHAR(128),
  type_car VARCHAR(128)
);

-- Drop columns in rental_cars to satisfy 3NF
ALTER TABLE rental_cars
DROP COLUMN manufacturer, 
DROP COLUMN type_car;

-- CHAPTER 3 - Database Views

-- database views = virtual table that is not part of the pyhsical schema
-- view isnt stored in ohysical memory instead the query to create the view is
-- data is aggrgeated from data in tables
-- no need to retype common queries or alter schemas

/* 
-- benefits
1. dosen't take up storage
2. form of access control i.e. hide sensitive columns and restrict what others can see
3. masks complex queries - useful for highly normalised schemas i.e. snowflake schemas where you had to use multiple joins
*/

-- Viewing views

-- get familiar with viewing views within a database and interpreting their purpose. This is a skill needed when writing database documentation or organizing views.

-- Get all non-systems views
SELECT * FROM INFORMATION_SCHEMA.views
WHERE table_schema NOT IN ('pg_catalog', 'information_schema');

-- Creating and querying a view

-- Create a view for reviews with a score above 9
CREATE VIEW high_scores AS
SELECT * FROM REVIEWS
WHERE score > 9;

-- Count the number of self-released works in high_scores
SELECT COUNT(*) FROM high_scores
INNER JOIN labels ON labels.reviewid = high_scores.reviewid
WHERE label = 'self-released';

-- Granting and revoking access to a view:

/* 
1. Privilages = SELECCT, INSERT, UPDATE, DELETE etc
2. Objects = table, view, schema etc
3. Roles = A db user or group of db users

Dropping a view:
1. RESTRICT = (default) which returns an error if there are objects that depends on the view
2. CASCADE = drops view and any object that depends on that view

Redefinign a view:
1. if a view with view_name exists it is replaced
2. new_query must gen same column names, order and data type as old query
3. column outplut may be different
4. new columns may be added at the end

if the above criteria can't be met > drop existing view and create new one
*/

-- Creating a view from other views

/* 
There are two views of interest in this exercise. 
top_15_2017 holds the top 15 highest scored reviews published in 2017 with columns reviewid,title, and score. 
artist_title returns a list of all reviewed titles and their respective artists with columns reviewid, title, and artist. 
From these views, we want to create a new view that gets the highest scoring artists of 2017.
*/

-- Create a view with the top artists in 2017
CREATE VIEW top_artists_2017 AS
-- with only one column holding the artist field
SELECT 
    artist_title.artist 
FROM 
    artist_title
INNER JOIN 
    top_15_2017
ON 
    top_15_2017.reviewid = artist_title.reviewid;

-- Output the new view
SELECT 
    * 
FROM 
    top_artists_2017;

-- drop command that would drop both top_15_2017 and top_artists_2017
DROP VIEW top_15_2017 CASCADE;

-- this is because top_artists_2017 is dependent on top_15_2017 and CASCADE drops view and any object that depends on that view

-- Granting and revoking access
-- In the case of our Pitchfork reviews, we don't want all database users to be able to write into the long_reviews view. Instead, the editor should be the only user able to edit this view.

-- Revoke all database users' update and insert privileges on the long_reviews view.
REVOKE INSERT, UPDATE ON long_reviews FROM PUBLIC;  

-- Grant the editor user update and insert privileges on the long_reviews view.
GRANT UPDATE, INSERT ON long_reviews TO editor; 

-- Updatable views
-- used the information_schema.views to get all the views in a database. If you take a closer look at this table, you will notice a column that indicates whether the view is updatable

SELECT *
FROM information_schema.views
WHERE is_updatable != 'NO';

-- Redefining a view
-- means modifying the underlying query that makes the view.
-- The artist_title view needs to be appended to include a column for the label field from the labels table.
-- q) Can the CREATE OR REPLACE statement be used to redefine the artist_title view?
-- a) yes, as long as the label column comes at the end

-- Redefine the artist_title view to have a label column
CREATE OR REPLACE VIEW artist_title AS
SELECT reviews.reviewid, reviews.title, artists.artist, labels.label
FROM reviews
INNER JOIN artists
ON artists.reviewid = reviews.reviewid
INNER JOIN labels
ON labels.reviewid = artists.reviewid;

SELECT * FROM artist_title;

-- Materialised views = stores the query results > stored on disk
-- query becomes pre-computed via the view
-- can be refreshed/rematerialised when prompted or scheduled / stored results are updated
-- useful when you have queries with long execution times
-- don't use materialised views for data that is updated often as it will be outdated
-- useful for datawarehouses - OLAP purposes
-- companies use pipeline schedulers such as Airflow to refresh materialised views with consideration to dependences between views

/*
non-materialised views:
1. always resturns up to date data
2. better to use on write intensive db

materialised views:
1. stores query result on disk
2. consumes more storage

Both:
1. can be used in a data warehouse
2. helps reduce overhead of writing queries
*/

-- Creating and refreshing a materialized view

-- Create a materialized view called genre_count 
CREATE MATERIALIZED VIEW genre_count AS
SELECT genre, COUNT(*) 
FROM genres
GROUP BY genre;

INSERT INTO genres
VALUES (50000, 'classical');

-- Refresh genre_count
REFRESH MATERIALIZED VIEW genre_count;

SELECT * FROM genre_count;

-- CHAPTER 4 - Database Management

-- DB roles = login? / create DB / write tables / password / assign roles

-- Create a role

-- Create a data scientist role
CREATE ROLE data_scientist;

-- Create a role called marta that has one attribute: the ability to login (LOGIN).
CREATE ROLE Marta LOGIN;

--Create a role called admin with the ability to create databases (CREATEDB) and to create roles (CREATEROLE).
CREATE ROLE admin WITH CREATEDB CREATEROLE;

-- GRANT privileges and ALTER attributes

-- Grant the data_scientist role update and insert privileges on the long_reviews view.
GRANT UPDATE, INSERT ON long_reviews TO data_scientist;

-- Give Marta's role a password
ALTER ROLE marta WITH PASSWORD 's3cur3p@ssw0rd';

-- Add a user role to a group role

-- Add Marta to the data scientist group
GRANT data_scientist TO MARTA;

-- Celebrate! You hired data scientists.

-- Remove Marta from the data scientist group
REVOKE data_scientist FROM MARTA;

-- Table Partitioning
-- when tables grow > more memory > slower queries/updates > split tables up into smaller parts (partitioning)

-- vertical partitioning > i.e. split up data by columns i.e.

/*
id, name, short_desc, price, long_desc becomes:

1st table: id, name, short_desc, price 
2nd table: id, long_description
*/

-- horizontal partitioning > split data up by rows 


/* 
id, product_id, amount, total_price, timestamp

different tables have the same columns but are defined according to their timestamp  i.e.

1st table from 1/1/24
2nd table 1/5/24
*/

/*
normalisation:
1.changes the logical data model
2. reduces redundancy in a table

vertical partitioning:
1. move specific columns to slower medium
2. more 3rd and 4th col to seperate table

horizontal partitioning:
1. use timestamp to move rows from Q4 in a specific table
2. sharding is an extension on this, using multiple machines

*/

-- Creating vertical partitions

-- Create a new table called film_descriptions (as this is the column we are partitioning)
CREATE TABLE film_descriptions (
    film_id INT,
    long_description TEXT
);

-- Copy the descriptions from the film table
INSERT INTO film_descriptions
SELECT film_id, long_description FROM film;

-- Drop the descriptions from the original table
ALTER TABLE film DROP COLUMN long_description;

-- Join to view the original table
SELECT * FROM film 
JOIN film_descriptions USING(film_id);

-- Creating horizontal partitions
-- you'll be using a list partition instead of a range partition. For list partitions, you form partitions by checking whether the partition key is in a list of values or not.

-- Create the table film_partitioned, partitioned on the field release_year.

CREATE TABLE film_partitioned (
  film_id INT,
  title TEXT NOT NULL,
  release_year TEXT
)
PARTITION BY LIST (release_year);

-- Create the partitions for 2019, 2018, and 2017
CREATE TABLE film_2019
	PARTITION OF film_partitioned FOR VALUES IN ('2019');
    
CREATE TABLE film_2018
	PARTITION OF film_partitioned FOR VALUES IN ('2018');
    
CREATE TABLE film_2017
	PARTITION OF film_partitioned FOR VALUES IN ('2017');

-- Insert the data into film_partitioned
INSERT INTO film_partitioned
SELECT film_id, title, release_year FROM film;

-- View film_partitioned
SELECT * FROM film_partitioned;

-- data integration = COMBINES DATA FROM DIFFERENT SOURCES, FORMATS, TECHNILOGIES TO PROVIDE USERS WITH TRANSLATED AND UNIFIED VIEW DATA

/*
DATA Integration summary:

TRUE:
- Being able to access the desired data through a single view does not mean all the data is stored together
- Data in the final view can be updated in different intervals
- you should be careful choosing a hand-coded solution because maintenance costs
- my source data can be stored in different physical locations
- data integration should be business driven i.e. what combinations of data will be useful for the business
- my source data can be in different formats and database management systems

FALSE:
- automated testing and proactive alerts are not needed
- after data integration all your data should be in a single table
- your data integration solution, hand-coded or ETL tool, should work once and then you ccan use the resulting view to run queries forever
- all your data has to be updated in real time in the final view
- everybody should have access to sensitive data in the final view
- you should choose whichever solution is right for the job right now
*/

-- DB Management systems = software for creating and maintaining db which serves as interface between db and end users:
-- data
-- db schema (structure)
-- db engine (allows access, locked and modified)

-- 2 types:
-- SQL dbms = relational dbms based on relational model of data employ sql for managing and accessing data (postgresql/oracle/sqlserver)
-- best option when data is structured and unchanging, data must be consistent
-- Example: banking app where its extremely important that data integrity is ensured

-- NoSQL dbms
-- best option when data is less structured, document centered than table centered, dont have to fit into well defined rows and columns, good for companies experiening rapid growth and no clear schema definitions who analyse large quantities of data or manage data structures that vary
-- types = key value store, doc store, columnar db, graphical db
-- Example: social media tool that provides users with opportunity to grow their networks via connections
-- Data warehousing on big data
-- during the holiday shopping season, an e-commerce website needs to keep track of millions of shopping carts
-- Blog that needs to create and incorporate new types of content such as images, comments and videos