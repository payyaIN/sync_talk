
<div align="center">

# SyncTalk – Admin (Flutter Web)

[![CI](https://img.shields.io/github/actions/workflow/status/Akshaypayya/synctalk-admin/ci.yml?label=CI)](#)
![Platform](https://img.shields.io/badge/platform-web%20%7C%20mobile%20%7C%20api-blue)
![Status](https://img.shields.io/badge/status-portfolio--ready-brightgreen)

</div>

---


# SyncTalk Admin (Flutter Web)
- Login with admin user
- View users & conversations
- Ban/unban, toggle role

## Run (Web)
```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE=http://localhost:4000
```


### Pages added
- Messages Moderation (`/moderation`) – load by conversation ID, delete messages
- Audit Logs (`/audit`) – latest 200 actions

- Added Moderation + Audit pages
\n\n---\n\n# synctalk-admin\n\n**GitHub-ready build.** See `/docs/README.md` for full system design, architecture, and API guide.\n

## Screenshots
See `/docs/diagrams` for architecture. Add app screenshots under `/docs/screenshots`.
