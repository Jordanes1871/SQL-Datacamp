-- SQL For Joining Data

-- CHAPTER 1 - Introduction to INNER JOIN

-- Select name fields (with alias) and region 

SELECT 
cities.name AS city,
countries.name AS country,
countries.region
FROM cities
  INNER JOIN countries
    ON cities.country_code = countries.code;


-- Select fields with aliases
SELECT c.code AS country_code, name, year, inflation_rate
FROM countries AS c
  -- Join to economies (alias e)
  INNER JOIN economies as e
    -- Match on code
    ON c.code = e.code;


-- Select fields
SELECT c.code, c.name, c.region, e.year, p.fertility_rate, e.unemployment_rate
  -- From countries (alias as c)
  FROM countries AS c
  -- Join to populations (as p)
  INNER JOIN populations AS p
    -- Match on country code
    ON c.code = p.country_code
  -- Join to economies (as e)
  INNER JOIN economies AS e
    -- Match on country code and year
    ON (c.code = e.code AND p.year = e.year);


-- The INNER JOIN with USING

-- Select fields
SELECT
c.name AS country, c.continent, l.name AS language, l.official
  -- From countries (alias as c)
  FROM countries as c
  -- Join to languages (as l)
  INNER JOIN languages as l
    -- Match using code
    USING (code)

-- JOIN a table to itself using SELF JOINS
-- this is used to compare values in a field to other values of the same field form within the same table

-- Select fields with aliases
SELECT p1.country_code,
       p1.size AS size2010, 
       p2.size AS size2015,
       -- Calculate growth_perc
       ((p2.size - p1.size)/p1.size * 100.0) AS growth_perc
-- From populations (alias as p1)
FROM populations AS p1
  -- Join to itself (alias as p2)
  INNER JOIN populations AS p2
    -- Match on country code
    ON p1.country_code = p2.country_code
        -- and year (with calculation)
        AND p1.year = p2.year - 5;

-- Case when and then
-- Often it's useful to look at a numerical field not as raw data, but instead as being in different categories or groups.

SELECT name, continent, code, surface_area,
    -- First case
    CASE WHEN surface_area > 2000000 THEN 'large'
        -- Second case
        WHEN surface_area > 350000 THEN 'medium'
        -- Else clause + end
        ELSE 'small' END
        -- Alias name
        AS geosize_group
-- From table
FROM countries;


-- Inner challenge
SELECT country_code, size,
  CASE WHEN size > 50000000
            THEN 'large'
       WHEN size > 1000000
            THEN 'medium'
       ELSE 'small' END
       AS popsize_group
INTO pop_plus       
FROM populations
WHERE year = 2015;

-- Select fields
SELECT name, continent, geosize_group, p.popsize_group
-- From countries_plus (alias as c)
FROM countries_plus as c
  -- Join to pop_plus (alias as p)
  INNER JOIN pop_plus as p
    -- Match on country code
    on c.code = p.country_code
-- Order the table    
ORDER BY geosize_group ASC;

-- *2 select statements above create 1 query

-- CHAPTER 2 - LEFT AND RIGHT JOINS

-- start with inner join
-- Select the city name (with alias), the country code,
-- the country name (with alias), the region,
-- and the city proper population
SELECT c1.name AS city, code, c2.name AS country,
       region, city_proper_pop
-- From left table (with alias)
FROM cities AS c1
  -- Join to right table (with alias)
  INNER JOIN countries AS c2
    -- Match on country code
    ON c1.country_code = c2.code
-- Order by descending country code
ORDER BY code DESC;


-- perform left join

SELECT c1.name AS city, code, c2.name AS country,
       region, city_proper_pop
FROM cities AS c1
  -- Join right table (with alias)
  LEFT JOIN countries AS c2
    -- Match on country code
    ON c1.country_code = c2.code
-- Order by descending country code
ORDER BY code DESC;


/*
Select country name AS country, the country's local name,
the language name AS language, and
the percent of the language spoken in the country
*/
SELECT c.name AS country, local_name, l.name AS language, percent
-- From left table (alias as c)
FROM countries AS c
  -- Join to right table (alias as l)
  INNER JOIN languages AS l
    -- Match on fields
    ON c.code = l.code
-- Order by descending country
ORDER BY country DESC;

/*
Select country name AS country, the country's local name,
the language name AS language, and
the percent of the language spoken in the country
*/
SELECT c.name AS country, local_name, l.name AS language, percent
-- From left table (alias as c)
FROM countries AS c
  -- Join to right table (alias as l)
  LEFT JOIN languages AS l
    -- Match on fields
    ON c.code = l.code
