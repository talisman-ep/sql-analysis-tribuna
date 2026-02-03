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
