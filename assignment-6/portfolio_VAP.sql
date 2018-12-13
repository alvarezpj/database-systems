/*
    ASSIGNMENT 6

    NAME: VICTOR ALVAREZ PAJARO
    DATE: DECEMBER 13TH, 2018
*/

\pset footer off



-- QUESTION 1

/*
-- backup database
-- assignment4 database contains all the work done on assignments 4 and 5
pg_dump -C -U postgres -d assignment4 > assignment4_backup.sql

-- restore database
psql -U postgres -f ./assignment4_backup.sql
*/



-- QUESTION 2

-- create view
CREATE VIEW portfolio AS
    WITH investment_companies AS (
            SELECT symbol, net_worth_growth, revenue_growth
            FROM potential_candidates
            WHERE symbol IN ('ABC', 'AYI', 'SIG', 'KLAC', 'DHI', 'CRM', 'BDX', 'STZ', 'HRL', 'LRCX')
        ), recent_prices AS (
            SELECT DISTINCT
                symbol,
                FIRST_VALUE(close) OVER (PARTITION BY symbol ORDER BY date DESC) AS most_recent_price
            FROM prices
        )
    SELECT investment_companies.symbol,
        securities.company AS company_name,
        securities.sector,
        recent_prices.most_recent_price,
        investment_companies.net_worth_growth as annual_worth_growth_rate,
        investment_companies.revenue_growth as annual_revenue_growth_rate
    FROM investment_companies
        INNER JOIN securities
            ON investment_companies.symbol = securities.symbol
        INNER JOIN recent_prices
            ON investment_companies.symbol = recent_prices.symbol;

SELECT * FROM portfolio;



-- QUESTION 3

-- export portfolio
-- psql -U postgres -d assignment4 -AF, -c "SELECT * FROM portfolio" > investment_portfolio.csv 



-- QUESTION 4

-- NOTE: no price data for 2017 available, so will do for time frame 2015-2016
