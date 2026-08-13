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
