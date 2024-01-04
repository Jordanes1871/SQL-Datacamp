-- CHAPTER 1 - INTRODUCING INNER JOINS

-- Your first join
-- Select name fields (with alias) and region 
SELECT 
    cities.name AS city,
    countries.name AS country,
    region
FROM cities
INNER JOIN countries
ON cities.country_code = countries.code;

-- Joining with aliased tables

-- Select fields with aliases
SELECT 
    c.code AS country_code,
    c.name,
    e.year,
    e.inflation_rate
FROM countries AS c
-- Join to economies (alias e)
INNER JOIN economies AS e
-- Match on code field using table aliases
ON c.code = e.code;

-- USING in action

SELECT c.name AS country, l.name AS language, official
FROM countries AS c
INNER JOIN languages AS l
-- Match using the code column
USING (code)

-- 1-1 RELATIONSHIP / 1-MANY RELATIONSHIP / MANY-1 RELATIONSHIP
-- code in the country table and country_code in the city table is an example of 1 to many relationship as 1 country can be associated with many cities within that country

-- Which of these options best describes the relationship between the countries table and the languages table?
-- many-to-many relationship because spanish can be spoken in mexico and spain it is not unique to a specific country

-- Inspecting a relationship

-- Rearrange SELECT statement, keeping aliases
-- form here you can see how many languages are spoken in different countries
SELECT c.name AS country, l.name AS language
FROM countries AS c
INNER JOIN languages AS l
USING(code)
-- Order the results by language
ORDER BY language;

-- Joining multiple tables

-- Select fields
SELECT name, e.year, fertility_rate, unemployment_rate
FROM countries AS c
INNER JOIN populations AS p
ON c.code = p.country_code
-- Join to economies (as e)
INNER JOIN economies AS e
-- Match on country code
ON e.code = c.code;

-- Checking multi-table joins
-- The query should return two: one for each year. The last join was performed on c.code = e.code, without also joining on year

SELECT name, e.year, fertility_rate, unemployment_rate
FROM countries AS c
INNER JOIN populations AS p
ON c.code = p.country_code
INNER JOIN economies AS e
ON c.code = e.code
-- Add an additional joining condition such that you are also joining on year
	AND e.year = p.year;

-- CHAPTER 2 - OUTER JOINS, CROSS JOINS, SELF JOINS

SELECT 
    c1.name AS city,
    code,
    c2.name AS country,
    region,
    city_proper_pop
FROM cities AS c1
-- Perform an inner join with cities as c1 and countries as c2 on country code
INNER JOIN countries AS c2 
ON c1.country_code = c2.code
ORDER BY code DESC;

-- implementing a left join

SELECT 
	c1.name AS city, 
    code, 
    c2.name AS country,
    region, 
    city_proper_pop
FROM cities AS c1
-- Join right table (with alias)
LEFT JOIN countries AS c2
ON c1.country_code = c2.code
ORDER BY code DESC;

-- BUILDING A LEFT JOIN
SELECT region, AVG(gdp_percapita) AS avg_gdp
FROM countries AS c
LEFT JOIN economies AS e
USING(code)
WHERE year = 2010
GROUP BY region
-- Order by descending avg_gdp
ORDER BY avg_gdp DESC
-- Return only first 10 records
LIMIT 10;

-- Modify this query to use RIGHT JOIN instead of LEFT JOIN
SELECT countries.name AS country, languages.name AS language, percent
FROM languages
RIGHT JOIN countries
USING(code)
ORDER BY language;

-- Comparing joins

SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
FULL JOIN currencies
USING (code)
-- Where region is North America or name is null
WHERE region = 'North America' OR name IS NULL
ORDER BY region;

-- using left join

SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
LEFT JOIN currencies
USING (code)
WHERE region = 'North America' 
	OR name IS NULL
ORDER BY region;

-- using inner join
SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
INNER JOIN currencies
USING (code)
WHERE region = 'North America' 
	OR name IS NULL
ORDER BY region;

