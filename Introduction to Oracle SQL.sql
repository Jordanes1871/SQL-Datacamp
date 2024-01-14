-- Introduction to Oracle SQL

-- Chapter 1 - SQL Basics

/* 
database = set of data stored in a computer
relational database management system (RDMS) = programme that allows you to create, update and admin a relational database
relational database = based on relational model of data
Most RDMS use SQL langauge to access the database
Oracle is one such db but it is not free to use
ERD = graphical relationships of your entities in a diagram (relational data model)
*/

-- Writing your first query

-- Select the title from the album table
SELECT 
    title
FROM 
    ALBUM

-- Select lastname from customer table
SELECT 
    lastname
FROM 
    CUSTOMER


-- Select the last name and country from the customer table
SELECT 
    lastname,
    country
FROM 
    CUSTOMER

-- Removing duplicates

-- Let's dig a little bit deeper into the database. 
-- You want to find out which composers have written a song that is sold by eSymphony.
-- Since composers can write multiple songs, your results will probably include many duplicate values. 
-- If you want to select all unique values from a column, you can use the DISTINCT keyword.

-- Select the unique composers from the track table
SELECT DISTINCT 
    composer
FROM 
    Track -- 853 Composes have written a song

-- Working with strings

-- Select the first name and country from the employee table
SELECT 
    firstname,
    country
FROM 
    EMPLOYEE

-- Create a message similar to this one: Jack lives in Australia.
SELECT 
    firstname || ' lives in ' || Country -- || = concatination
FROM 
    Employee

-- Create a message similar to this one: Jack's home country is Australia.
/*

SELECT FirstName || q'['s home country is ]' || Country
FROM Employee

*/

-- Arithmetic expressions

-- Add 50 cents to the total amount
SELECT 
    total + 0.50
FROM 
    INVOICE

-- Ordering

-- Select the relevant fields from the employee table
SELECT 
    LastName, 
    Title, 
    BirthDate 
FROM 
    Employee
-- Order by job title and descending birth date
ORDER BY 
    Title, 
    BirthDate DESC

-- Comparison operators

-- Select the relevant columns and filter based on the condition
SELECT InvoiceId, Total
FROM Invoice
WHERE Total = 3.98

-- Select the relevant columns and filter based on the condition
SELECT InvoiceId, Total
FROM Invoice
WHERE Total > 3.98

-- Select the relevant columns and filter based on the condition
SELECT InvoiceId, Total
FROM Invoice
WHERE Total <= 3.98

-- Select the relevant columns and filter based on the condition
SELECT InvoiceId, Total
FROM Invoice
WHERE Total != 3.98

-- Select the song name and composer from the track table
SELECT name, composer
FROM TRACK
-- Filter on composer
WHERE Composer = 'Queen' 
      OR Composer = 'Mercury- Freddie'

-- Comparison keywords

SELECT LastName, Country
FROM Customer
-- Filter on the customer last name
WHERE LastName LIKE 'B%'

SELECT LastName, Country
FROM Customer
-- Filter on the customer last name
WHERE LastName LIKE 'B%' 
	  -- Filter on English speaking countries
      AND Country IN ('USA', 'Canada', 'United Kingdom')

SELECT LastName, Country
FROM Customer
-- Filter on the customer last name
WHERE LastName LIKE 'B%'
      -- Filter on non-English speaking countries
      AND Country NOT IN ('USA', 'Canada', 'United Kingdom')

-- Chapter 2 - Aggregating Data

-- Select the last name from the customer table
-- Getting started with group functions

-- Calculate the required values from the Invoice table
-- Add column aliases
SELECT MIN(Total) AS MINIMUM, 
       MAX(Total) AS MAXIMUM, 
       SUM(Total) AS SUM, 
       AVG(Total) AS AVERAGE
FROM Invoice

-- Counting

-- Count the number of billing cities
SELECT COUNT(billingcity)
FROM INVOICE
-- Filter on rows where the billing country is the USA
WHERE billingcountry = 'USA'

-- Count the number of unique billing cities in the Invoice table
-- Add the column alias
SELECT COUNT(DISTINCT BillingCity) AS "Number of US cities"
FROM Invoice
-- Filter on rows where the billing country is the USA
WHERE BillingCountry = 'USA'

-- Grouping

-- Select the country and the total number of customers
select country, count(*) AS Total
FROM Customer
-- Group the results by country
group by country

-- Advanced grouping

