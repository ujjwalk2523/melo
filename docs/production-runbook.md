# Melo — Production Operations & Deployment Runbook

## 1. Release Checklist & Prerequisites

### Flutter Mobile App
- [x] Dart formatting clean: `dart format --output=none --set-exit-if-changed lib test`
- [x] Dart analysis clean: `flutter analyze` (0 issues)
- [x] Full unit and widget test suite passing: `flutter test` (134/134 tests passing)
- [x] Proguard / R8 rules configured (`android/app/proguard-rules.pro`)
- [x] Uncaught error handlers registered (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, `ErrorWidget.builder`)
- [x] Release APK compiles cleanly: `flutter build apk --release`

### Express Backend Service
- [x] TypeScript compilation clean: `npm run build` (`tsc` 0 errors)
- [x] Vitest test suite passing: `npm test` (57/57 tests passing)
- [x] Security headers active (`nosniff`, `DENY`, CSP, HSTS in production)
- [x] Rate limiters active on general API (120/min), auth (20/min), and download info (30/min)
- [x] Environment validation active via Zod schema

---

## 2. Production Environment Configuration

### Backend Environment Variables (`.env.production`)
```bash
NODE_ENV=production
PORT=4000
# Must be a cryptographically random 32+ character string
JWT_SECRET=super_secret_production_key_must_be_over_32_characters_long
# Exact comma-delimited allowed origins (no wildcard * allowed in production)
CORS_ORIGIN=https://melo.stream,https://app.melo.stream

# Database Connection (Supabase / PostgreSQL)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key
DATABASE_URL=postgresql://postgres:password@db.your-project.supabase.co:5432/postgres

# Music Provider Credentials
JAMENDO_CLIENT_ID=your_jamendo_client_id
AUDIUS_APP_NAME=melo_production_app
```

### Flutter Client Build Flags
```bash
flutter build apk --release \
  --dart-define=MELO_ENV=production \
  --dart-define=MELO_API_URL=https://api.melo.stream/api \
  --no-tree-shake-icons
```

---

## 3. Deployment Procedures

### Backend Deployment (Docker / Node Process Manager)
1. **Build Container / Bundle**:
   ```bash
   cd backend
   npm ci --production=false
   npm run build
   npm prune --production
   ```
2. **Execute Database Migrations**:
   ```bash
   # Run schema migration against production PostgreSQL
   psql $DATABASE_URL -f src/db/schema.sql
   ```
3. **Start Process (e.g., with PM2)**:
   ```bash
   pm2 start dist/server.js --name melo-backend -i max
   ```
4. **Verify Health**:
   ```bash
   curl -I https://api.melo.stream/api/health
   # Expected: HTTP 200 OK with security headers present
   ```

---

## 4. Incident Response & Troubleshooting

### Incident 1: Backend Rate Limiting False Positives
- **Symptoms**: Legitimate client requests receive HTTP 429 Too Many Requests.
- **Remediation**:
  1. Inspect `X-Forwarded-For` and ensure reverse proxy (Nginx / Cloudflare) correctly passes real client IPs.
  2. If traffic legitimately surges, adjust `maxRequests` in `rate-limiter.middleware.ts`.

### Incident 2: Playback Stalls or Network Dropouts
- **Symptoms**: Song playback fails to buffer or stream halts midway.
- **Remediation**:
  1. `ApiClient` automatically retries transient 502/503/504 errors up to 2 times with exponential backoff.
  2. If upstream provider node is unresponsive, `MusicService` automatically falls back across discovery providers.
  3. Offline-downloaded tracks remain 100% playable regardless of network status.

### Incident 3: Drift Database Schema Migration
- Current schema version is `2`.
- Any table modifications must increment `schemaVersion` and supply an explicit `MigrationStrategy` in `lib/core/database/app_database.dart` with `onUpgrade` steps. Never modify existing migration contracts destructively.