-- Suppose you are doing some research on Melanesia and Micronesia, and are interested in pulling information about languages and currencies into the data we see for these regions in the countries table
-- Chaining FULL JOINs

SELECT 
	c1.name AS country, 
    region, 
    l.name AS language,
	basic_unit, 
    frac_unit
FROM countries as c1 
-- Full join with languages (alias as l)
FULL JOIN languages AS l
USING (code)
-- Full join with currencies (alias as c2)
FULL JOIN currencies AS c2
USING (code)
WHERE region LIKE 'M%esia';

-- cross joins
-- Histories and languages
-- CROSS JOIN can be incredibly helpful when asking questions that involve looking at all possible combinations or pairings between two sets of data.
-- What are the languages presently spoken in the two countries?
-- Given the shared history between the two countries, what languages could potentially have been spoken in either country over the course of their history?

SELECT c.name AS country, l.name AS language
-- Inner join countries as c with languages as l on code
FROM countries AS c 
INNER JOIN languages AS l
ON c.code = l.code
WHERE c.code IN ('PAK','IND')
	AND l.code in ('PAK','IND');

-- UISNG CROSS JOIN
SELECT c.name AS country, l.name AS language
FROM countries AS c        
-- Perform a cross join to languages (alias as l)
CROSS JOIN languages AS l
WHERE c.code in ('PAK','IND')
	AND l.code in ('PAK','IND');

-- Choosing your join
-- You will determine the names of the five countries and their respective regions with the lowest life expectancy for the year 2010. 

SELECT 
	c.name AS country,
    region,
    life_expectancy AS life_exp
FROM countries AS c
-- Join to populations (alias as p) using an appropriate join
INNER JOIN populations AS p
ON c.code = p.country_code
-- Filter for only results in the year 2010
WHERE year = 2010
-- Sort by life_exp
ORDER BY life_exp
-- Limit to five records
LIMIT 5;

-- SELF JOINS
-- self join = used to compare values form part of a table to other values within that same table
-- Comparing a country to itself
-- Suppose you are interested in finding out how much the populations for each country changed from 2010 to 2015. You can visualize this change by performing a self join.

-- Select aliased fields from populations as p1
SELECT 
    p1.country_code, 
    p1.size AS size2010, 
    p2.size AS size2015
FROM populations AS p1
-- Join populations as p1 to itself, alias as p2, on country code
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code
WHERE p1.year = 2010 
-- Filter such that p1.year is always five years before p2.year
    AND p1.year = p2.year - 5

-- All joins on deck

/*
inner join

You sell houses and have 2 tables (listing_price and price_sold). You want a table with sale prices and listing prices only if you know them both

left join

you run a pizza delivery service with loyal customers. Youw ant a table of clients and their weekly orders, with nulls if there are no orders

full join

you want a report of whether your patients have reached out to you or you have reached out to them. You are fine with nulls for either condition
*/

-- CHAPTER 3 - SET THEORY SQL JOINS

-- union = takes 2 tables as input and returns all records in both
-- union all = takes 2 records as input and returns all records including duplicate values
-- CONDITION = number of selected cols and their respective data types must be identicial 

/*
union example:

left table
id  val
1 A 
1 B
2 A 
3 A
4 A

right table
id  val
1 A
4 A
5 A
6 A

UNION RESULT TABLE
id  val
1 A 
1 B
2 A 
3 A
4 A
5 A
6 A

UNION ALL RESULT TABLE
1 A 
1 A
1 B
2 A 
3 A
4 A
4 A
5 A
6 A

Q) What result will the following SQL query produce?
SELECT * 
FROM languages
UNION
SELECT * 
FROM currencies;

A SQL error, because languages and currencies do not have the same number of fields

Q) What result will the following SQL query produce?
SELECT code FROM
languages
UNION ALL
SELECT code FROM 
currencies;

An unordered list of each country code in languages and currencies, including duplicates

Q) What will the following SQL query produce?
SELECT code 
FROM languages
UNION
SELECT curr_id 
FROM currencies;

A SQL error, because code and curr_id are not of the same data type

*/

