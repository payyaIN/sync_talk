
# Architecture
- **Backend**: Express + modular domains (auth, users, conversations, messages, ai, calls, audit)
- **Sockets**: Presence + Chat + Calls namespaces
- **Mobile**: Flutter (MVVM + Riverpod) with feature‑first folders
- **Admin**: Flutter Web with data_table_2 and GoRouter

```
clients ──► REST (Express) ──► Mongo
        └─► Socket.IO (presence/chat/calls)
```
