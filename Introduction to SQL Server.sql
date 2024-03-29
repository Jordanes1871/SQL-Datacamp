-- Introduction to SQL Server

-- Chapter 1 - SELECTion Box

-- sql server - relational db developed by microsoft
-- T-SQL - Microsoft implementation of SQL with additional functionality

-- Limit the number of rows returned
SELECT 
  top (50) points 
FROM 
  eurovision;

-- Return unique countries and use an alias
SELECT 
  DISTINCT country AS unique_country 
FROM 
  eurovision;

-- return only half the rows using 'TOP', using the same shortcut as before to return all columns.

-- Return all columns, restricting the percent of rows returned
SELECT 
  TOP (50) PERCENT * 
FROM 
  eurovision;


-- Select the top 20 rows from description, nerc_region and event_date
SELECT 
  TOP (20) description,
  nerc_region,
  event_date
FROM 
  grid 
  -- Order by nerc_region, affected_customers & event_date
  -- Event_date should be in descending order
ORDER BY
  nerc_region,
  affected_customers,
  event_date DESC;

-- Select description and event_year
SELECT 
  description, 
  event_year 
FROM 
  grid 
  -- Filter the results
WHERE 
  description = 'Vandalism';

-- Select nerc_region and demand_loss_mw
SELECT 
  nerc_region, 
  demand_loss_mw 
FROM 
  grid 
-- Retrieve rows where affected_customers is >= 500000  (500,000)
WHERE 
  affected_customers >= 500000 ;

-- Select description and affected customers
SELECT 
  description, 
  affected_customers 
FROM 
  grid 
  -- Retrieve rows where the event_date was the 22nd December, 2013    
WHERE 
  event_date = '2013-12-22';

-- Select description, affected_customers and event date
SELECT 
  description, 
  affected_customers,
  event_date
FROM 
  grid 
  -- The affected_customers column should be >= 50000 and <=150000   
WHERE 
  affected_customers BETWEEN 50000
  AND 150000 
   -- Define the order   
ORDER BY 
  event_date DESC;

-- Working with NULL values

-- Retrieve all columns
SELECT 
  * 
FROM 
  grid 
  -- Return only rows where demand_loss_mw is missing or unknown  
WHERE 
  demand_loss_mw IS NULL;

-- Retrieve all columns
SELECT 
  * 
FROM 
  grid 
  -- Return rows where demand_loss_mw is not missing or unknown   
WHERE 
  demand_loss_mw IS NOT NULL;

-- Retrieve the song,artist and release_year columns
SELECT 
  song, 
  artist, 
  release_year 
FROM 
  songlist 
  -- Ensure there are no missing or unknown values in the release_year column
WHERE 
  release_year IS NOT NULL 
  -- Arrange the results by the artist and release_year columns
ORDER BY 
  artist, 
  release_year;

-- WHERE CLAUSES

SELECT 
  song, 
  artist, 
  release_year
FROM 
  songlist 
WHERE 
  -- Retrieve records greater than and including 1980
  release_year >= 1980 
  -- Also retrieve records up to and including 1990
  AND release_year <= 1990 
ORDER BY 
  artist, 
  release_year;


-- USING OR
SELECT 
  song, 
  artist, 
  release_year
FROM 
  songlist 
WHERE 
  -- Retrieve records greater than and including 1980
  release_year >= 1980 
  -- Replace AND with OR
  OR release_year <= 1990 
ORDER BY 
  artist, 
  release_year;


-- Select all artists beginning with B who released tracks in 1986, but also retrieve any records where the release_year is greater than 1990.

SELECT 
  artist, 
  release_year, 
  song 
FROM 
  songlist 
  -- Choose the correct artist and specify the release year
WHERE 
  (
    artist LIKE 'B%' 
    AND release_year = 1986
  ) 
  -- Or return all songs released after 1990
  OR release_year > 1990 
  -- Order the results
ORDER BY 
  release_year, 
  artist, 
  song;

-- Chapter 2 - Groups, strings and counting things

-- Summing

-- Sum the demand_loss_mw column
SELECT 
  SUM(demand_loss_mw) AS MRO_demand_loss 
FROM 
  grid 
WHERE
  -- demand_loss_mw should not contain NULL values
  demand_loss_mw IS NOT NULL
  -- and nerc_region should be 'MRO';
  AND nerc_region = 'MRO';

-- COUTNING

-- Obtain a count of 'grid_id'
SELECT 
  COUNT(grid_id) AS RFC_count
FROM 
  grid
-- Restrict to rows where the nerc_region is 'RFC'
WHERE
  nerc_region = 'RFC';

-- MIN, MAX and AVG

-- Find the maximum number of affected customers
SELECT 
  MIN(affected_customers) AS min_affected_customers 
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE 
  demand_loss_mw IS NOT NULL;

