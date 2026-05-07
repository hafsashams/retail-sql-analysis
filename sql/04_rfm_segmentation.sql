USE retail_analysis;

WITH max_date AS (
    SELECT MAX(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i')) as last_date 
    FROM clean_retail
),
customer_stats AS (
    SELECT
        customer_id,
        country,
        COUNT(DISTINCT invoice) as frequency,
        ROUND(SUM(revenue), 2) as monetary,
        ROUND(AVG(revenue), 2) as avg_order_value,
        MAX(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i')) as last_purchase_date,
        MIN(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i')) as first_purchase_date,
        DATEDIFF(
            MAX(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i')), 
            MIN(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i'))
        ) as customer_lifespan_days
    FROM clean_retail
    GROUP BY customer_id, country
),
with_recency AS (
    SELECT c.*,
        DATEDIFF((SELECT last_date FROM max_date), c.last_purchase_date) as recency_days
    FROM customer_stats c
),
scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days DESC) as recency_score,
        NTILE(4) OVER (ORDER BY frequency ASC) as frequency_score,
        NTILE(4) OVER (ORDER BY monetary ASC) as monetary_score
    FROM with_recency
)
SELECT *,
    ROUND((recency_score + frequency_score + monetary_score) / 3, 2) as rfm_score,
    CASE 
        WHEN frequency_score = 4 AND monetary_score = 4
            THEN 'Champion'
        WHEN recency_score >= 3 AND frequency_score >= 3 
            THEN 'Loyal'
        WHEN monetary_score = 4
            THEN 'High Value'
        WHEN recency_score <= 1
            THEN 'At Risk'
        ELSE 'Regular'
    END as customer_segment
FROM scored
ORDER BY monetary DESC;