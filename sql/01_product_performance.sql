USE retail_analysis;

WITH product_stats AS (
    SELECT 
        stock_code,
        description,
        COUNT(DISTINCT invoice) as total_orders,
        SUM(quantity) as total_units_sold,
        ROUND(AVG(price), 2) as avg_price,
        ROUND(SUM(revenue), 2) as total_revenue,
        COUNT(DISTINCT customer_id) as unique_customers
    FROM clean_retail
    GROUP BY stock_code, description
),
ranked_products AS (
    SELECT *,
        RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
        ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) as revenue_share_pct
    FROM product_stats
)
SELECT *
FROM ranked_products
WHERE revenue_rank <= 15
ORDER BY revenue_rank;