-- Find the maximum number of affected customers
SELECT 
  MAX(affected_customers) AS max_affected_customers 
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE 
  demand_loss_mw IS NOT NULL;

-- Find the average number of affected customers
SELECT 
  AVG(affected_customers) AS avg_affected_customers 
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE 
  demand_loss_mw IS NOT NULL;

-- STRINGS

-- LEN(col_name) = length of string
-- LEFT(col_name, no_char_to_extract) = extract no: char from left side of string
-- RIGHT(col_name, no_char_to_extract) = extract no: char from right side of string
-- CHARINDEX('GHJF', COL_NAME) = identify specific characters within column
-- SUBSTRING(col_name, no.char to start from, no: char to extract)
-- REPLACE(col_name, 'a', 'b') = replace a with b in col_name

-- Calculate the length of the description column
SELECT 
  LEN (description) AS description_length 
FROM 
  grid;

-- Select the first 25 characters from the left of the description column
SELECT 
  LEFT(description, 25) AS first_25_left 
FROM 
  grid;

-- Amend the query to select 25 characters from the  right of the description column
SELECT 
  RIGHT(description, 25) AS last_25_right 
FROM 
  grid;

-- You can use CHARINDEX to find a specific character or pattern within a column. Edit the query to return the CHARINDEX of the string 'Weather' whenever it appears within the description column.
-- Now we use SUBSTRING to return everything after Weather for the first ten rows. The start index here is 15, because the CHARINDEX for each row is 8, and the LEN of Weather is 7.

-- Complete the substring function to begin extracting from the correct character in the description column
SELECT TOP (10)
  description, 
  CHARINDEX('Weather', description) AS start_of_string, 
  LEN ('Weather') AS length_of_string, 
  SUBSTRING(
    description, 
    15, 
    LEN(description) 
  ) AS additional_description 
FROM 
  grid
WHERE description LIKE '%Weather%';

-- GROUPING AND HAVING

-- Select the region column
SELECT 
  nerc_region,
  -- Sum the demand_loss_mw column
  SUM(demand_loss_mw) AS demand_loss
FROM 
  grid
  -- Exclude NULL values of demand_loss
WHERE 
  demand_loss_mw IS NOT NULL
  -- Group the results by nerc_region
GROUP BY
  nerc_region
  -- Order the results in descending order of demand_loss
ORDER BY 
  demand_loss DESC;

SELECT 
  nerc_region, 
  SUM (demand_loss_mw) AS demand_loss 
FROM 
  grid 
  -- Remove the WHERE clause
WHERE demand_loss_mw  IS NOT NULL
GROUP BY 
  nerc_region 
  -- Enter a new HAVING clause so that the sum of demand_loss_mw is greater than 10000
HAVING 
  SUM(demand_loss_mw) > 10000 
ORDER BY 
  demand_loss DESC;

--EUROVISION TASK

SELECT 
  country, 
  COUNT (country) AS country_count, 
  AVG (place) AS avg_place, 
  AVG (points) AS avg_points, 
  MIN (points) AS min_points, 
  MAX (points) AS max_points 
FROM 
  eurovision 
GROUP BY 
  country 
  -- The country column should only contain those with a count greater than 5
HAVING 
  COUNT(country) > 5 
  -- Arrange columns in the correct order
ORDER BY 
  avg_place, 
  avg_points DESC;

-- Chapter 3 - Joining Tables

-- Inner Joins - a perfect match

SELECT 
  track_id,
  name AS track_name,
  title AS album_title
FROM track
  -- Complete the join type and the common joining column
INNER JOIN album on track.album_id = album.album_id;

-- Select album_id and title from album, and name from artist
SELECT 
  album_id,
  title,
  artist.name AS artist
  -- Enter the main source table name
FROM album
  -- Perform the inner join
INNER JOIN artist on album.artist_id = artist.artist_id;

-- join 3 tables

SELECT track_id,
-- Enter the correct table name prefix when retrieving the name column from the track table
  track.name AS track_name,
  title as album_title,
  -- Enter the correct table name prefix when retrieving the name column from the artist table
  artist.name AS artist_name
FROM track
  -- Complete the matching columns to join album with track, and artist with album
INNER JOIN album on track.album_id = album.album_id 
INNER JOIN artist on album.artist_id = artist.artist_id;

-- LEFT join

SELECT 
  invoiceline_id,
  unit_price, 
  quantity,
  billing_state
  -- Specify the source table
FROM invoiceline
  -- Complete the join to the invoice table
LEFT JOIN invoice ON
invoiceline.invoice_id = invoice.invoice_id;

-- RIGHT JOIN

SELECT 
  album.album_id,
  title,
  album.artist_id,
  artist.name as artist
