-- ASSIGNMENT 2

-- NAME: VICTOR ALVAREZ PAJARO
-- DATE: OCTOBER 3TH, 2018


-- PART I - THE SCHEMA

-- 2.

-- This database is in Normal Form. Specifically, it is in 3NF as, in my opinion, it passes the criteria for being of this type. All tables
-- pass the 1NF criterion. And table countrylanguage passes the criteria for 2NF and 3NF (no partial or transitive dependencies). Hence, the
-- database is in 3NF.

-- BETTER ANSWER: database is in 2NF.



-- PART II - QUERIES

-- 1.

\echo '\n1. Top ten countries by economic activity (GNP)'

SELECT name, gnp
FROM country
ORDER BY gnp DESC
LIMIT 10;


-- 2.

\echo '\n2. Top ten countries by GNP per capita'

SELECT name, (gnp / population)::NUMERIC(10, 5) AS gnp_per_capita
FROM country
WHERE population != 0
ORDER BY gnp_per_capita DESC
LIMIT 10;


-- 3.

\echo '\n3. Ten most densely populated countries'

SELECT name, (population / surfacearea)::NUMERIC(10, 5) AS population_density
FROM country
ORDER BY population_density DESC
LIMIT 10;

\echo '\n3. Ten least densely populated countries'

-- in where clause (gnp != 0)
SELECT name, (population / surfacearea)::NUMERIC(10, 5) AS population_density
FROM country
WHERE population != 0
ORDER BY population_density ASC
LIMIT 10;


-- 4.

\echo '\n4. Different forms of government'

SELECT DISTINCT governmentform
FROM country;

\echo '\n4. Most frequent forms of government'
SELECT governmentform, COUNT(*) AS ncount
FROM country
GROUP BY governmentform
ORDER BY ncount DESC;

-- 5.

\echo '\n5. Countries with highest life expectancy (top ten)'

-- SELECT name, lifeexpectancy FROM country WHERE lifeexpectancy IS NOT NULL ORDER BY lifeexpectancy DESC;

SELECT name, lifeexpectancy
FROM country
WHERE lifeexpectancy IS NOT NULL
ORDER BY lifeexpectancy DESC
LIMIT 10;


-- 6.

\echo '\n6. Top ten countries by total population and official language'

SELECT name, population, language AS official_language
FROM country
INNER JOIN countrylanguage
    ON country.code = countrylanguage.countrycode
WHERE isofficial = 't'  -- also, WHERE isofficial = TRUE
ORDER BY population DESC
LIMIT 10;

-- Nigeria is supposed to be the 10th most populous country, not Mexico, but has "no official language" in countrylanguage


-- 7.

\echo '\n7. Top ten most populated cities with country and continent'

SELECT
    city.name AS city_name,
    city.population,
    country.name AS country_name,
    country.continent
FROM city
INNER JOIN country
    ON city.countrycode = country.code
ORDER BY city.population DESC
LIMIT 10;


-- 8.

\echo '\n8. Official language of top 10 cities'

SELECT
    city.name AS city_name,
    city.population,
    country.name AS country_name,
    country.continent,
    countrylanguage.language AS official_language
FROM city
INNER JOIN country
    ON city.countrycode = country.code
        INNER JOIN countrylanguage
            ON country.code = countrylanguage.countrycode
WHERE countrylanguage.isofficial = 't'
ORDER BY city.population DESC
LIMIT 10;


-- 9.

\echo '\n9. Cities capitals of their countries'

-- TLDR; query is too complicated. Next time look at the scheme diagram!!
SELECT
    city.name AS city_name,
    city.population,
    country.name AS country_name,
    country.continent
FROM city
INNER JOIN country
    ON city.countrycode = country.code
WHERE city.id IN (
                    SELECT capital
                    FROM country
                    INNER JOIN city
                        ON country.code = city.countrycode
                    ORDER BY city.population DESC
                    LIMIT 10
                )
ORDER BY city.population DESC
LIMIT 4;


-- 10.

\echo '\n10. Percentage of the country\'s population living in the capital'

SELECT
    city.name AS city_name,
    city.population,
    country.name AS country_name,
    country.continent,
    (CAST(city.population AS FLOAT) / CAST(country.population AS FLOAT) * 100)::NUMERIC(10, 3) AS percentage_of_population_living_in_capital
FROM city
INNER JOIN country
    ON city.countrycode = country.code
ORDER BY city.population DESC
LIMIT 10;

