# Data Dictionary

This dictionary summarizes the tables represented in the project schema.

## `users`

| Column | Type | Description |
|---|---|---|
| `user_id` | SERIAL, primary key | Unique identifier for each user |
| `username` | VARCHAR(50), unique, not null | User's unique username |
| `password` | VARCHAR(128), not null | Stored password value; production systems should store a secure password hash |
| `created_at` | TIMESTAMP | Account creation time; defaults to `NOW()` |

## `channels`

| Column | Type | Description |
|---|---|---|
| `channel_id` | SERIAL, primary key | Unique identifier for each channel |
| `name` | VARCHAR(100), unique, not null | Unique channel name |
| `description` | TEXT | Optional channel description |
| `created_at` | TIMESTAMP | Channel creation time; defaults to `NOW()` |

## `channel_members`

| Column | Type | Description |
|---|---|---|
| `membership_id` | SERIAL, primary key | Unique identifier for a membership row |
| `user_id` | INT, foreign key | References `users.user_id` |
| `channel_id` | INT, foreign key | References `channels.channel_id` |
| `joined_at` | TIMESTAMPTZ | Time the user joined; defaults to `NOW()` |

A unique constraint on (`user_id`, `channel_id`) prevents duplicate memberships.

## `chat_inbox`

| Column | Type | Description |
|---|---|---|
| `message_id` | SERIAL, primary key | Unique identifier for each message |
| `username` | VARCHAR(50), foreign key | References the unique `users.username` value |
| `channel_id` | INT, foreign key | References `channels.channel_id` |
| `body` | VARCHAR(500), not null | Message text |
| `created_at` | TIMESTAMPTZ | Message creation time; defaults to `NOW()` |

The message table references `username` rather than `user_id`, matching the milestone implementation. This is valid because `users.username` is unique, though referencing a stable user ID is often preferable in a production design.