FROM album
INNER JOIN artist ON album.artist_id = artist.artist_id
-- Perform the correct join type to return matches or NULLS from the track table
RIGHT JOIN track on track.album_id = album.album_id
WHERE album.album_id IN (213,214)

-- UNION AND UNION ALL

-- need to have same data types in the same order and same number of cols in each table to combine - note the field names can be diffeent but you need to alias to make them the same
-- UNION = does not return duplicate rows
-- UNION ALL = union all return duplicate rows

-- Join the UNION

SELECT 
  album_id AS ID,
  title AS description,
  'Album' AS Source
  -- Complete the FROM statement
FROM album
 -- Combine the result set using the relevant keyword
UNION
SELECT 
  artist_id AS ID,
  name AS description,
  'Artist'  AS Source
  -- Complete the FROM statement
FROM artist;

-- Chapter 4 - You've got the power

-- CRUD operations:

/*
CREATE = db tables and views, users, permissions, security groups
READ = select statements (reading the data)
UPDATE = ammend existing db records
DELETE = tables
*/

-- Create tables

-- Create the table
CREATE TABLE results (
	-- Create track column
	track VARCHAR(200),
    -- Create artist column
	artist VARCHAR(120),
    -- Create album column
	album VARCHAR(160),
	-- Create track_length_mins
	track_length_mins INT,
	);

-- Select all columns from the table
SELECT 
  track, 
  artist, 
  album, 
  track_length_mins 
FROM 
  results;

-- INSERT SOME DATA INTO YOUR NEWLY DEFINED TABLE

-- Create the table
CREATE TABLE tracks(
  -- Create track column
  track VARCHAR(200), 
  -- Create album column
  album VARCHAR(160), 
  -- Create track_length_mins column
  track_length_mins INT
);
-- Complete the statement to enter the data to the table         
INSERT INTO tracks
-- Specify the destination columns
(track, album, track_length_mins)
-- Insert the appropriate values for track, album and track length
VALUES
  ('Basket Case', 'Dookie', 3);
-- Select all columns from the new table
SELECT 
  *
FROM 
  tracks;

-- Update

-- You may sometimes have to update the rows in a table. For example, in the album table, there is a row with a very long album title, and you may want to shorten it.

-- Run the query
SELECT 
  title 
FROM 
  album 
WHERE 
  album_id = 213;
-- UPDATE the album table
UPDATE 
  album
-- SET the new title    
SET 
  title = 'Pure Cult: The Best Of The Cult'
WHERE album_id = 213;

-- Delete

-- Run the query
SELECT 
  * 
FROM 
  album 
  -- DELETE the record
DELETE FROM 
  album 
WHERE 
  album_id = 1 
  -- Run the query again
SELECT 
  * 
FROM 
  album;

-- DECLARE variables (create variables)

-- DECLARE @ = general syntax
-- DECLARE @test_int = INT VARIABLE
-- DECLARE@my_artist VARCHAR(100)

-- SET @test_int = 5 this will assign value to the test_int variable

-- temporary tables = #my_temp_table

-- DECLARE and SET a variable

-- Declare the variable @region
DECLARE @region VARCHAR(10)

-- Update the variable value
SET @region = 'RFC'

SELECT description,
       nerc_region,
       demand_loss_mw,
       affected_customers
FROM grid
WHERE nerc_region = @region;

-- Declare multiple variables

-- Declare your variables
DECLARE @start DATE
DECLARE @stop DATE
DECLARE @affected INT;
-- SET the relevant values for each variable
SET @start = '2014-01-24'
SET @stop  = '2014-07-02'
SET @affected =  5000 ;

SELECT 
  description,
  nerc_region,
  demand_loss_mw,
  affected_customers
FROM 
  grid
-- Specify the date range of the event_date and the value for @affected
WHERE event_date BETWEEN @start AND @stop
AND affected_customers >= @affected;

-- Ultimate Power

-- Sometimes you might want to 'save' the results of a query so you can do some more work with the data. 
-- You can do that by creating a temporary table that remains in the database until SQL Server is restarted.

SELECT  album.title AS album_title,
  artist.name as artist,
  MAX(track.milliseconds / (1000 * 60) % 60 ) AS max_track_length_mins
-- Name the temp table #maxtracks
INTO #maxtracks
FROM album
-- Join album to artist using artist_id
INNER JOIN artist ON album.artist_id = artist.artist_id
-- Join track to album using album_id
INNER JOIN track ON track.album_id = album.album_id
GROUP BY artist.artist_id, album.title, artist.name,album.album_id
-- Run the final SELECT query to retrieve the results from the temporary table
SELECT album_title, artist, max_track_length_mins
FROM  #maxtracks
ORDER BY max_track_length_mins DESC, artist;
