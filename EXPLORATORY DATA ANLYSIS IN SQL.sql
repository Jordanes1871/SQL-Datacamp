-- EXPLORATORY DATA ANLYSIS IN SQL

-- CHAPTER 1: What's in the DB

-- Which table has the most rows? Which table has the most columns?

SELECT COUNT(*)
FROM tablename;

-- Select the count of the number of rows
SELECT count(*)
FROM fortune500; 


-- Inner Join tables based on common field
SELECT company.name
-- Table(s) to select from
  FROM company
       inner join fortune500
       on fortune500.ticker=company.ticker;


-- What is the most common stackoverflow tag_type? What companies have a tag of that type?

-- Count the number of tags with each type
SELECT type, COUNT(*) AS count
  FROM tag_type
 -- To get the count for each type, what do you need to do?
 GROUP BY type
 -- Order the results with the most common
 -- tag types listed first
 order by count desc;

-- Select the 3 columns desired
SELECT name, tag_type.tag, tag_type.type
  FROM company
  	   -- Join to the tag_company table
       INNER JOIN tag_company 
       ON company.id = tag_company.company_id
       -- Join to the tag_type table
       INNER JOIN tag_type
       ON tag_company.tag = tag_type.tag
  -- Filter to most common type
  WHERE type='cloud';

-- In the fortune500 data, industry contains some missing values. Use coalesce() to use the value of sector as the industry when industry is NULL. Then find the most common industry.

-- Use coalesce
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       -- Don't forget to count!
       count(industry) 
  FROM fortune500 
-- Group by what? (What are you counting by?)
 GROUP BY industry, sector
-- Order results to see most common first
 order by count(*) desc
-- Limit results to get just the one value you want
 limit 1;

-- You previously joined the company and fortune500 tables to find out which companies are in both tables. Now, also include companies from company that are subsidiaries of Fortune 500 companies as well
-- To include subsidiaries, you will need to join company to itself to associate a subsidiary with its parent company's information. To do this self-join, use two different aliases for company.
-- coalesce will help you combine the two ticker columns in the result of the self-join to join to fortune500.


SELECT company_original.name, title, rank
  -- Start with original company information
  FROM COMPANY AS company_original
       -- Join to another copy of company with parent
       -- company information
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       -- Join to fortune500, only keep rows that match
       INNER JOIN fortune500 
       -- Use parent ticker if there is one, 
       -- otherwise original ticker
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 -- For clarity, order by rank
 ORDER BY rank; 

-- When you cast data from one type to another, information can be lost or changed. See how the casting changes values and practice casting data using the CAST() function and the :: syntax.
-- Select the original value
SELECT profits_change, 
	   -- Cast profits_change
       CAST(profits_change as INT) AS profits_change_int
  FROM fortune500;


--Compare the results of casting of dividing the integer value 10 by 3 to the result of dividing the numeric value 10 by 3.
-- Divide 10 by 3
SELECT 10/3, 
       -- Cast 10 as numeric and divide by 3
       10::numeric/3;


--Now cast numbers that appear as text as numeric.
Note: 1e3 is scientific notation.
SELECT '3.2'::numeric,
       '-123'::numeric,
       '1e3'::numeric,
       '1e-3'::numeric,
       '02314'::numeric,
       '0002'::numeric;

--Was 2017 a good or bad year for revenue of Fortune 500 companies? Examine how revenue changed from 2016 to 2017 by first looking at the distribution of revenues_change and then counting companies whose revenue increased.


--Was 2017 a good or bad year for revenue of Fortune 500 companies? Examine how revenue changed from 2016 to 2017 by first looking at the distribution of revenues_change and then counting companies whose revenue increased.

-- Select the count of each value of revenues_change
SELECT revenues_change, count(*)
  FROM fortune500
 group by revenues_change
 -- order by the values of revenues_change
 ORDER BY revenues_change;