-- Select the BillingCountry, BillingCity, and total amount
SELECT BillingCountry, BillingCity, SUM(Total) AS "Total invoice amount"
FROM Invoice
-- Filter on BillingCountry 
WHERE BillingCountry IN ('USA', 'Canada')
-- Group by BillingCountry and BillingCity
GROUP BY BillingCountry, BillingCity
-- Sort the results
order by SUM(Total) desc

-- Restricting groups

-- Adapt the query below to show the correct results
SELECT Country, COUNT(*) AS Customers
FROM Customer
HAVING COUNT(*) > 4
GROUP BY Country

-- Select the title and the date of the most recent hire
SELECT Title, MAX(HireDate) AS "Most recent hire date"
-- The data comes from the Employee table 
FROM Employee
-- Group by title
GROUP BY Title
-- Exclude teams with only one member
HAVING COUNT(title) > 1

-- Combining WHERE and HAVING

-- Select the BillingCountry and the total billing amount
SELECT BillingCountry, SUM(Total)
FROM Invoice
-- Filter out invoices from Paris
WHERE billingcity <> 'Paris'
-- Group by billing country
GROUP BY BillingCountry
-- Exclude groups with an invoice amount of LESS than 100
HAVING SUM(Total) > 100

-- Chapter 3 - Combining Data
-- Inner joins

-- Select the customer's and employee's first and last names
SELECT c.FirstName, c.LastName, e.FirstName, e.LastName
-- Join the Customer and the Employee tables
FROM Customer c INNER JOIN Employee e
	-- Complete the common joining column
	ON c.SupportRepId = e.EmployeeId
-- Filter on the customer's first and last name
WHERE c.FirstName = 'Mark' AND c.LastName = 'Philips'

-- Using USING

-- Select the customer first and last name, and the total amount
SELECT c.FirstName, c.LastName, SUM(i.Total) AS TotalAmount
-- Join the Customer and the Invoice tables
FROM Customer c INNER JOIN Invoice i
	-- Complete the common joining column
	ON c.CustomerId = i.CustomerId
-- Group the result by customer name
GROUP BY c.FirstName, c.LastName
-- Order by the total amount in descending order
ORDER BY TotalAmount DESC

-- Select the customer first and last name, and the total amount
SELECT c.FirstName, c.LastName, SUM(i.Total) AS TotalAmount
-- Join the Customer and the Invoice tables
FROM Customer c INNER JOIN Invoice i
	-- Complete the common joining column
	USING(customerid)
-- Group the data by customer name
GROUP BY c.FirstName, c.LastName
-- Order by the total amount in descending order
ORDER BY TotalAmount DESC

-- Joining multiple tables

-- Select the track name and count
SELECT t.Name, COUNT(*)
-- Join the data in the Track, InvoiceLine, and Invoice tables
FROM Track t INNER JOIN InvoiceLine il 
    ON t.TrackId = il.TrackId
    INNER JOIN Invoice i 
    ON il.InvoiceId = i.InvoiceId
-- Filter on the USA 
WHERE i.BillingCountry = 'USA'
-- Group by track name
GROUP BY t.name
-- Order by count in descending order
ORDER BY COUNT(*) DESC

-- Left outer join

-- eSymphony's marketing department has noticed that songs in playlists get purchased more often. 
-- Since there's a Led Zeppelin anniversary coming up, they want to know how many songs composed by Jimmy Page, the founder of the band, are not in a playlist yet.

SELECT t.TrackId, t.Composer, t.Name, p.PlaylistId
-- Perform a left outer join
FROM Track t LEFT OUTER JOIN PlaylistTrack p
	-- Match on track id
	ON t.TrackId = p.TrackId
-- Filter on composer
WHERE t.Composer = 'Jimmy Page'

-- Right outer join

-- This time you want to figure out which tracks have never been sold. 
-- With this information eSymphony can limit the songs on offer and do some more targeted sales. 
-- They want you to focus on Miles Davis specifically because they noticed that jazz is not selling particularly well.

SELECT t.TrackId, t.Name, i.InvoiceId, i.Quantity
-- Perform a left outer join
FROM InvoiceLine i RIGHT OUTER JOIN Track t
	-- Match on track id
	ON i.TrackId = t.TrackId
-- Filter on composer
where composer = 'Miles Davis'

-- Cross joins

-- For a business to be successful, it's important to treat your most loyal customers well. 
-- You'd like to make sure that the support team is aware of who these customers are, so that they can prioritize their requests. 
-- You'd like to create a table where each of the support agents gets matched to each customer that spent at least $45 with eSymphony.

