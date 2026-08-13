WITH ranked AS (
  SELECT customer_id, plan_id, start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
  FROM subscriptions
)
SELECT 
  COUNT(*) AS churned_after_trial,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 0) AS pct
FROM ranked
WHERE rn = 2 AND plan_id = 4;
