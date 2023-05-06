#checking if there are any null values in the dataset

SELECT * 
FROM financial_transactions
WHERE customer_id is null;

SELECT *
FROM financial_transactions
WHERE type is null;

SELECT*
FROM financial_transactions
WHERE date is null;

#-----------------------------------------------------------------
#Comparative analysis by yearly and transaction_method
SELECT customer_id, SUM(amount) as Total_Revenue
FROM financial_transactions
GROUP BY customer_id
ORDER BY Total_Revenue DESC;

#changing name of the column 
ALTER TABLE financial_transactions
RENAME COLUMN type TO transaction_method;

#Extracting TOP10 total_revenue customer who used credit, debit, transfer during 2022.
SELECT customer_id, SUM(amount) as Total_Revenue
FROM financial_transactions
WHERE date BETWEEN '2022-01-01' AND '2022-12-31' and transaction_method like 'credit'
GROUP BY customer_id
ORDER BY Total_Revenue DESC
LIMIT 10;

SELECT customer_id, SUM(amount) as Total_Revenue
FROM financial_transactions
WHERE date BETWEEN '2022-01-01' AND '2022-12-31' and transaction_method like 'debit'
GROUP BY customer_id
ORDER BY Total_Revenue DESC
LIMIT 10;

SELECT customer_id, SUM(amount) as Total_Revenue
FROM financial_transactions
WHERE date BETWEEN '2022-01-01' AND '2022-12-31' and transaction_method like 'transfer'
GROUP BY customer_id
ORDER BY Total_Revenue DESC
LIMIT 10;

#Checking the number of each transaction method
SELECT transaction_method, COUNT(*) as transaction_method_count
FROM financial_transactions
GROUP BY transaction_method
ORDER BY transaction_method_count desc

#Selecting the top 10 customers who used credit cards, debit cards, transfer frequently in 2022
SELECT customer_id, transaction_method, COUNT(*) as transaction_method_count
FROM financial_transactions
WHERE date between '2022-01-01' AND '2022-12-31' and transaction_method like 'credit'
GROUP BY customer_id, transaction_method
ORDER BY transaction_method_count desc
limit 10;

SELECT customer_id, transaction_method, COUNT(*) as transaction_method_count
FROM financial_transactions
WHERE date between '2022-01-01' AND '2022-12-31' and transaction_method like 'debit'
GROUP BY customer_id, transaction_method
ORDER BY transaction_method_count desc
limit 10;

SELECT customer_id, transaction_method, COUNT(*) as transaction_method_count
FROM financial_transactions
WHERE date between '2022-01-01' AND '2022-12-31' and transaction_method like 'transfer'
GROUP BY customer_id, transaction_method
ORDER BY transaction_method_count desc
limit 10;

#transaction that occurs 
#between each pair of transaction_id and customer_id that overlap more than once
SELECT customer_id, transaction_id, COUNT(*) AS duplicate_count
FROM financial_transactions
WHERE 
    (customer_id, transaction_id) IN (
        SELECT customer_id, transaction_id
        FROM financial_transactions
        GROUP BY customer_id, transaction_id
        HAVING COUNT(*) >= 2
    )
GROUP BY customer_id, transaction_id
ORDER BY duplicate_count DESC;