-- Select the count of each revenues_change integer value
SELECT revenues_change::integer, count(*)
  FROM fortune500
 group by revenues_change::integer
 -- order by the values of revenues_change
 ORDER BY revenues_change;

-- Count rows 
SELECT count(*)
  FROM fortune500
 -- Where...
 WHERE revenues_change > 0;

 -- Chapter 2: Numeric Data Types and Summary Functions

 -- Compute the average revenue per employee for Fortune 500 companies by sector.

-- Select average revenue per employee by sector
SELECT sector, 
       avg(revenues/employees::numeric) AS avg_rev_employee
  FROM fortune500
 GROUP BY sector
 -- Use the column alias to order the results
 ORDER BY avg_rev_employee;



-- Chapter 2: Numeric Data types and summary functions
 --In exploring a new database, it can be unclear what the data means and how columns are related to each other.

-- What information does the unanswered_pct column in the stackoverflow table contain? Is it the percent of questions with the tag that are unanswered (unanswered ?s with tag/all ?s with tag)? Or is it something else, such as the percent of all unanswered questions on the site with the tag (unanswered ?s with tag/all unanswered ?s)?

-- Divide unanswered_count (unanswered ?s with tag) by question_count (all ?s with tag) to see if the value matches that of unanswered_pct to determine the answer.

-- Divide unanswered_count by question_count
SELECT unanswered_count/question_count::numeric AS computed_pct, 
       -- What are you comparing the above quantity to?
       unanswered_pct
  FROM stackoverflow
 -- Select rows where question_count is not 0
 WHERE question_count  !=0
 LIMIT 10;

-- Select min, avg, max, and stddev of fortune500 profits
SELECT min(profits),
       avg(profits),
       max(profits),
       stddev(profits)
  FROM fortune500;

-- Select sector and summary measures of fortune500 profits
SELECT sector,
       min(profits),
       avg(profits),
       max(profits),
       stddev(profits)
  FROM fortune500
 -- What to group by?
 GROUP BY sector
 -- Order by the average profits
 ORDER BY avg;


--Sometimes you want to understand how a value varies across groups. For example, how does the maximum value per group vary across groups?

--To find out, first summarize by group, and then compute summary statistics of the group results. One way to do this is to compute group values in a subquery, and then summarize the results of the subquery.

--For this exercise, what is the standard deviation across tags in the maximum number of Stack Overflow questions per day? What about the mean, min, and max of the maximums as well?

-- Compute standard deviation of maximum values
SELECT stddev(maxval),
	   -- min
       min(maxval),
       -- max
       max(maxval),
       -- avg
       avg(maxval)
  -- Subquery to compute max of question_count by tag
  FROM (SELECT max(question_count) AS maxval
          FROM stackoverflow
         -- Compute max by...
         GROUP BY tag) AS max_results; -- alias for subquery


-- TRUNCATE

-- Truncate employees
SELECT trunc(employees, -5) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;

-- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Limit to which companies?
 WHERE trunc(employees, -5) < 100000
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;

--Generate series
--Summarize the distribution of the number of questions with the tag "dropbox" on Stack Overflow per day by binning the data.

-- Select the min and max of question_count
SELECT min(question_count), 
       max(question_count)
  -- From what table?
  FROM stackoverflow
 -- For tag dropbox
 where tag = 'dropbox';

-- Create lower and upper bounds of bins
SELECT generate_series(2200, 3050, 50) AS lower,
       generate_series(2250, 3100, 50) AS upper;


-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), 
       -- keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower 
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;

-- Correlation
--What's the relationship between a company's revenue and its other financial attributes? Compute the correlation between revenues and other financial variables with the corr() function.

-- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;