-- Select first and last names
SELECT e.FirstName || ' ' || e.LastName AS "Employee",
       c.FirstName || ' ' || c.LastName AS "Customer",
	   SUM(i.total) AS "Total"
-- Join Employee with Customer
FROM Employee e CROSS JOIN Customer c
-- Join with Invoice
	 INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
-- Filter for support agents only     
WHERE e.Title = 'Sales Support Agent'
GROUP BY e.FirstName, e.LastName, c.FirstName, c.LastName
-- Filter for customers that spent $45 or more
HAVING SUM(i.total) >= 45

-- Self joins

-- People who love music also love to discuss it or discover new artists. 
-- eSymphony is thinking about organizing a meetup to gather customers from a same city. 
-- That's not all: they would like to organize a speed meeting session, so that all customers get to speak with each other and exchange at least one artist.

-- Select city first and last name in one column
SELECT
    c1.City,
    c1.FirstName || ' ' || c1.LastName customer_1,
    c2.FirstName || ' ' || c2.LastName customer_2
-- Alias customer table as c1
FROM Customer c1
-- Join customer table on itself
JOIN Customer c2 ON c1.CustomerId > c2.CustomerId -- ensures no duplicates
	-- Match customers only if they live in the same city
	AND c1.city = c2.city

-- set operators

-- Write a query to get the first name and last name of all employees and customers.
-- Get employees first and last names
SELECT firstname, lastname
FROM Employee
-- Get customers first and last names
UNION ALL
SELECT firstname, lastname
FROM CUSTOMER 

-- Our query result contains 67 rows. Some employees may also be customers: modify your query to remove duplicates.

SELECT FirstName, LastName
FROM Employee
-- Modify your clause to remove duplicates
UNION
SELECT FirstName, LastName
FROM Customer

-- Find the tracks that appear in the Track table, that also appear in the InvoiceLine one.

-- Get track IDs that appear in InvoiceLine
SELECT TrackId
FROM TRACK
Intersect
SELECT TrackId
FROM INVOICELINE

-- Get track IDs that don't appear in invoiceline
(SELECT trackid
FROM TRACK)
MINUS
(SELECT trackid
FROM INVOICELINE)

-- Chapter 4 - Taking it to the next level

-- order in which Oracle procceses information
/*
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT 
6. ORDER BY 
*/

-- Mistakes against query processing order

-- Adapt this query to make it run without errors

-- PREVIOUSLY
SELECT Composer, MIN(Milliseconds) AS MinSongLength
FROM Track
WHERE GenreId = 1 AND MIN(Milliseconds) > 1000000
GROUP BY Composer
ORDER BY MinSongLength

-- ADJUSTED
SELECT Composer, MIN(Milliseconds) AS MinSongLength
FROM Track
WHERE GenreId = 1 
GROUP BY Composer
HAVING MIN(Milliseconds) > 1000000
ORDER BY MinSongLength

-- FUNCTIONS

-- Getting a substring:
-- SUBSTR(column, m, n): returns a portion of a string from position m, n characters long
-- SUBSTR(column of interest, starting pos of substring,length of substring)

-- LENGTH(val) = returns length of string
-- REPLACE(val, m, n) = replace m with n in val
SELECT REPLACE('kayak', 'k', 'y') -- returns yayay

-- ROUND(column, m) = round column to m decimal places
-- TRUNC(column, m) = truncates column to m decimal
-- MOD(column1, column2) = returns remainder of division
SELECT MOD(14,4) -- RETURNS 2 I.E. 14/4 = 12 REMAINDER 2

-- Rounding numbers
-- All the prices of songs end with .99.
-- convert UnitPrice in the Track table to the nearest whole number (e.g., $1.99 to $2).

-- Select TrackId and rounded unit price
SELECT TrackId, ROUND(unitprice, 0)
FROM TRACK

-- Working with the modulo
-- Your manager wants to know if she can equally divide customers amongst the new sales support team so that each agent has the same number of customers

-- Use a function to find the remainder
SELECT MOD(numerator,denominator) AS Modulo
-- Value to be divided
FROM (SELECT count(*) AS numerator 
      FROM CUSTOMER)
	-- Divisor
    CROSS JOIN (SELECT count(*) AS denominator 
          FROM EMPLOYEE 
          WHERE title = 'Sales Support Agent')