-- Comparing global economies

-- you have two tables, economies2015 and economies2019, available to you under the tabs in the console. 
-- You'll perform a set operation to stack all records in these two tables on top of each other, excluding duplicates.

-- Select all fields from economies2015
SELECT *    
FROM economies2015
-- Set operation
UNION
-- Select all fields from economies2019
SELECT * 
FROM economies2019
ORDER BY code, year;

-- Comparing two set operations
-- Perform an appropriate set operation that determines all pairs of country code and year (in that order) from economies and populations, excluding duplicates.
-- Order by country code and year.

-- Query that determines all pairs of code and year from economies and populations, without duplicates
SELECT 
    country_code,
    year
FROM populations
UNION 
SELECT  
    code,
    year
FROM economies
ORDER BY country_code, year;

-- Amend the query to return all combinations (including duplicates) of country code and year in the economies or the populations tables.

SELECT 
    country_code,
    year
FROM populations
UNION ALL
SELECT  
    code,
    year
FROM economies
ORDER BY country_code, year;

-- INTERSECT set condition
-- MATCHES ONLY ON SAME VALUES IN BOTH TABLES
-- NEED SAME NUMBER OF FIELDS AND THEY NEED TO BE IDENTICAL IN BOTH TABLES INCLUDING DATA TYPES

/*
left table
id  val
1 A 
1 B
2 A 
3 A
4 A

right table
id  val
1 A
4 A
5 A
6 A

RESULT TABLE USING INTERSECT AND NO DUPLICATES
id  val
1 A 
4 A

RESULT TABLE USING INNER JOIN = WE GET DUPLICATE VALUES
id  val
1 A 
1 A 
4 A
4 A

*/

-- INTERSECT

-- Return all cities with the same name as a country
SELECT name
FROM cities
INTERSECT
SELECT name
FROM countries;

-- EXCEPT set operation
-- only records in the left table that is not present in the right table
-- can include duplicates values

/*
left table
id  val
1 A 
1 B
2 A 
3 A
4 A

right table
id  val
1 A
4 A
5 A
6 A

RESULT TABLE USING EXCEPT 
1 B
3 A

*/

-- Return all cities that do not have the same name as a country
SELECT
    name
FROM cities
EXCEPT
SELECT 
    name
FROM countries
ORDER BY name;

-- Calling all set operators


/*

UNION OR UNION ALL

You are a school teacher teaching multiple classes. you want to combine the grades of all students into 1 consolidated table

INTERSECT

A residence hall ahs asked students to rank their preferences to be assigned a room. 
They now want to pair students based on common preferences

EXCEPT

You run a music streaming service and have a list of songs a user has listening to.
You want to show them new songs they haven't heard before

*/

-- CHAPTER 4 - SUBQUERIES

-- semi join = chooses records in 1st table where a condiiton is met in the second table
-- anti-join = choose records in the 1st table where col1 dose not find a match in col2

/*
left table
id col1
1 A
2 B
3 C
4 D

right table
id col2
B
C

RESULT SEMI JOIN
ID COL1
2 B
3 C

RESULT ANTI JOIN
ID COL1
1 A
4 D

*/

-- Semi join
-- Create a semi join out of the two queries you've written, which filters unique languages returned in the first query for only those languages spoken in the 'Middle East'.

-- STEP 1 (INNER QUERY I.E. SUBQUERY)
SELECT code
    FROM countries
    WHERE region = 'Middle East'

 -- STEP 2
SELECT DISTINCT name
FROM languages

-- SEMI-JOIN
SELECT DISTINCT name
FROM languages
-- Add syntax to use bracketed subquery below as a filter
WHERE code IN
    (SELECT code
    FROM countries
    WHERE region = 'Middle East')
ORDER BY name;