-- What groups are you computing statistics by?
SELECT sector,
       -- Select the mean of assets with the avg function
       avg(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 -- Computing statistics for each what?
 GROUP BY sector
 -- Order results by a value of interest
 ORDER BY mean;

-- Create a temp table
-- Find the Fortune 500 companies that have profits in the top 20% for their sector (compared to other Fortune 500 companies).

-- To clear table if it already exists;
-- fill in name of temp table
DROP TABLE IF EXISTS profit80;

-- Create the temporary table
CREATE TEMP TABLE profit80 AS 
  -- Select the two columns you need; alias as needed
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    -- What table are you getting the data from?
    FROM fortune500
   -- What do you need to group by?
   GROUP BY sector;
   
-- See what you created: select all columns and rows 
-- from the table you created
SELECT * 
  FROM profit80;



-- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

-- Select columns, aliasing as needed
SELECT title, fortune500.sector, 
       profits, profits/pct80 AS ratio
-- What tables do you need to join?  
  FROM fortune500 
       LEFT JOIN profit80
-- How are the tables joined?
       ON fortune500.sector=profit80.sector
-- What rows do you want to select?
 WHERE profits > pct80;


--The Stack Overflow data contains daily question counts through 2018-09-25 for all tags, but each tag has a different starting date in the data.
--Find out how many questions had each tag on the first date for which data for the tag is available, as well as how many questions had the tag on the last day. Also, compute the difference between these two values.
--To do this, first compute the minimum date for each tag.
--Then use the minimum dates to select the question_count on both the first and last day. To do this, join the temp table startdates to two different copies of the stackoverflow table: one for each column - first day and last day - aliased with different names.

-- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

-- Create temp table syntax
CREATE TEMP TABLE startdates AS
-- Compute the minimum date for each what?
SELECT tag,
       min(date) AS mindate
  FROM stackoverflow
 -- What do you need to compute the min date for each tag?
 GROUP BY tag;
 
 -- Look at the table you created
 SELECT * 
   FROM startdates;


-- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
-- Select tag (Remember the table name!) and mindate
SELECT startdates.tag, 
       mindate, 
       -- Select question count on the min and max days
	   so_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       -- Compute the change in question_count (max- min)
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       -- Join startdates to stackoverflow with alias so_min
       INNER JOIN stackoverflow AS so_min
          -- What needs to match between tables?
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       -- Join to stackoverflow again with alias so_max
       INNER JOIN stackoverflow AS so_max
          -- Again, what needs to match between tables?
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';


-- INSERT A TEMP TABLE
-- While you can join the results of multiple similar queries together with UNION, sometimes it's easier to break a query down into steps. You can do this by creating a temporary table and inserting rows into it.
--Compute the correlations between each pair of profits, profits_change, and revenues_change from the Fortune 500 data.

DROP TABLE IF EXISTS correlations;

-- Create temp table 
DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       round(profits::numeric, 2) AS profits,
       round(profits_change::numeric, 2)  AS profits_change,
       round(revenues_change::numeric, 2)  AS revenues_change
  FROM correlations;

--CHAPTER 3 Character data types and common issues

-- Count the categories
-- In this chapter, we'll be working mostly with the Evanston 311 data in table evanston311. This is data on help requests submitted to the city of Evanston, IL.
--This data has several character columns. Start by examining the most frequent values in some of these columns to get familiar with the common categories.

--How many rows does each priority level have?
-- Select the count of each level of priority
SELECT priority, Count(*)
  FROM evanston311
 GROUP BY priority;

-- How many distinct values of zip appear in at least 100 rows?
-- Find values of zip that appear in at least 100 rows
-- Also get the count of each value
SELECT zip, COUNT(*)
  FROM evanston311
 GROUP BY zip
 HAVING COUNT(*) >= 100; 

-- How many distinct values of source appear in at least 100 rows?
-- Find values of source that appear in at least 100 rows
-- Also get the count of each value
SELECT source, COUNT(*)
  FROM evanston311
 GROUP BY source
 HAVING COUNT(*) >= 100; 


-- Select the five most common values of street and the count of each.
-- Find the 5 most common values of street and the count of each
SELECT street, count(*)
  FROM evanston311
 GROUP BY street
 ORDER BY count(*) desc
 LIMIT 5;


-- Which of the following is NOT an issue you see with the values of street?
-- A) there are sometimes extra spaces at the begging an dend of values
select street, count(*)
from evanston311
group by street
order by street desc;

