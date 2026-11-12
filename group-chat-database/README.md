# Group Chat Database System

**Course project:** INFO 330 — University of Washington  
**Technologies:** PostgreSQL, SQL, relational database design

## Overview

This project designs and implements the database layer for a multi-user group chat application. The database supports user accounts, channels, channel memberships, and messages. SQL queries support core application operations, while a separate set of analytical queries explores channel activity, user engagement, and messaging patterns.

The project was completed across five milestones: requirements and ERD design, relational schema implementation, messaging and indexes, application queries, and data analysis.

## Features represented in the database

- User registration and account records
- Channel creation and channel descriptions
- Joining and leaving channels
- Membership checks and channel member listings
- Storing and retrieving channel messages
- Querying channel and user activity for analysis

## Repository structure

```text
group-chat-database/
├── README.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_messaging_and_indexes.sql
│   ├── 03_application_queries.sql
│   └── 04_analytics_queries.sql
└── docs/
    ├── data_dictionary.md
    └── erd-placeholder.md
```

## Database design

The relational model uses four main tables:

- `users` — user accounts
- `channels` — chat channels
- `channel_members` — many-to-many relationship between users and channels
- `chat_inbox` — messages posted by users in channels

The schema uses primary keys, foreign keys, uniqueness constraints, check constraints, and cascading deletes. The membership table prevents a user from joining the same channel more than once.

## SQL work

The SQL files are organized by project milestone:

1. `01_schema.sql` creates the core relational tables.
2. `02_messaging_and_indexes.sql` creates the message table and indexes used for message retrieval.
3. `03_application_queries.sql` contains example parameterized queries for application features.
4. `04_analytics_queries.sql` contains analytical queries for channel activity, user engagement, and messaging patterns.

The application queries use PostgreSQL positional parameters such as `$1` and `$2`. They are intended to be called by an application layer that supplies those values.

## Important implementation notes

- The original project schema stores a `password` field. This repository does **not** claim that password hashing or production-ready authentication was implemented in SQL. A real application should hash passwords with a suitable password-hashing algorithm in its application layer and should never store plaintext passwords.
- The sample queries assume the schema in `01_schema.sql` and `02_messaging_and_indexes.sql`.
- The analytics are based on the project's sample data. They demonstrate query techniques and should not be interpreted as findings about real users.
- The average interval query measures time between consecutive messages in a channel. It is not necessarily a measure of reply response time.
- If you publish this repository, use only synthetic/sample data and remove credentials or private information.

## Running the SQL

1. Create a PostgreSQL database.
2. Run `sql/01_schema.sql`.
3. Run `sql/02_messaging_and_indexes.sql`.
4. Run the queries in `sql/03_application_queries.sql` and `sql/04_analytics_queries.sql` individually, supplying parameter values where required.

The application and analytics query files are reference collections; they are not intended to be executed as one uninterrupted script because some statements require parameters.

## Project skills

- Relational database design and ERD modeling
- Database normalization
- PostgreSQL table creation and constraints
- Primary and foreign key relationships
- SQL joins, CTEs, aggregation, and subqueries
- Index creation and query-plan inspection with `EXPLAIN`
- Window functions including `LAG()` and `ROW_NUMBER()`
- Data analysis using SQL

## Author

Add your name and any teammates according to your course's collaboration and sharing guidelines.