-- Diagnosing problems using anti join
-- The anti join is a related and powerful joining tool. It can be particularly useful for identifying whether an incorrect number of records appears in a join.
-- Say you are interested in identifying currencies of Oceanian countries. You have written the following INNER JOIN, which returns 15 records. Now, you want to ensure that all Oceanian countries from the countries table are included in this result.
SELECT c1.code, name, basic_unit AS currency
FROM countries AS c1
INNER JOIN currencies AS c2
ON c1.code = c2.code
WHERE c1.continent = 'Oceania';
-- If there are any Oceanian countries excluded in this INNER JOIN, you want to return the names of these countries.

-- STEP 1
-- Select code and name of countries from Oceania
SELECT code, name
FROM countries
WHERE continent = 'Oceania'

-- STEP 2
SELECT code, name
FROM countries
WHERE continent = 'Oceania'
-- Filter for countries not included in the bracketed subquery
  AND code NOT IN
    (SELECT code
    FROM currencies);

-- Subquery inside WHERE

SELECT *
FROM populations
-- Filter for only those populations where life expectancy is 1.15 times higher than average
WHERE life_expectancy > 1.15*
  (SELECT AVG(life_expectancy)
   FROM populations
   WHERE year = 2015) 
    AND year = 2015;

-- WHERE do people live?

-- subquerying by identifying capital cities in order of largest to smallest population.
-- Select relevant fields from cities table
SELECT 
    name, 
    country_code, 
    urbanarea_pop
FROM 
    cities
-- Filter using a subquery on the countries table
WHERE name IN
(SELECT capital
FROM countries
)
ORDER BY urbanarea_pop DESC;


-- Subquery inside SELECT

-- USING JOIN METHOD
-- Find top nine countries with the most cities
SELECT 
    countries.name AS country,
    count(cities.name) AS cities_num
-- Order by count of cities as cities_num
FROM 
    countries
LEFT JOIN cities
ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC
LIMIT 9;

-- USING SUBQUERY INSIDE SELECT yields same result
SELECT countries.name AS country,
-- Subquery that provides the count of cities   
  (SELECT count(cities) AS cities_num
   FROM cities
   WHERE cities.country_code = countries.code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;

-- Subquery inside FROM

-- Say you are interested in determining the number of languages spoken for each country. 
-- You want to present this information alongside each country's local_name, which is a field only present in the countries table and not in the languages table.

-- STEP 1 

-- Select code, and language count as lang_num
SELECT code, COUNT(name) AS lang_num
FROM languages
GROUP BY code;

-- STEP 2

-- Select local_name and lang_num from appropriate tables
SELECT local_name, lang_num
FROM countries,
  (SELECT code, COUNT(*) AS lang_num
  FROM languages
  GROUP BY code) AS sub
-- Where codes match
WHERE sub.code = countries.code
ORDER BY lang_num DESC;

-- Subquery challenge
-- Suppose you're interested in analyzing inflation and unemployment rate for certain countries in 2015. 
-- You are not interested in countries with "Republic" or "Monarchy" as their form of government, but are interested in all other forms of government, such as emirate federations, socialist states, and commonwealths

-- Select relevant fields
SELECT code, inflation_rate, unemployment_rate
FROM economies
WHERE year = 2015 
  AND code NOT IN
-- Subquery returning country codes filtered on gov_form
	(SELECT code
  FROM countries
  WHERE gov_form LIKE '%Republic%' OR gov_form LIKE '%Monarchy%')
ORDER BY inflation_rate;

-- Final challenge
-- determine the top 10 capital cities in Europe and the Americas by city_perc, a metric you'll calculate. city_perc is a percentage that calculates the "proper" population in a city as a percentage of the total population in the wider metro area, as follows:
-- city_proper_pop / metroarea_pop * 100

-- Select fields from cities
SELECT name, country_code, city_proper_pop, metroarea_pop, city_proper_pop / metroarea_pop * 100 AS city_perc
FROM cities
WHERE name IN
-- Use subquery to filter city name
(SELECT capital FROM countries WHERE continent = 'Europe' OR continent LIKE '%America')
-- Add filter condition such that metroarea_pop does not have null values
AND metroarea_pop IS NOT NULL
-- Sort and limit the result
ORDER BY city_perc DESC
LIMIT 10;