-- Trimming
-- Some of the street values in evanston311 include house numbers with # or / in them. In addition, some street values end in a ..
-- Remove the house numbers, extra punctuation, and any spaces from the beginning and end of the street values as a first attempt at cleaning up the values.

SELECT distinct street,
       -- Trim off unwanted characters from street
       trim(street, '0123456789#/. ') AS cleaned_street
  FROM evanston311
 ORDER BY street;

-- xploring unstructured text
-- The description column of evanston311 has the details of the inquiry, while the category column groups inquiries into different types. How well does the category capture what's in the description?

-- Building up the query through the steps below, find inquires that mention trash or garbage in the description without trash or garbage being in the category. What are the most frequent categories for such inquiries?

-- LIKE and ILIKE queries will help you find relevant descriptions and categories. Remember that with LIKE queries, you can include a % on each side of a word to find values that contain the word.

-- Use ILIKE to count rows in evanston311 where the description contains 'trash' or 'garbage' regardless of case.

-- Count rows
SELECT count(*)
  FROM evanston311
 -- Where description includes trash or garbage
 WHERE description ILIKE '%trash%'
    OR description ILIKE '%garbage%';


-- category values are in title case. Use LIKE to find category values with 'Trash' or 'Garbage' in them.
-- Select categories containing Trash or Garbage
SELECT category
  FROM evanston311
 -- Use LIKE
 WHERE category LIKE '%Trash%'
    OR category LIKE '%Garbage%';


-- Count rows where the description includes 'trash' or 'garbage' but the category does not.

-- Count rows
SELECT count(*)
  FROM evanston311 
 -- description contains trash or garbage (any case)
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
 -- category does not contain Trash or Garbage
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%';

-- Find the most common categories for rows with a description about trash that don't have a trash-related category.

-- Count rows with each category
SELECT category, count(*)
  FROM evanston311 
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%'
 -- What are you counting?
 GROUP BY category
 --- order by most frequent values
 ORDER BY count DESC
 LIMIT 10;

 
-- Concatenate strings
-- Concatenate house_num, a space, and street
-- and trim spaces from the start of the result
SELECT trim(concat(house_num, ' ', street),' ') AS address
  FROM evanston311;

-- Split Strings
-- Use split_part() to select the first word in street; alias the result as street_name.
-- Also select the count of each value of street_name.

-- Select the first word of the street value
SELECT split_part(street, ' ', 1) AS street_name, /*(value, split by, part)*/
       count(*)
  FROM evanston311
 GROUP BY street_name
 ORDER BY count DESC
 LIMIT 20;

-- Shorten long strings
-- Select the first 50 characters of description with '...' concatenated on the end where the length() of the description is greater than 50 characters. Otherwise just select the description as is.
-- Select only descriptions that begin with the word 'I' and not the letter 'I'.

-- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN left(description, 50) || '...'
       -- otherwise just select description
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description LIKE 'I %'
 ORDER BY description;




-- Group and recode values
-- Fill in the command below with the name of the temp table
DROP TABLE IF EXISTS recode;

-- Create and name the temporary table
CREATE TEMP TABLE recode AS
-- Write the select query to generate the table 
-- with distinct values of category and standardized values
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
    -- What table are you selecting the above values from?
    FROM evanston311;
    
-- Look at a few values before the next step
SELECT DISTINCT standardized 
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';

-------------------

-- Code from previous step
DROP TABLE IF EXISTS recode;

CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
    FROM evanston311;

-- Update to group trash cart values
UPDATE recode 
   SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';

-- Update to group snow removal values
UPDATE recode 
   SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow Removal/Concerns' OR standardized LIKE 'Snow/Ice/Hazard Removal';
    
