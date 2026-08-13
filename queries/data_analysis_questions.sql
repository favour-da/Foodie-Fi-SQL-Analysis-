SELECT COUNT(DISTINCT customer_id) AS total_customers 
FROM subscriptions;

SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS month_start, COUNT(*) AS trial_count
FROM subscriptions
WHERE plan_id = 0
GROUP BY month_start
ORDER BY month_start;

SELECT p.plan_name, COUNT(*) AS event_count
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name
ORDER BY event_count DESC;

SELECT 
  COUNT(DISTINCT customer_id) AS churned_customers,
  ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS churn_pct
FROM subscriptions
WHERE plan_id = 4;

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

WITH ranked AS (
  SELECT customer_id, plan_id, start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS rn
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
)
SELECT p.plan_name, COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS pct
FROM ranked r
JOIN plans p ON r.plan_id = p.plan_id
WHERE r.rn = 1
GROUP BY p.plan_name
ORDER BY customer_count DESC;

SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual_2020
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;

WITH trial AS (
  SELECT customer_id, start_date AS trial_date FROM subscriptions WHERE plan_id = 0
),
annual AS (
  SELECT customer_id, start_date AS annual_date FROM subscriptions WHERE plan_id = 3
)
SELECT ROUND(AVG(DATEDIFF(a.annual_date, t.trial_date)), 0) AS avg_days_to_annual
FROM trial t
JOIN annual a ON t.customer_id = a.customer_id;

WITH trial AS (
  SELECT customer_id, start_date AS trial_date FROM subscriptions WHERE plan_id = 0
),
annual AS (
  SELECT customer_id, start_date AS annual_date FROM subscriptions WHERE plan_id = 3
),
days_diff AS (
  SELECT t.customer_id, DATEDIFF(a.annual_date, t.trial_date) AS days_to_annual
  FROM trial t
  JOIN annual a ON t.customer_id = a.customer_id
),
bucketed AS (
SELECT 
    customer_id, 
    days_to_annual,
    FLOOR(days_to_annual/30) AS bucket_num
   FROM days_diff
   )
SELECT 
  CONCAT(bucket_num*30, '-', bucket_num*30 + 30, ' days') AS period,
  COUNT(*) AS customer_count
FROM bucketed 
GROUP BY bucket_num
ORDER BY bucket_num;

WITH ranked AS (
  SELECT customer_id, plan_id, start_date,
    LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan_id
  FROM subscriptions
)
SELECT COUNT(*) AS downgrades_pro_to_basic_2020
FROM ranked
WHERE prev_plan_id = 2 AND plan_id = 1 AND YEAR(start_date) = 2020;