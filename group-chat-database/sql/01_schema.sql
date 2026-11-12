-- Group Chat Database System
-- Core relational schema based on the INFO 330 project milestones.
-- Run this file first in a PostgreSQL database.

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    CHECK (username <> '')
);

CREATE TABLE channels (
    channel_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    CHECK (TRIM(name) <> '')
);

CREATE TABLE channel_members (
    membership_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    channel_id INT NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, channel_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE
);

-- Normalization notes from the project:
-- The tables separate users, channels, memberships, and messages into
-- distinct entities. Primary keys identify rows; foreign keys represent
-- relationships; UNIQUE constraints prevent duplicate usernames and
-- duplicate memberships.
--
-- Security note:
-- The password column reflects the course schema. Do not store plaintext
-- passwords in a real application. Hash passwords in the application layer.