-- Examine effect of updates
SELECT DISTINCT standardized 
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';


-------------------

-- Code from previous step
DROP TABLE IF EXISTS recode;

CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
    FROM evanston311;
  
UPDATE recode SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';

UPDATE recode SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';

-- Update to group unused/inactive values
UPDATE recode 
   SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 
               'NO LONGER IN USE');

-- Examine effect of updates
SELECT DISTINCT standardized 
  FROM recode
 ORDER BY standardized;


-----------------------

-- Code from previous step
DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
  FROM evanston311;
UPDATE recode SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, count(*) 
-- From the original table and table with recoded values
  FROM evanston311 
       LEFT JOIN recode 
       -- Specify the table name or alias before the column name
       ON evanston311.category = recode.category 
 -- What do you need to group by to count?
 GROUP BY standardized
 -- Display the most common val values first
 ORDER BY count DESC;


-- Determine whether medium and high priority requests in the evanston311 data are more likely to contain requesters' contact information: an email address or phone number.

-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the temp table
CREATE TEMP TABLE indicators AS
  SELECT id, 
         CAST (description LIKE '%@%' AS integer) AS email,
         CAST (description LIKE '%___-___-____%' AS integer) AS phone 
    FROM evanston311;
  
SELECT priority,
       -- Compute the proportion of rows with each indicator
       sum(email)/count(*)::numeric AS email_prop, 
       sum(phone)/count(*)::numeric AS phone_prop
  -- Tables to select from
  FROM evanston311
       LEFT JOIN indicators
       -- Joining condition
       ON evanston311.id = indicators.id
 -- What are you grouping by?
 GROUP BY priority;

 -- CHAPTER 4: Date/Time types and formats

-- Date comparisons

-- Count the number of Evanston 311 requests created on January 31, 2017 by casting date_created to a date.
SELECT count(*) 
  FROM evanston311
 WHERE date_created::date = '2017-01-31';

-- Count the number of Evanston 311 requests created on February 29, 2016 by using >= and < operators.
SELECT count(*)
  FROM evanston311 
 WHERE date_created >= '2016-02-29' 
   AND date_created < '2016-03-01';

-- Count the number of requests created on March 13, 2017.
-- Specify the upper bound by adding 1 to the lower bound.
SELECT count(*)
  FROM evanston311
 WHERE date_created >= '2017-03-13'
   AND date_created < '2017-03-13'::date + 1;

-- Date arithmetic

-- Subtract the min date_created from the max
SELECT max(date_created) - min(date_created)
  FROM evanston311;

-- How old is the most recent request?
SELECT now() - max(date_created)
  FROM evanston311;

-- Add 100 days to the current timestamp
SELECT now() + '100 days'::interval;

-- Select the current timestamp, 
-- and the current timestamp + 5 minutes
SELECT now() + '5 minutes'::interval;

-- Completion time by category

-- Which category of Evanston 311 requests takes the longest to complete?
-- Select the category and the average completion time by category
SELECT category, 
       avg(date_completed - date_created) AS completion_time
  FROM evanston311
 group by category
-- Order the results
 order by completion_time desc;

-- How many requests are created in each of the 12 months during 2016-2017?

-- Extract the month from date_created and count requests
SELECT date_part('month', date_created) AS month, 
       count(*)
  FROM evanston311
 -- Limit the date range
 WHERE date_created >= '2016-01-01'
   AND date_created < '2018-01-01'
 -- Group by what to get monthly counts?
 GROUP BY month;

-- What is the most common hour of the day for requests to be created?
-- Get the hour and count requests
SELECT date_part('hour', date_created) AS hour,
       count(*)
  FROM evanston311
 GROUP BY hour
 -- Order results to select most common
 ORDER BY count(*) desc
 LIMIT 1;

-- During what hours are requests usually completed? Count requests completed by hour.
-- Count requests completed by hour
SELECT date_part('hour', date_completed) AS hour,
       count(*)
  FROM evanston311
 group by hour
 order by hour desc;