-- Order by descending country
ORDER BY country DESC;


-- Select name, region, and gdp_percapita
SELECT name, region, e.gdp_percapita
-- From countries (alias as c)
FROM countries AS c
  -- Left join with economies (alias as e)
  LEFT JOIN economies AS e
    -- Match on code fields
    ON c.code = e.code
-- Focus on 2010
WHERE e.year = 2010;


-- Select fields
SELECT region, AVG(e.gdp_percapita) AS avg_gdp
-- From countries (alias as c)
FROM countries AS c
  -- Left join with economies (alias as e)
  LEFT JOIN economies AS e
    -- Match on code fields
    ON c.code = e.code
-- Focus on 2010
WHERE e.year = 2010
-- Group by region
GROUP BY region
-- Order by descending avg_gdp
ORDER BY avg_gdp DESC;

-- Right join

-- convert this code to use RIGHT JOINs instead of LEFT JOINs
/*
SELECT cities.name AS city, urbanarea_pop, countries.name AS country,
       indep_year, languages.name AS language, percent
FROM cities
  LEFT JOIN countries
    ON cities.country_code = countries.code
  LEFT JOIN languages
    ON countries.code = languages.code
ORDER BY city, language;
*/

SELECT cities.name AS city, urbanarea_pop, countries.name AS country,
       indep_year, languages.name AS language, percent
FROM languages
  RIGHT JOIN countries
    ON countries.code = languages.code
  RIGHT JOIN cities
    ON cities.country_code = countries.code
ORDER BY city, language;

-- FULL JOIN

SELECT name AS country, code, region, basic_unit
-- From countries
FROM countries
  -- Join to currencies
  FULL JOIN currencies
    -- Match on code
    USING (code)
-- Where region is North America or null
WHERE region = 'North America' OR region IS NULL
-- Order by region
ORDER BY region;

SELECT countries.name, code, languages.name AS language
-- From languages
FROM languages
  -- Join to countries
  FULL JOIN countries
    -- Match on code
    USING (code)
-- Where countries.name starts with V or is null
WHERE countries.name LIKE 'V%' OR countries.name IS NULL
-- Order by ascending countries.name
ORDER BY countries.name;

-- Select fields (with aliases)
SELECT c1.name AS country, region, l.name AS language,
       basic_unit, frac_unit
-- From countries (alias as c1)
FROM countries AS c1
  -- Join with languages (alias as l)
  FULL JOIN languages AS l
    -- Match on code
    USING (code)
  -- Join with currencies (alias as c2)
  FULL JOIN currencies AS c2
    -- Match on code
    USING (code)
-- Where region like Melanesia and Micronesia
WHERE region LIKE 'M%esia';

-- CROSS JOINS 
-- This exercise looks to explore languages potentially and most frequently spoken in the cities of Hyderabad, India and Hyderabad, Pakistan.
-- Select fields
SELECT c.name AS city, l.name AS language
-- From cities (alias as c)
FROM cities AS c        
  -- Join to languages (alias as l)
  CROSS JOIN languages AS l
-- Where c.name like Hyderabad
WHERE c.name LIKE 'Hyder%';

-- Challenge 

-- Select fields
SELECT c.name AS country, region, p.life_expectancy AS life_exp
-- From countries (alias as c)
FROM countries AS c
  -- Join to populations (alias as p)
  LEFT JOIN populations AS p
    -- Match on country code
    on c.code = p.country_code
-- Focus on 2010
WHERE p.year = '2010'
-- Order by life_exp
ORDER BY life_exp
-- Limit to 5 records
LIMIT 5;


-- CHAPTER 3 - UNION

-- UNION = every record in both tables but does not double count those in both tables
-- UNION ALL = includes every record in both tables and does replicate those in both tables (double count)
-- INTERSECT = records that are only in both tables
-- EXCEPT =  only results in one table and not the other

-- UNION
-- Select fields from 2010 table
SELECT *
  -- From 2010 table
  FROM economies2010
	-- Set theory clause
	UNION
-- Select fields from 2015 table
SELECT *
  -- From 2015 table
  FROM economies2015
-- Order by code and year
ORDER BY code, year;


-- DETERMING DUPLICATE COUNTRY CODES
-- Select field
SELECT country_code
  -- From cities
  FROM cities
	-- Set theory clause
	UNION
-- Select field
SELECT code
  -- From currencies
  FROM currencies
-- Order by country_code
ORDER BY country_code;


-- UNION ALL
-- As you saw, duplicates were removed from the previous two exercises by using UNION.
-- To include duplicates, you can use UNION ALL.

