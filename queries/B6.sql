WITH ranked AS (
  SELECT customer_id, plan_id, start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
  FROM subscriptions
)
SELECT p.plan_name, COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS pct
FROM ranked r
JOIN plans p ON r.plan_id = p.plan_id
WHERE r.rn = 2
GROUP BY p.plan_name
ORDER BY customer_count DESC;