-- Variation by day of week

-- Does the time required to complete a request vary by the day of the week on which the request was created?
-- Select name of the day of the week the request was created 
SELECT to_char(date_created, 'day') AS day, 
       -- Select avg time between request creation and completion
       avg(date_completed - date_created) AS duration
  FROM evanston311 
 -- Group by the name of the day of the week and 
 -- integer value of day of week the request was created
 GROUP BY day, EXTRACT(DOW FROM date_created)
 -- Order by integer value of the day of the week 
 -- the request was created
 ORDER BY EXTRACT(DOW FROM date_created);

-- Date truncation
-- Unlike date_part() or EXTRACT(), date_trunc() keeps date/time units larger than the field you specify as part of the date. So instead of just extracting one component of a timestamp, date_trunc() returns the specified unit and all larger ones as well.

-- Using date_trunc(), find the average number of Evanston 311 requests created per day for each month of the data. Ignore days with no requests when taking the average.

-- Aggregate daily counts by month
SELECT date_trunc('month', day) AS month,
       avg(count)

       
  -- Subquery to compute daily counts
  FROM (SELECT date_trunc('day', date_created) AS day,
               count(*) AS count
          FROM evanston311
         GROUP BY day) AS daily_count


 GROUP BY month
 ORDER BY month;

-- Find missing dates

SELECT day
-- 1) Subquery to generate all dates
-- from min to max date_created
  FROM (SELECT generate_series(min(date_created),
                               max(date_created),
                               '1 day')::date AS day
          -- What table is date_created in?
          FROM evanston311) AS all_dates
-- 4) Select dates (day from above) that are NOT IN the subquery
 WHERE day NOT IN
       -- 2) Subquery to select all date_created values as dates
       (SELECT date_created::date
          FROM evanston311);

-- Custom aggregation periods
-- Find the median number of Evanston 311 requests per day in each six month period from 2016-01-01 to 2018-06-30.

-- Generate 6 month bins covering 2016-01-01 to 2018-06-30

-- Create lower bounds of bins
SELECT generate_series('2016-01-01',  -- First bin lower value
                       '2018-01-01',  -- Last bin lower value (enclosed in single quotes)
                       '6 months'::interval) AS lower,
       generate_series('2016-07-01',  -- First bin upper value
                       '2018-07-01',  -- Last bin upper value
                       '6 months'::interval) AS upper;

-- Count number of requests made per day
SELECT day, count(date_created) AS count
-- Use a daily series from 2016-01-01 to 2018-06-30 
-- to include days with no requests
  FROM (SELECT generate_series('2016-01-01',  -- series start date
                               '2018-06-30 ',  -- series end date
                               '1 day'::interval)::date AS day) AS daily_series
       LEFT JOIN evanston311
       -- match day from above (which is a date) to date_created
       ON day = date_created::date
 GROUP BY day;

-- Bins from Step 1
WITH bins AS (
	 SELECT generate_series('2016-01-01',
                            '2018-01-01',
                            '6 months'::interval) AS lower,
            generate_series('2016-07-01',
                            '2018-07-01',
                            '6 months'::interval) AS upper),
-- Daily counts from Step 2
     daily_counts AS (
     SELECT day, count(date_created) AS count
       FROM (SELECT generate_series('2016-01-01',
                                    '2018-06-30',
                                    '1 day'::interval)::date AS day) AS daily_series
            LEFT JOIN evanston311
            ON day = date_created::date
      GROUP BY day)
-- Select bin bounds 
SELECT lower, 
       upper, 
       -- Compute median of count for each bin
       percentile_disc(0.5) WITHIN GROUP (ORDER BY count) AS median
  -- Join bins and daily_counts
  FROM bins
       LEFT JOIN daily_counts
       -- Where the day is between the bin bounds
       ON day >= lower
          AND day < upper
 -- Group by bin bounds
 GROUP BY lower, upper
 ORDER BY lower;

