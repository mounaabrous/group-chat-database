-- Group Chat Database System
-- Message storage and indexes from the messaging milestone.
-- Run after 01_schema.sql.

CREATE TABLE chat_inbox (
    message_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    channel_id INT NOT NULL,
    body VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (body <> ' '),
    CHECK (LENGTH(body) <= 500),
    FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE
);

-- Supports retrieving a channel's messages in reverse chronological order.
CREATE INDEX idx_chat_inbox_channel_created
    ON chat_inbox (channel_id, created_at DESC);

-- Supports filtering messages by username.
CREATE INDEX idx_chat_inbox_username
    ON chat_inbox (username);

-- Example query-plan inspection from the project:
EXPLAIN
SELECT message_id, username, channel_id, body, created_at
FROM chat_inbox
WHERE channel_id = 1
ORDER BY created_at DESC
LIMIT 50;
