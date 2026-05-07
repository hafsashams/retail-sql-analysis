USE retail_analysis;

WITH country_stats AS (
    SELECT 
        country,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT invoice) as total_orders,
        ROUND(SUM(revenue), 2) as total_revenue,
        ROUND(AVG(revenue), 2) as avg_order_value,
        ROUND(SUM(revenue) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer
    FROM clean_retail
    GROUP BY country
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
        ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) as revenue_share_pct
    FROM country_stats
)
SELECT *
FROM ranked
WHERE revenue_rank <= 12
ORDER BY revenue_rank;