-- Manipulating strings

-- The company has launched a platform for customers. You've been asked to generate a username that's easy for customers to remember and for employees to interpret.
-- First four letters of LastName
-- All characters of the CustomerId

-- Output a new column called Username
SELECT LastName, CustomerId, CONCAT(
    -- First four letters of LastName
    SUBSTR(lastname, 1, 4), 
  	-- CustomerId
    customerid
    ) AS Username
FROM CUSTOMER

-- Replacing letters
-- You decide a temporary password should be made up of a customer's LastName. To make it more secures, as should be replaced with @, ss with $, and e with 3.

SELECT 
	--- Replace e with 3 and name the column Password
    REPLACE(
        --- Replace s with $
        REPLACE(
          	--- Replace a with @
            REPLACE(LastName, 'a', '@'),
		's', '$'),
	'e','3') AS Password
FROM Customer

-- working with null values

-- NVL(x,y) = convert x, which may contain a null value to y, a non-null value
SELECT NVL(Hiredate, '11/19/2004')

-- NULLIF(x,y) = if 2 values are the same it records the value as NULL, otherwise it returns value x

-- COALESCE = returns first non-null value in a list

-- Testing if a value is NULL

-- eSymphony is interested in knowing the number of tracks that are not in a playlist and cost $1.99. 
-- Since they know songs in a playlist are bought more often, they want to get an idea of the potential revenue they are missing out on.

-- Count the number of rows in the result
SELECT count(*) AS SongCount
-- Perform the appropriate join
FROM TRACK t LEFT OUTER JOIN PLAYLISTTRACK p
	ON t.trackid = p.trackid
-- Filter on tracks not in a playlist and cost $1.99
WHERE p.playlistid IS NULL AND t.UnitPrice = 1.99

-- Replacing NULL values

-- You are interested in knowing what companies US customers work for. 
-- Not all customers have provided the company they work for at the moment they signed up at eSymphony. 
-- This means there are some NULL values in the data. You want any eSymphony employees that look at your query later on to understand the result. 
-- This is why you decide to add a No affiliation tag to customers that haven't completed the Company field.

-- Replace NULL values in the Company field
SELECT NVL(company, 'No affiliation') AS Affiliation, COUNT(*)
FROM Customer
-- Filter on the country USA
WHERE country = 'USA'
-- Group by affiliation
GROUP BY company

-- Adapt your query to use the other function that will achieve the same.

-- Replace NULL values in the Company field
SELECT COALESCE(Company, 'No affiliation') AS Affiliation, COUNT(*)
FROM Customer
-- Filter on the country USA
WHERE Country = 'USA'
-- Group by affiliation
GROUP BY Company

-- Comparing values

-- eSymphony has asked you to look into the differences between composer and artist name.
-- More specifically, they want to know for which Queen tracks these differ. 
-- If they are the same a NULL value should appear, and if they differ the artist name should be displayed.

-- Use the correct null-related function
SELECT t.Name, ar.Name, t.Composer, NULLIF(ar.Name, t.Composer)
FROM Track t INNER JOIN Album a 
	ON t.AlbumId = a.AlbumId
	INNER JOIN Artist ar
	ON a.ArtistId = ar.ArtistId
-- Filter on artist name Queen
WHERE ar.name = 'Queen'
ORDER BY 3

-- Implicit and explicit conversion

-- You want to show all data for the employee with id 3. The problem is that you don't remember the datatype of the EmployeeId field. You decide to run two queries:

SELECT *
FROM Employee
WHERE EmployeeId = '3'

SELECT *
FROM Employee
WHERE EmployeeId = 3

-- You can paste them to the console on the right to see the output. Notice that both queries run without errors. Which type of conversion is responsible for this?
-- IMPLICIT CONVERSION = Convert numeric to string

-- Conversion functions

-- As a final request, eSymphony has asked you to help them get some insight into their hiring over time. 
-- They want to know for all years in the database, the total number of employees hired each month. The resulting date should be formatted as follows: 2019-12.
-- To achieve this, you need to make use of conversion functions to convert the HireDate from the Employee table to a suitable format.

-- Select the converted date from the Employee table
SELECT TO_CHAR(HireDate, 'YYYY-MM') AS YearMonth, COUNT(*) AS Employees
FROM Employee
-- Group by year and month
GROUP BY TO_CHAR(HireDate, 'YYYY-MM')
-- Order by year and month
ORDER BY YearMonth






