-- Group Chat Database System
-- Analytical SQL queries from the data-insights milestone.
-- These queries assume the schema in 01_schema.sql and 02_messaging_and_indexes.sql.

-- 1. Message count per channel
SELECT c.name, COUNT(m.message_id) AS message_count
FROM channels AS c
LEFT JOIN chat_inbox AS m ON m.channel_id = c.channel_id
GROUP BY c.channel_id, c.name
ORDER BY message_count DESC;

-- 2. Message count per user
SELECT u.username, COUNT(m.message_id) AS message_count
FROM users AS u
LEFT JOIN chat_inbox AS m ON m.username = u.username
GROUP BY u.user_id, u.username
ORDER BY message_count DESC;

-- 3. Messages created in the last 24 hours
SELECT COUNT(*) AS messages_last_24_hours
FROM chat_inbox
WHERE created_at >= NOW() - INTERVAL '24 hours';

-- 4. Most active channel in the last 3 days
SELECT c.name, COUNT(m.message_id) AS message_count
FROM channels AS c
JOIN chat_inbox AS m ON m.channel_id = c.channel_id
WHERE m.created_at >= NOW() - INTERVAL '3 days'
GROUP BY c.channel_id, c.name
ORDER BY message_count DESC
LIMIT 1;

-- 5. Top 3 active users in each channel
WITH user_channel_counts AS (
    SELECT
        channel_id,
        username,
        COUNT(*) AS message_count
    FROM chat_inbox
    GROUP BY channel_id, username
),
ranked_users AS (
    SELECT
        channel_id,
        username,
        message_count,
        ROW_NUMBER() OVER (
            PARTITION BY channel_id
            ORDER BY message_count DESC, username
        ) AS user_rank
    FROM user_channel_counts
)
SELECT channel_id, username, message_count, user_rank
FROM ranked_users
WHERE user_rank <= 3
ORDER BY channel_id, user_rank;

-- 6. Average time between consecutive messages in each channel.
-- This measures message intervals, not necessarily reply response times.
WITH message_intervals AS (
    SELECT
        channel_id,
        created_at - LAG(created_at) OVER (
            PARTITION BY channel_id
            ORDER BY created_at
        ) AS time_between_messages
    FROM chat_inbox
)
SELECT
    channel_id,
    AVG(time_between_messages) AS average_time_between_messages
FROM message_intervals
WHERE time_between_messages IS NOT NULL
GROUP BY channel_id
ORDER BY channel_id;

-- 7. Messages per channel member
WITH member_counts AS (
    SELECT channel_id, COUNT(DISTINCT user_id) AS member_count
    FROM channel_members
    GROUP BY channel_id
),
message_counts AS (
    SELECT channel_id, COUNT(*) AS message_count
    FROM chat_inbox
    GROUP BY channel_id
)
SELECT
    c.channel_id,
    c.name,
    COALESCE(mc.message_count, 0) AS message_count,
    COALESCE(mem.member_count, 0) AS member_count,
    COALESCE(mc.message_count, 0)::DECIMAL
        / NULLIF(mem.member_count, 0) AS messages_per_member
FROM channels AS c
LEFT JOIN message_counts AS mc ON mc.channel_id = c.channel_id
LEFT JOIN member_counts AS mem ON mem.channel_id = c.channel_id
ORDER BY c.name;

-- 8. Number of shared channels for each pair of users
-- The user_id comparison prevents duplicate and mirrored pairs.
SELECT
    u1.username AS user_one,
    u2.username AS user_two,
    COUNT(*) AS shared_channel_count
FROM channel_members AS cm1
JOIN channel_members AS cm2
    ON cm1.channel_id = cm2.channel_id
   AND cm1.user_id < cm2.user_id
JOIN users AS u1 ON u1.user_id = cm1.user_id
JOIN users AS u2 ON u2.user_id = cm2.user_id
GROUP BY u1.username, u2.username
ORDER BY shared_channel_count DESC, user_one, user_two;

-- 9. Most frequent consecutive-message username pairs, including self-pairs
WITH message_pairs AS (
    SELECT
        channel_id,
        LAG(username) OVER (
            PARTITION BY channel_id
            ORDER BY created_at, message_id
        ) AS previous_username,
        username AS current_username
    FROM chat_inbox
),
pair_counts AS (
    SELECT
        previous_username,
        current_username,
        COUNT(*) AS pair_count
    FROM message_pairs
    WHERE previous_username IS NOT NULL
    GROUP BY previous_username, current_username
),
ranked_pairs AS (
    SELECT *,
        ROW_NUMBER() OVER (
            ORDER BY pair_count DESC, previous_username, current_username
        ) AS pair_rank
    FROM pair_counts
)
SELECT previous_username, current_username, pair_count
FROM ranked_pairs
ORDER BY pair_count DESC, previous_username, current_username;

-- 10. Most frequent consecutive-message username pairs, excluding self-pairs
WITH message_pairs AS (
    SELECT
        channel_id,
        LAG(username) OVER (
            PARTITION BY channel_id
            ORDER BY created_at, message_id
        ) AS previous_username,
        username AS current_username
    FROM chat_inbox
),
pair_counts AS (
    SELECT
        previous_username,
        current_username,
        COUNT(*) AS pair_count
    FROM message_pairs
    WHERE previous_username IS NOT NULL
      AND previous_username <> current_username
    GROUP BY previous_username, current_username
)
SELECT previous_username, current_username, pair_count
FROM pair_counts
ORDER BY pair_count DESC, previous_username, current_username;
