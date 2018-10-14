-- ASSIGNMENT 3

-- NAME: VICTOR ALVAREZ PAJARO
-- DATE: OCTOBER 10TH, 2018


\pset footer off


\echo '\nbest referral source of buyers'
SELECT referrer, COUNT(*)
FROM buyers
GROUP BY referrer
ORDER BY count DESC;

-- based on the results, best referral sources are Facebook, Boatbuyer, and Craigslist


\echo '\ncustomers who have not bought a boat'
SELECT buyers.*
FROM buyers
LEFT JOIN transactions
    ON buyers.cust_id = transactions.cust_id
WHERE transactions.trans_id IS NULL;


\echo '\nboats that have not sold'
SELECT boats.*
FROM boats
LEFT JOIN transactions
    ON boats.prod_id = transactions.prod_id
WHERE transactions.trans_id IS NULL;


\echo '\nboat Alan Weston bought'
SELECT boats.*
FROM buyers
INNER JOIN transactions
    ON buyers.cust_id = transactions.cust_id
        INNER JOIN boats
            ON transactions.prod_id = boats.prod_id
WHERE buyers.fname='Alan'
    AND buyers.lname='Weston';


\echo '\nVIP customers (anyone who has bought more than one boat)'
WITH vip_customers AS (
    SELECT cust_id, COUNT(cust_id) AS number_of_boats_bought
    FROM transactions
    GROUP BY cust_id
    HAVING COUNT(cust_id) > 1
)
SELECT buyers.cust_id, buyers.fname, buyers.lname, vip_customers.number_of_boats_bought
FROM buyers
INNER JOIN vip_customers
    ON buyers.cust_id = vip_customers.cust_id;
