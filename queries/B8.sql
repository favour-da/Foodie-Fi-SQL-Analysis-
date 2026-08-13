SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual_2020
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;
