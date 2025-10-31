#!/usr/bin/env bash
set -e
git init
git add .
git commit -m "feat: SyncTalk Admin (Flutter Web)"
git branch -M main
git remote add origin https://github.com/Akshaypayya/synctalk-admin.git
git push -u origin main