-- Determine all combinations (include duplicates) of country code and year that exist in either the economies or the populations tables. Order by code then year.

-- Select fields
SELECT code, year
  -- From economies
  FROM economies
	-- Set theory clause
	UNION ALL
-- Select fields
SELECT country_code, year
  -- From populations
  FROM populations
-- Order by code, year
ORDER BY code, year;

-- INTERSECT

-- Use INTERSECT to determine the records in common for country code and year for the economies and populations tables.
-- Select fields
SELECT code, year
  -- From economies
  FROM economies
	-- Set theory clause
	INTERSECT
-- Select fields
SELECT country_code, year
  -- From populations
  FROM populations
-- Order by code and year
ORDER BY code, year;


-- As you think about major world cities and their corresponding country, you may ask which countries also have a city with the same name as their country name?

-- Select fields
SELECT code, name
  -- From countries
  FROM countries
	-- Set theory clause
	INTERSECT
-- Select fields
SELECT country_code, name
  -- From cities
  FROM cities;

-- EXCEPT

-- Get the names of cities in cities which are not noted as capital cities in countries as a single field result.

-- Select field
SELECT name
  -- From cities
  FROM cities
	-- Set theory clause
	EXCEPT
-- Select field
SELECT capital
  -- From countries
  FROM countries
-- Order by result
ORDER BY name;

-- Determine the names of capital cities that are not listed in the cities table.

-- Select field
SELECT capital
  -- From countries
  FROM countries
	-- Set theory clause
	EXCEPT
-- Select field
SELECT name
  -- From cities
  FROM cities
-- Order by ascending capital
ORDER BY capital;

-- SEMI-JOINS AND ANTI-JOINS

-- SEMI-JOIN = matches records by a key field in the right table with those in the left
--             It then picks out only the rows in the left table that match that condition
-- ANTI-JOIN = picks out columns in the left table that do not match the condition on the right table

-- Semi-join
-- You are now going to use the concept of a semi-join to identify languages spoken in the Middle East.

-- Query from step 2
SELECT DISTINCT name
  FROM languages
-- Where in statement
WHERE code IN
  -- Query from step 1
  -- Subquery
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
-- Order by name
ORDER BY name;

-- equivilant result using INNER JOIN
SELECT DISTINCT (languages.name) AS language
FROM languages
INNER JOIN countries
ON languages.code = countries.code
WHERE region = 'Middle East'
ORDER BY language;

-- ANTI JOIN


-- step 1
-- Begin by determining the number of countries in countries that are listed in Oceania using SELECT, FROM, and WHERE.


-- Select statement
SELECT COUNT(name)
  -- From countries
  From countries
-- Where continent is Oceania
WHERE continent = 'Oceania';

-- Another powerful join in SQL is the anti-join. It is particularly useful in identifying which records are causing an incorrect number of records to appear in join queries.


-- Select fields (with aliases)
SELECT c1.code, c1.name AS name, 
        c2.basic_unit AS currency
  -- From countries (alias as c1)
  FROM countries AS c1
  	-- Join with currencies (alias as c2)
  	INNER JOIN currencies AS c2
    -- Match on code
    ON c1.code = c2.code
-- Where continent is Oceania
WHERE continent = 'Oceania';

-- Note that not all countries in Oceania were listed in the resulting inner join with currencies. Use an anti-join to determine which countries were not included!

-- Select fields
SELECT code, name
  -- From Countries
  FROM Countries
  -- Where continent is Oceania
  WHERE continent = 'Oceania'
  	-- And code not in
  	AND code NOT IN 
  	-- Subquery
  	(SELECT code
  	 FROM currencies);


-- Set theory challenge

-- task here will be to incorporate two of UNION/UNION ALL/INTERSECT/EXCEPT to solve a challenge involving three tables.
-- Identify the country codes that are included in either economies or currencies but not in populations.

-- Select the city name
SELECT c1.name 
  -- Alias the table where city name resides
  FROM cities AS c1
  -- Choose only records matching the result of multiple set theory clauses
  WHERE country_code IN
(
    -- Select appropriate field from economies AS e
    SELECT e.code
    FROM economies AS e
    -- Get all additional (unique) values of the field from currencies AS c2  
    UNION
    SELECT c2.code
    FROM currencies AS c2
    -- Exclude those appearing in populations AS p
    EXCEPT
    SELECT p.country_code
    FROM populations AS p
);


-- CHAPTER 4 - SUBQUERIES INSIDE WHERE AND SELECT CLAUSES

-- Subquery inside where
-- You'll now try to figure out which countries had high average life expectancies (at the country level) in 2015.

-- Select fields
SELECT *
  -- From populations
  FROM populations
