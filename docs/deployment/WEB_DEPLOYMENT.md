# Admin Web Panel Deployment Guide

This guide covers building and hosting the Flutter Web Admin Panel on cloud platforms such as Vercel, Netlify, Cloudflare Pages, or Firebase Hosting.

---

## 1. Building Web Assets

```bash
cd admin-panel
flutter build web --release --web-renderer canvaskit
```

Generated build assets will be located in:
`admin-panel/build/web/`

---

## 2. Deploying to Vercel / Netlify / Firebase

### Deploying to Vercel
1. Set output directory to `admin-panel/build/web`.
2. Configure rewrite rules for Single Page Application (SPA) routing in `vercel.json`:
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### Deploying to Firebase Hosting
```bash
firebase init hosting
# Specify public directory: admin-panel/build/web
# Configure as single-page app: Yes
firebase deploy --only hosting
```
