WITH ranked AS (
  SELECT customer_id, plan_id, start_date,
    LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan_id
  FROM subscriptions
)
SELECT COUNT(*) AS downgrades_pro_to_basic_2020
FROM ranked
WHERE prev_plan_id = 2 AND plan_id = 1 AND YEAR(start_date) = 2020;