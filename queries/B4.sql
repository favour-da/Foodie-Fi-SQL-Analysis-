SELECT 
  COUNT(DISTINCT customer_id) AS churned_customers,
  ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS churn_pct
FROM subscriptions
WHERE plan_id = 4;

