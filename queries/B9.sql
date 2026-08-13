WITH trial AS (
  SELECT customer_id, start_date AS trial_date FROM subscriptions WHERE plan_id = 0
),
annual AS (
  SELECT customer_id, start_date AS annual_date FROM subscriptions WHERE plan_id = 3
)
SELECT ROUND(AVG(DATEDIFF(a.annual_date, t.trial_date)), 0) AS avg_days_to_annual
FROM trial t
JOIN annual a ON t.customer_id = a.customer_id;

