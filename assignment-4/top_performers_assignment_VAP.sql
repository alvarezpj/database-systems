/*
    ASSIGNMENT 4

    NAME: VICTOR ALVAREZ PAJARO
    DATE: NOVEMBER 12TH, 2018
*/

\pset footer off

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

/*
-- drop temporary tables
DROP TABLE some_table;
DROP TABLE some_table2;
DROP TABLE some_table3;
DROP TABLE some_table4;
DROP TABLE annual_returns;
*/