-- generate series with all days from 2016-01-01 to 2018-06-30
WITH all_days AS 
     (SELECT generate_series('2016-01-01',
                             '2018-06-30',
                             '1 day'::interval) AS date),
     -- Subquery to compute daily counts
     daily_count AS 
     (SELECT date_trunc('day', date_created) AS day,
             count(*) AS count
        FROM evanston311
       GROUP BY day)
-- Aggregate daily counts by month using date_trunc
SELECT date_trunc('month', date) AS month,
       -- Use coalesce to replace NULL count values with 0
       avg(coalesce(count, '0')) AS average
  FROM all_days
       LEFT JOIN daily_count
       -- Joining condition
       ON all_days.date=daily_count.day
 GROUP BY month
 ORDER BY month; 

-- Longest gap

-- Compute the gaps
WITH request_gaps AS (
        SELECT date_created,
               -- lead or lag
               lag(date_created) OVER (ORDER BY date_created) AS previous,
               -- compute gap as date_created minus lead or lag
               date_created - lag(date_created) OVER (order by date_created) AS gap
          FROM evanston311)
-- Select the row with the maximum gap
SELECT *
  FROM request_gaps
-- Subquery to select maximum gap from request_gaps
 WHERE gap = (SELECT max(gap)
                FROM request_gaps);


-- Requests in category "Rodents- Rats" average over 64 days to resolve. Why
-- Investigate in 4 steps:

-- Why is the average so high? Check the distribution of completion times. Hint: date_trunc() can be used on intervals.

-- See how excluding outliers influences average completion times.

-- Do requests made in busy months take longer to complete? Check the correlation between the average completion time and requests per month.

-- Compare the number of requests created per month to the number completed.

-- step 1
-- Truncate the time to complete requests to the day
SELECT date_trunc('day', date_completed-date_created) AS completion_time,
-- Count requests with each truncated time
       count(*)
  FROM evanston311
-- Where category is rats
 WHERE category = 'Rodents- Rats'
-- Group and order by the variable of interest
 GROUP BY completion_time
 ORDER BY completion_time;

-- step 2
SELECT category, 
       -- Compute average completion time per category
       avg(date_completed - date_created) AS avg_completion_time
  FROM evanston311
-- Where completion time is less than the 95th percentile value
 WHERE date_completed - date_created < 
-- Compute the 95th percentile of completion time in a subquery
         (SELECT percentile_disc(0.95) WITHIN GROUP (ORDER BY date_completed - date_created)
            FROM evanston311)
 GROUP BY category
-- Order the results
 ORDER BY avg_completion_time DESC;

-- step 3
-- Compute correlation (corr) between 
-- avg_completion time and count from the subquery
SELECT corr(avg_completion, count)
  -- Convert date_created to its month with date_trunc
  FROM (SELECT date_trunc('month', date_created) AS month, 
               -- Compute average completion time in number of seconds           
               avg(EXTRACT(epoch FROM date_completed - date_created)) AS avg_completion, 
               -- Count requests per month
               count(*) AS count
          FROM evanston311
         -- Limit to rodents
         WHERE category='Rodents- Rats' 
         -- Group by month, created above
         GROUP BY month) 
         -- Required alias for subquery 
         AS monthly_avgs;

--step 4

-- Compute monthly counts of requests created
WITH created AS (
       SELECT date_trunc('month', date_created) AS month,
              count(*) AS created_count
         FROM evanston311
        WHERE category='Rodents- Rats'
        GROUP BY month),
-- Compute monthly counts of requests completed
      completed AS (
       SELECT date_trunc('month', date_completed) AS month,
              count(*) AS completed_count
         FROM evanston311
        WHERE category='Rodents- Rats'
        GROUP BY month)
-- Join monthly created and completed counts
SELECT created.month, 
       created_count, 
       completed_count
  FROM created
       INNER JOIN completed
       ON created.month=completed.month
 ORDER BY created.month;











