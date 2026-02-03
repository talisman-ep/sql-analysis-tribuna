-- =============================================
-- Частина 1: SQL
-- =============================================

-- 1.1. Базова агрегація: ТОП-10 країн

SELECT 
    country,
    COUNT(user_id) AS total_registrations
FROM users
WHERE registration_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY country
ORDER BY total_registrations DESC
LIMIT 10;

-- 1.2. Конверсія

SELECT 
    SUBSTRING(users.registration_date, 1, 7) AS cohort_month,

    COUNT(DISTINCT users.user_id) AS total_registrations,

    COUNT(DISTINCT CASE WHEN orders.status = 'completed' THEN orders.user_id END) AS converted_users,

    ROUND(
        COUNT(DISTINCT CASE WHEN orders.status = 'completed' THEN orders.user_id END) * 100.0 
        / 
        NULLIF(COUNT(DISTINCT users.user_id), 0), 
    2) AS conversion_rate_percent

FROM users
LEFT JOIN orders ON users.user_id = orders.user_id
GROUP BY 1
ORDER BY 1;

-- 1.3 Фільтрація зі складною умовою

SELECT
	user_id,
    COUNT(order_id) AS total_transactions,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS successful_transactions
FROM orders
GROUP BY user_id
HAVING 
	total_transactions > 3
	AND
    successful_transactions = 0;

-- 1.4 Когортний аналіз (Retention)

SELECT 
    SUBSTRING(users.registration_date, 1, 7) AS cohort_month,

    COUNT(DISTINCT users.user_id) AS cohort_size,

    ROUND(
        COUNT(DISTINCT CASE WHEN CAST(JULIANDAY(events.event_date) - JULIANDAY(users.registration_date) AS INTEGER) = 1 THEN users.user_id END) * 100.0 
        / COUNT(DISTINCT users.user_id), 
    2) AS retention_day_1,

    ROUND(
        COUNT(DISTINCT CASE WHEN CAST(JULIANDAY(events.event_date) - JULIANDAY(users.registration_date) AS INTEGER) = 7 THEN users.user_id END) * 100.0 
        / COUNT(DISTINCT users.user_id), 
    2) AS retention_day_7,

    ROUND(
        COUNT(DISTINCT CASE WHEN CAST(JULIANDAY(events.event_date) - JULIANDAY(users.registration_date) AS INTEGER) = 30 THEN users.user_id END) * 100.0 
        / COUNT(DISTINCT users.user_id), 
    2) AS retention_day_30

FROM users
LEFT JOIN events ON users.user_id = events.user_id
GROUP BY cohort_month
ORDER BY cohort_month;

-- 1.5 Віконні функції

WITH weekly_stats AS (
    SELECT 
        strftime('%Y-%W', order_date) AS week_number,
        
        ROUND(AVG(amount), 2) AS current_aov
    FROM orders
    WHERE status = 'completed'
    GROUP BY week_number
)

SELECT 
    week_number, 
    current_aov,

    LAG(current_aov) OVER (ORDER BY week_number) AS prev_week_aov,

    ROUND(
        (current_aov - LAG(current_aov) OVER (ORDER BY week_number)) * 100.0 
        / 
        LAG(current_aov) OVER (ORDER BY week_number), 
    2) AS growth_percent
    
FROM weekly_stats
ORDER BY week_number;