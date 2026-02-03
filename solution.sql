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
