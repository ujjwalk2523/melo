# Melo Backend Service

A high-performance, provider-agnostic Node.js/TypeScript backend for the Melo music streaming platform.

---

## Architecture Overview

```text
backend/
├── src/
│   ├── config/
│   │   └── env.ts                  # Typed Zod environment configuration
│   ├── controllers/
│   │   ├── health.controller.ts     # /api/health
│   │   ├── search.controller.ts     # /api/search
│   │   └── track.controller.ts      # /api/tracks/:provider/:trackId
│   ├── middleware/
│   │   ├── error.middleware.ts      # Centralized safe error sanitizer
│   │   └── not-found.middleware.ts  # 404 Route handler
│   ├── providers/
│   │   ├── interfaces/
│   │   │   └── music-provider.ts    # Common provider interface
│   │   ├── audius/
│   │   │   └── audius.provider.ts   # Official Audius v1 REST adapter
│   │   └── jamendo/
│   │       └── jamendo.provider.ts  # Jamendo v3.0 REST adapter
│   ├── routes/
│   │   ├── health.routes.ts
│   │   ├── search.routes.ts
│   │   └── track.routes.ts
│   ├── services/
│   │   ├── music.service.ts         # High-level music search & track service
│   │   └── provider-registry.ts     # Pluggable provider registry
│   ├── types/
│   │   └── music.ts                 # Provider-neutral domain models (Song, etc.)
│   ├── utils/
│   │   └── app-error.ts             # Operational AppError hierarchy
│   └── server.ts                    # Express setup and lifecycle
├── tests/
│   ├── health.test.ts
│   ├── search-validation.test.ts
│   ├── provider-normalization.test.ts
│   └── music-service.test.ts
├── .env.example
├── package.json
└── tsconfig.json
```

---

## Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
```

| Variable | Required | Default | Description |
| :--- | :---: | :---: | :--- |
| `PORT` | No | `4000` | Local HTTP port |
| `NODE_ENV` | No | `development` | Environment (`development`, `production`, `test`) |
| `CORS_ORIGIN` | No | `http://localhost:3000` | Allowed CORS origins (comma-separated or `*`) |
| `AUDIUS_API_URL` | No | `https://discoveryprovider.audius.co` | Official Audius Discovery node URL |
| `AUDIUS_APP_NAME`| No | `melo_app` | Audius registered application tag |
| `JAMENDO_API_URL`| No | `https://api.jamendo.com/v3.0` | Jamendo REST API endpoint |
| `JAMENDO_CLIENT_ID` | Optional | `""` | Jamendo developer Client ID (obtain from https://devportal.jamendo.com/) |

### 3. Run Development Server
```bash
npm run dev
```

### 4. Build & Run Production Bundle
```bash
npm run build
npm start
```

### 5. Run Test Suite
```bash
npm test
```

---

## API Endpoints

### 1. Health Check
* **Endpoint**: `GET /api/health`
* **Response**:
```json
{
  "success": true,
  "service": "melo-api",
  "status": "healthy",
  "timestamp": "2026-09-20T14:15:00.000Z"
}
```

### 2. Music Search
* **Endpoint**: `GET /api/search?q={query}&provider={audius|jamendo}&limit={number}`
* **Query Parameters**:
  * `q` (required): Search keyword (trimmed, 1–100 characters).
  * `provider` (optional): Specific music provider. Defaults to `audius`.
  * `limit` (optional): Maximum items to return (default: 15).
* **Response**:
```json
{
  "success": true,
  "query": "lofi",
  "provider": "audius",
  "totalResults": 10,
  "results": [
    {
      "id": "audius:95wro",
      "provider": "audius",
      "providerTrackId": "95wro",
      "title": "Stars In The Sky - Lofi Beats",
      "artist": "Lofi Beats",
      "artworkUrl": "https://audius-creator-11.theblueprint.xyz/content/.../480x480.jpg",
      "durationSeconds": 71,
      "streamUrl": "https://discoveryprovider.audius.co/v1/tracks/95wro/stream?app_name=melo_app",
      "downloadUrl": null,
      "isDownloadable": false,
      "explicit": false
    }
  ]
}
```

### 3. Track Metadata
* **Endpoint**: `GET /api/tracks/:provider/:trackId`
* **Example**: `GET /api/tracks/audius/95wro`

### 4. Track Stream URL
* **Endpoint**: `GET /api/tracks/:provider/:trackId/stream`
* **Example**: `GET /api/tracks/audius/95wro/stream`

---

## Provider Architecture & Authorization

1. **Audius**:
   * Uses legitimate, official public Audius Discovery Node v1 endpoints.
   * Does NOT require API keys for discovery searches.
   * `isDownloadable` is set to `true` strictly when `is_downloadable === true` and `download` object is present.

2. **Jamendo**:
   * Uses official Jamendo v3.0 REST endpoints.
   * Requires a registered `JAMENDO_CLIENT_ID`. If unconfigured, the adapter safely raises a `503 JAMENDO_NOT_CONFIGURED` error without crashing the server.
   * Respects Jamendo's `audiodownload_allowed` flag.

3. **No Audio Scraping Policy**:
   * Melo strictly enforces that YouTube, Spotify, Amazon Music, and unauthorized reverse-engineered streams are NEVER scraped, extracted, or bypassed.

---

## Android Emulator Networking

When accessing this backend from the Android Emulator:
* The host machine's `localhost` is mapped to `10.0.2.2` in the Android emulator environment.
* Flutter client default URL: `http://10.0.2.2:4000/api`.
* For desktop/web testing, pass `--dart-define=MELO_API_URL=http://localhost:4000/api`.
