SELECT * FROM dbo.sales;

-- Getting list of column names
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'sales'

--Basic SQL Questions:

--1. How many unique languages are represented in the dataset?
SELECT COUNT(DISTINCT language_code) as unique_languages
FROM dbo.sales

--2. Can you provide a list of the top 5 bestselling books and their authors?
SELECT TOP 5 [units sold] as "Units Sold", Author -- Can use "LIMIT" if it wasn't for SQL Server
FROM dbo.sales
ORDER BY [units sold] DESC;

--3. What is the total number of books sold in the dataset?
SELECT SUM([units sold]) AS "Total Books Sold"
FROM dbo.sales;

--4. How many books belong to each genre?
SELECT genre, COUNT(*) as GENRE_COUNT
FROM dbo.sales
GROUP BY genre 

--5. Can you list the top 10 publishers by total revenue?
SELECT TOP 10 Publisher as "Top 10 Publishers", ROUND(SUM([publisher revenue]), 2) AS total_revenue
FROM dbo.sales
GROUP BY Publisher
ORDER BY total_revenue DESC;



SELECT * FROM dbo.sales;
--Moderate SQL Questions:

-- 1. Which genres have the highest total gross sales? List the top 5 genres along with their total gross sales.
SELECT genre, SUM([gross sales]) as "Total Gross Sales"
FROM dbo.sales
GROUP BY genre 
ORDER BY [Total Gross Sales] DESC

-- 2. What is the average revenue earned by each publisher? List the publishers along with their average revenue.
SELECT Publisher, ROUND(AVG([publisher revenue]), 2) as "Average Revenue Earned per Publisher"
FROM dbo.sales
GROUP BY Publisher
ORDER BY [Average Revenue Earned per Publisher] DESC

-- 3.  What is the total gross sales for books with an average rating above 4.5?
SELECT [Book Name], SUM([gross sales]) as "Total Gross Sale"
FROM dbo.sales
WHERE Book_average_rating > 4.5 AND [Book Name] IS NOT NULL -- Since top reult I got was a NULL value
GROUP BY [Book Name]

-- 4. What is the trend of gross sales over the years? Calculate the total gross sales for each year and arrange the results by year.
SELECT [Publishing Year], SUM([gross sales]) as "Total Gross Sales by Year"
FROM dbo.sales
GROUP BY [Publishing Year]
HAVING [Publishing Year] > 0 AND [Publishing Year] IS NOT NULL -- I am not sure why there were negative years
ORDER BY [Publishing Year] ASC

-- 5. What is the average sales rank for each genre?
SELECT genre, ROUND (AVG([sales rank]), 2) AS "Average Sales Rank"
FROM dbo.sales
GROUP BY genre



SELECT * FROM dbo.sales;
-- Hard SQL Questions:

-- 1. Identify the top-selling book in each genre.
-- For each genre, find the book with the highest number of units sold.
-- Subquery selects the top-selling book for each genre.
-- Outer query retrieves book name, genre, and units sold.
SELECT [Book Name], genre AS "Genre", [units sold]
FROM dbo.sales s1
WHERE [Book Name] = (
    SELECT TOP 1 [Book Name]
    FROM dbo.sales s2
    WHERE s1.genre = s2.genre
    ORDER by [units sold] DESC
)
ORDER BY [units sold] DESC;

-- 2. Identify any significant correlation between the number of units sold and gross sales of books across different genres.
-- Group by genre to calculate total units sold and gross sales.
-- Order by total units sold to identify any correlation.
SELECT 
    genre,
    SUM([units sold]) AS total_units_sold,
    SUM([gross sales]) AS total_gross_sales
FROM dbo.sales
GROUP BY genre
ORDER BY total_units_sold;

-- 3. Determine the median sale price for each genre.
-- Calculate the median sale price within each genre.
-- Use PERCENTILE_CONT() window function to find the median.
SELECT DISTINCT
    genre,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [sale price]) OVER(PARTITION BY genre) AS median_sale_price
FROM dbo.sales;

-- 4. Handle inconsistencies in the 'language_code' column, such as different representations of the same language.
-- Identify distinct language codes to understand inconsistencies.
SELECT DISTINCT language_code FROM dbo.sales;

-- Update language_code to a single representation for English.
-- All variations of English language codes are set to 'eng' for simplification.
UPDATE sales
SET language_code = 'eng'
WHERE language_code IN ('en-GB', 'en-CA', 'en-US');
