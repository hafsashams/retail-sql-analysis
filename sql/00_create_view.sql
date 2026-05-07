USE retail_analysis;

CREATE OR REPLACE VIEW clean_retail AS
SELECT 
    invoice,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    customer_id,
    country,
    ROUND(quantity * price, 2) as revenue
FROM online_retail
WHERE 
    customer_id != 'nan'
    AND quantity > 0
    AND price > 0
    AND invoice NOT LIKE 'C%'
    AND stock_code REGEXP '^[0-9]';
    