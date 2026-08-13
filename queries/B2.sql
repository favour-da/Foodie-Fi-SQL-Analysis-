SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS month_start, COUNT(*) AS trial_count
FROM subscriptions
WHERE plan_id = 0
GROUP BY month_start
ORDER BY month_start;
