WITH RECURSIVE ordered_subs AS (
  SELECT 
    customer_id, plan_id, start_date,
    LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan_id,
    LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start_date
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
),
paid_segments AS (
  SELECT customer_id, plan_id, start_date, prev_plan_id,
    COALESCE(next_start_date, '2021-01-01') AS segment_end
  FROM ordered_subs
  WHERE plan_id IN (1,2,3)   -- only paid plans: basic monthly, pro monthly, pro annual
),
month_offsets AS (
  SELECT 0 AS n
  UNION ALL
  SELECT n + 1 FROM month_offsets WHERE n < 11   -- max 12 monthly payments in a year
),
monthly_payments AS (
  SELECT 
    s.customer_id, s.plan_id, p.plan_name,
    DATE_ADD(s.start_date, INTERVAL mo.n MONTH) AS payment_date,
    -- first payment is reduced only if upgrading straight from basic monthly
    CASE 
      WHEN mo.n = 0 AND s.prev_plan_id = 1 THEN p.price - 9.90
      ELSE p.price
    END AS amount
  FROM paid_segments s
  JOIN plans p ON s.plan_id = p.plan_id
  JOIN month_offsets mo
  WHERE s.plan_id IN (1,2)   -- basic monthly, pro monthly only
    AND DATE_ADD(s.start_date, INTERVAL mo.n MONTH) < s.segment_end
    AND DATE_ADD(s.start_date, INTERVAL mo.n MONTH) <= '2020-12-31'
),
annual_payments AS (
  SELECT 
    s.customer_id, s.plan_id, p.plan_name,
    s.start_date AS payment_date,
    CASE WHEN s.prev_plan_id = 1 THEN p.price - 9.90 ELSE p.price END AS amount
  FROM paid_segments s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE s.plan_id = 3   -- pro annual only
),
all_payments AS (
  SELECT * FROM monthly_payments
  UNION ALL
  SELECT * FROM annual_payments
)
SELECT customer_id, plan_id, plan_name, payment_date, amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM all_payments
ORDER BY customer_id, payment_date;