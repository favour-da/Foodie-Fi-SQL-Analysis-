SELECT p.plan_name, COUNT(*) AS event_count
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name
ORDER BY event_count DESC;

