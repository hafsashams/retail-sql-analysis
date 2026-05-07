USE retail_analysis;

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i'), '%Y-%m') as month,
        COUNT(DISTINCT invoice) as total_orders,
        COUNT(DISTINCT customer_id) as unique_customers,
        ROUND(SUM(revenue), 2) as total_revenue,
        ROUND(AVG(revenue), 2) as avg_order_value
    FROM clean_retail
    GROUP BY DATE_FORMAT(STR_TO_DATE(invoice_date, '%d/%m/%Y %H:%i'), '%Y-%m')
),
with_growth AS (
    SELECT *,
        LAG(total_revenue) OVER (ORDER BY month) as prev_month_revenue,
        ROUND(
            (total_revenue - LAG(total_revenue) OVER (ORDER BY month)) 
            / LAG(total_revenue) OVER (ORDER BY month) * 100
        , 2) as mom_growth_pct
    FROM monthly_revenue
)
SELECT *
FROM with_growth
ORDER BY month;