-- Where life_expectancy is greater than
WHERE life_expectancy > 1.15 * 
  --  1.15 * subquery
  (SELECT AVG(life_expectancy)
     FROM populations
   WHERE year = '2015')
   AND year = '2015';

 
-- Use your knowledge of subqueries in WHERE to get the urban area population for only capital cities.
-- Select fields
Select name, country_code, urbanarea_pop
  -- From cities
  FROM cities
-- Where city name in the field of capital cities
WHERE name IN
  -- Subquery
  (Select capital
   FROM countries)
ORDER BY urbanarea_pop DESC;

-- Subquery inside select
-- how some queries can be written using either a join or a subquery

-- JOIN EXAMPLE
SELECT countries.name AS country, COUNT(*) AS cities_num
  FROM cities
    INNER JOIN countries
    ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC, country
LIMIT 9;

-- SUBQUERY EXAMPLE

SELECT name AS country,
  -- Subquery
  (SELECT COUNT(*)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;

-- Subquery inside from

-- determine the number of languages spoken for each country by local_name
-- Select fields
SELECT local_name, lang_num
  -- From countries
  FROM countries,
  	-- Subquery (alias as subquery)
  	(SELECT code, COUNT(*) AS lang_num
  	 FROM languages
  	 GROUP BY code) AS subquery
  -- Where codes match
  WHERE countries.code = subquery.code
-- Order by descending number of languages
ORDER BY lang_num DESC;

-- Advanced subquery

-- You can also nest multiple subqueries to answer even more specific questions.
-- for each of the six continents listed in 2015, you'll identify which country had the maximum inflation rate, and how high it was, using multiple subqueries.

-- Select fields
SELECT name, continent, inflation_rate
  -- From countries
  FROM countries
	-- Join to economies
	INNER JOIN economies
	-- Match on code
	ON countries.code = economies.code
  -- Where year is 2015
  WHERE year = 2015
    -- And inflation rate in subquery (alias as subquery)
     AND inflation_rate IN (
        SELECT MAX(inflation_rate) AS max_inf
        FROM (
             SELECT name, continent, inflation_rate
             FROM countries
             INNER JOIN economies
             ON economies.code = countries.code
             WHERE year = 2015) AS subquery
      -- Group by continent
        GROUP BY continent);

-- Subquery challenge
-- Use a subquery to get 2015 economic data for countries that do not have

-- gov_form of 'Constitutional Monarchy' or
-- 'Republic' in their gov_form.

-- Select fields
SELECT code, inflation_rate, unemployment_rate
  -- From economies
  FROM economies
  -- Where year is 2015 and code is not in
  WHERE year = '2015' AND code NOT IN
  	-- Subquery
  	(SELECT code
  	 FROM countries
  	 WHERE (gov_form = 'Constitutional Monarchy' OR gov_form LIKE '%Republic'))
-- Order by inflation rate
ORDER BY inflation_rate;

-- Final challenge
-- Central American countries with an official language.

-- Select fields
SELECT DISTINCT name, e.total_investment, e.imports
  -- From table (with alias)
  FROM countries AS c
    -- Join with table (with alias)
    LEFT JOIN economies AS e
      -- Match on code
      ON (c.code = e.code
      -- and code in Subquery
        AND c.code IN (
          SELECT l.code
          FROM languages AS l
          WHERE official = 'true'
        ) )
  -- Where region and year are correct
  WHERE region = 'Central America' AND year = '2015'
-- Order by field
ORDER BY name;

-- Let's ease up a bit and calculate the average fertility rate for each region in 2015.

-- Select fields
SELECT region, continent, AVG(p.fertility_rate) AS avg_fert_rate
  -- From left table
  FROM countries AS c
    -- Join to right table
    INNER JOIN populations AS p
      -- Match on join condition
      ON c.code = p.country_code
  -- Where specific records matching some condition
  WHERE p.year = '2015'
-- Group appropriately
GROUP BY region, continent
-- Order appropriately
ORDER BY avg_fert_rate;


--  determining the top 10 capital cities in Europe and the Americas in terms of a calculated percentage using city_proper_pop and metroarea_pop in cities.
-- Select fields
SELECT name, country_code, city_proper_pop, metroarea_pop,  
      -- Calculate city_perc
      city_proper_pop / metroarea_pop * 100 AS city_perc
  -- From appropriate table
  FROM cities
  -- Where 
  WHERE name IN
    -- Subquery
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe'
        OR continent LIKE '%America'))
       AND metroarea_pop IS NOT NULL
-- Order appropriately
ORDER BY city_perc DESC
-- Limit amount
LIMIT 10;
































