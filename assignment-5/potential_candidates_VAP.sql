/*
    ASSIGNMENT 5

    NAME: VICTOR ALVAREZ PAJARO
    DATE: NOVEMBER 28TH, 2018
*/

\pset footer off

/*

MY SOLUTIONS FOR HOMEWORK 4, FOR REFERENCE

-- QUESTION 1

-- create database
CREATE DATABASE assignment4;
\c assignment4

-- drop tables if they already exists
DROP TABLE IF EXISTS securities CASCADE;
DROP TABLE IF EXISTS fundamentals;
DROP TABLE IF EXISTS prices;
DROP TABLE IF EXISTS top_performers;

-- create securities table
CREATE TABLE securities (
    symbol              TEXT PRIMARY KEY,
    company             TEXT,
    sector              TEXT,
    subindustry         TEXT,
    initial_trade_date  DATE
);

-- create fundamentals table
CREATE TABLE fundamentals (
    id                                  INTEGER,
    symbol                              TEXT REFERENCES securities (symbol),
    year_ending                         DATE,
    cash_and_cash_equivalents           NUMERIC(15),
    earnings_before_interest_and_taxes  NUMERIC(15),
    gross_margin                        INTEGER,
    net_income                          NUMERIC(15),
    total_assets                        NUMERIC(15),
    total_liabilities                   NUMERIC(15),
    total_revenue                       NUMERIC(15),
    year                                INTEGER,
    earnings_per_share                  NUMERIC(30, 15),
    shares_outstanding                  NUMERIC(30, 15)
);

-- create prices table
CREATE TABLE prices (
    "date"  DATE,
    symbol  TEXT REFERENCES securities (symbol),
    "open"  NUMERIC(30, 15),
    "close" NUMERIC(30, 15),
    low     NUMERIC(30, 15),
    high    NUMERIC(30, 15),
    volume  NUMERIC(15)
);

-- copy data into tables
\COPY securities FROM './securities.csv' CSV;
\COPY fundamentals FROM './fundamentals.csv' CSV;
\COPY prices FROM './prices.csv' CSV;



-- QUESTION 2

-- extract year, month, and day from "date" column
CREATE TEMP TABLE some_table AS
    SELECT  symbol,
            "date",
            EXTRACT (YEAR FROM "date") AS year,
            EXTRACT (MONTH FROM "date") AS month,
            EXTRACT (DAY FROM "date") AS day,
            "close"
    FROM prices
    ORDER BY symbol;

-- select last day of year and close price for every symbol per year
CREATE TEMP TABLE some_table2 AS
    SELECT  symbol,
            "date",
            year,
            month,
            FIRST_VALUE ("day") OVER (PARTITION BY symbol, year ORDER BY "date" DESC) AS last_day_of_year,
            FIRST_VALUE ("close") OVER (PARTITION BY symbol, year ORDER BY "date" DESC) AS close_price
    FROM some_table;

-- filter by last day of year
CREATE TEMP TABLE some_table3 AS
    SELECT  symbol,
            "date",
            year,
            close_price
    FROM some_table2
    WHERE   month = 12
            AND (EXTRACT (DAY FROM "date")) = last_day_of_year;

-- add last_year_close_price column
CREATE TEMP TABLE some_table4 AS
    SELECT  symbol,
            "date",
            year,
            close_price,
            LEAD (close_price, 1) OVER (PARTITION BY symbol ORDER BY year DESC) AS last_year_close_price
    FROM some_table3;

-- compute annual returns by symbol and year
CREATE TEMP TABLE annual_returns AS
    SELECT  symbol,
            "date",
            year,
            close_price,
            last_year_close_price,
            ((close_price / last_year_close_price) - 1) AS annual_return
    FROM some_table4;



-- QUESTION 3

-- top companies sorted by performance
CREATE TABLE top_performers AS
    SELECT symbol, year, "date" as year_ends, annual_return
    FROM annual_returns
    WHERE annual_return IS NOT NULL
    ORDER BY annual_return DESC
    LIMIT 30;


SELECT *
FROM top_performers;

*/



-- QUESTION 1

/*
    top_performers table from homework 4 has the following headings:

        | symbol | year | year_ends | annual_return |
*/

-- get fundamentals of all top performers
CREATE TEMP TABLE top_performers_fundamentals AS
    SELECT fundamentals.*
    FROM top_performers
        INNER JOIN fundamentals
            ON top_performers.symbol = fundamentals.symbol AND top_performers.year = fundamentals.year;


