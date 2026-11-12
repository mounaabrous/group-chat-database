# Entity Relationship Diagram

Add an exported image of your original ERD here, preferably named `database_erd.png`.

The diagram should show these relationships:

- `users` to `channel_members`: one user can have many membership rows.
- `channels` to `channel_members`: one channel can have many membership rows.
- `users` to `chat_inbox`: one username can be associated with many messages.
- `channels` to `chat_inbox`: one channel can contain many messages.

The `channel_members` table represents the many-to-many relationship between users and channels.
