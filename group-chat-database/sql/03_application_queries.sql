-- Group Chat Database System
-- Representative application queries from the application-functionality milestone.
-- These statements use PostgreSQL positional parameters ($1, $2, ...).
-- Execute each statement through an application/database client with values bound.

-- 1. Login lookup
-- $1 = username
SELECT password
FROM users
WHERE username = $1;

-- 2. User registration
-- $1 = username, $2 = password hash supplied by the application
INSERT INTO users (username, password)
VALUES ($1, $2);

-- 3. Password update
-- $1 = username, $2 = new password hash, $3 = current password verification value
-- In a real application, verify credentials and hash passwords in application code.
UPDATE users
SET password = $2
WHERE username = $1
  AND password = $3;

-- 4. Display channels and whether the specified user is a member
-- $1 = username
WITH logged_in_user AS (
    SELECT user_id
    FROM users
    WHERE username = $1
)
SELECT
    c.channel_id,
    c.name,
    c.description,
    CASE WHEN cm.user_id IS NULL THEN FALSE ELSE TRUE END AS is_member,
    COUNT(all_members.user_id) AS member_count
FROM channels AS c
CROSS JOIN logged_in_user AS u
LEFT JOIN channel_members AS cm
    ON cm.channel_id = c.channel_id
   AND cm.user_id = u.user_id
LEFT JOIN channel_members AS all_members
    ON all_members.channel_id = c.channel_id
GROUP BY c.channel_id, c.name, c.description, cm.user_id
ORDER BY c.name;

-- 5. Check whether a user belongs to a channel
-- $1 = username, $2 = channel_id
SELECT cm.user_id, cm.channel_id
FROM channel_members AS cm
JOIN users AS u ON u.user_id = cm.user_id
WHERE u.username = $1
  AND cm.channel_id = $2;

-- 6. Join a channel
-- $1 = username, $2 = channel_id
INSERT INTO channel_members (user_id, channel_id)
SELECT user_id, $2
FROM users
WHERE username = $1
ON CONFLICT (user_id, channel_id) DO NOTHING;

-- 7. Leave a channel
-- $1 = username, $2 = channel_id
DELETE FROM channel_members AS cm
USING users AS u
WHERE cm.user_id = u.user_id
  AND u.username = $1
  AND cm.channel_id = $2;

-- 8. Create a channel
-- $1 = channel name, $2 = description
INSERT INTO channels (name, description)
VALUES ($1, $2)
RETURNING channel_id;

-- 9. List members of a channel
-- $1 = channel_id
SELECT u.user_id, u.username, cm.joined_at
FROM channel_members AS cm
JOIN users AS u ON u.user_id = cm.user_id
WHERE cm.channel_id = $1
ORDER BY u.username;

-- 10. Display the most recent 50 messages in a channel, oldest first
-- $1 = channel_id
SELECT message_id, username, body, created_at
FROM chat_inbox
WHERE channel_id = $1
ORDER BY created_at DESC
LIMIT 50;

-- 11. Send a message
-- $1 = username, $2 = channel_id, $3 = message body
INSERT INTO chat_inbox (username, channel_id, body)
VALUES ($1, $2, $3)
RETURNING message_id, created_at;