-- a) high net worth?
SELECT symbol, year, (total_assets - total_liabilities) AS net_worth
FROM top_performers_fundamentals
ORDER BY net_worth DESC;

-- high net worth growth year-over-year? (growth rate)
-- first, get fundamentals of all top performers for every year
CREATE TEMP TABLE top_performers_fundamentals_extended AS
	SELECT fundamentals.*, (total_assets - total_liabilities) AS net_worth
	FROM top_performers
		INNER JOIN fundamentals
			ON top_performers.symbol = fundamentals.symbol;

-- second, compute year-over-year net worth
SELECT
	symbol,
	year,
	net_worth,
	((net_worth - LEAD(net_worth) OVER (PARTITION BY symbol ORDER BY year DESC)) / 
		LEAD(net_worth) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS net_worth_growth
FROM top_performers_fundamentals_extended
ORDER BY net_worth_growth DESC
OFFSET 25;

-- b) high net income growth year-over-year? (growth rate)
SELECT
	symbol,
	year,
	net_income,
	((net_income - LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC)) / 
		LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS net_income_growth
FROM top_performers_fundamentals_extended
ORDER BY net_income_growth DESC
OFFSET 25;

-- c) high revenue growth year-over-year? (growth rate)
SELECT
	symbol,
	year,
	total_revenue,
	((total_revenue - LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC)) / 
		LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS revenue_growth
FROM top_performers_fundamentals_extended
ORDER BY revenue_growth DESC
OFFSET 25;

-- d) high earnings-per-share?
SELECT symbol, year, earnings_per_share
FROM top_performers_fundamentals
ORDER BY earnings_per_share DESC;

-- earnings-per-share growth (growth rate)
SELECT
	symbol,
	year,
    earnings_per_share,
	((earnings_per_share - LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC)) / 
		LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS earnings_per_share_growth
FROM top_performers_fundamentals_extended
ORDER BY earnings_per_share_growth DESC
OFFSET 25;

-- e) low price-to-earnings ratio?
-- first, get share price and earnings per share for all top performers
CREATE TEMP TABLE top_performers_share_price_earnings_per_share AS
    SELECT top_performers.symbol, top_performers.year, prices.close AS share_price, fundamentals.earnings_per_share
    FROM top_performers
    	INNER JOIN prices
    		ON top_performers.symbol = prices.symbol AND top_performers.year_ends = prices.date
    			INNER JOIN fundamentals
    				ON top_performers.symbol = fundamentals.symbol AND top_performers.year = fundamentals.year;

-- second, compute price-to-earnings ratio
SELECT symbol, year, (share_price / earnings_per_share) AS price_to_earnings_ratio
FROM top_performers_share_price_earnings_per_share
ORDER BY price_to_earnings_ratio ASC;

-- f) amount of liquid cash vs. total liabilities?
SELECT symbol, year, (cash_and_cash_equivalents / total_liabilities) AS liquid_cash_vs_total_liabilities
FROM top_performers_fundamentals
ORDER BY liquid_cash_vs_total_liabilities DESC;



-- QUESTION 2

/*
    factors contributing to high performance:
        * high net worth growth year-over-year
        * high revenue growth year-over-year
*/

-- top companies with similar fundamental factors
CREATE TEMP TABLE meaningful_fundamentals AS
    SELECT
    	symbol,
    	year,
    	(total_assets - total_liabilities) AS net_worth,
    	total_revenue
    FROM fundamentals;

CREATE TEMP TABLE common_factors AS
    SELECT
	    symbol,
	    year,
	    ((net_worth - LEAD(net_worth) OVER (PARTITION BY symbol ORDER BY year DESC))
	    	/ LEAD(net_worth) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS net_worth_growth,
	    ((total_revenue - LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC))
	    	/ LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC) * 100) AS revenue_growth
    FROM meaningful_fundamentals;

-- select top companies with net worth growth and revenue growth greater than 1%
-- this gives about 27 companies only
CREATE TABLE potential_candidates AS
    SELECT symbol, net_worth_growth, revenue_growth
    FROM common_factors
    WHERE net_worth_growth > 1.0
	    AND revenue_growth > 1.0
	    AND year = 2016;



-- QUESTION 3

-- show company name and sector for each symbol
SELECT symbol, company, sector, net_worth_growth, revenue_growth
FROM potential_candidates
	INNER JOIN securities
		USING(symbol);
