# Melo — Production Security Architecture & Threat Model

## 1. Security Overview
Melo implements defense-in-depth across the Flutter mobile client and the Express/Node.js backend. The system ensures robust protection of user credentials, zero leakage of API secrets, defense against network-level interception, and protection against on-device tampering.

---

## 2. Secrets Management & Repository Hygiene
- **Strict `.gitignore` Boundaries**: All environment files (`.env*`), private keystores (`*.jks`, `*.keystore`), Android signing configurations (`key.properties`, `local.properties`), cryptographic certificates (`*.pem`, `*.key`), local SQLite caches (`*.db`, `*.sqlite`), and compiled binary outputs (`*.apk`, `*.aab`) are strictly ignored.
- **Git Tree Audit**: `git ls-files` verification confirms zero secret credentials or certificates reside in source control history.
- **Zod Runtime Environment Validation**:
  - Requires 32+ character non-default `JWT_SECRET` in production.
  - Forbids wildcard `CORS_ORIGIN=*` in production environments.
  - Fails fast on startup if mandatory secrets are missing or insecure.

---

## 3. Backend Hardening

### Defensive HTTP Headers (`security-headers.middleware.ts`)
| Header | Value | Purpose |
| :--- | :--- | :--- |
| `X-Content-Type-Options` | `nosniff` | Prevents MIME-type sniffing attacks |
| `X-Frame-Options` | `DENY` | Mitigates clickjacking attacks |
| `X-XSS-Protection` | `0` | Disables outdated, buggy legacy browser XSS filters |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Protects URI path privacy during cross-domain navigation |
| `Content-Security-Policy` | `default-src 'self' ...` | Binds script, connect, and media execution origins |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Enforces HTTPS in production |
| `X-Powered-By` | *(Removed)* | Hides backend framework fingerprint |

### Request Throttling & Sliding-Window Rate Limiting
- **General Limiter**: 120 requests / minute per client IP.
- **Auth Limiter**: 20 requests / minute on `/api/auth/*` (login, register, forgot-password) to thwart credential stuffing and brute-force attacks.
- **Download Info Limiter**: 30 requests / minute on `/api/tracks/:provider/:trackId/download-info` to prevent scraper abuse.
- **Exceeded Threshold Response**: Emits HTTP `429 Too Many Requests` with a compliant `Retry-After: <seconds>` header.

### Bounded Payload & Safe Error Handling
- **Request Body Size Limit**: Strictly capped at `1mb` (`express.json({ limit: '1mb' })`). Requests exceeding this limit receive HTTP `413 Payload Too Large`.
- **Sanitized Error Masking**: In production (`NODE_ENV=production`), unhandled 500 exceptions emit generic messages (`"An internal server error occurred"`). All stack traces are stripped. Regex filters scrub Bearer tokens, passwords, database URIs, and API keys.

---

## 4. Mobile Client Hardening

### Network Resiliency & Retry Architecture
- **Transient Failure Retries**: The `ApiClient` employs exponential backoff retry for network drops, timeouts (HTTP 408), and gateway instability (HTTP 502, 503, 504).
- **Client Error Integrity**: Client-side errors (`4xx`) are never retried, preventing infinite loops or rate limit exhaustion.
- **Configurable Environments**: Supports `development`, `staging`, and `production` via compile-time `--dart-define=MELO_ENV` and `--dart-define=MELO_API_URL`.

### Safe On-Device Logging (`AppLogger`)
- All log statements are routed through `AppLogger` with categorical tags (`AUTH`, `API`, `PLAYER`, `DOWNLOAD`, `SYNC`, `RECOMMENDATION`, `DATABASE`).
- In release mode (`kReleaseMode`), verbose debug logs are suppressed.
- Automatic regex sanitization continuously scrubs:
  - `Bearer <token>` ➔ `Bearer REDACTED`
  - `password=...` ➔ `password=REDACTED`
  - `api_key=...` ➔ `api_key=REDACTED`
  - User emails ➔ `u***@domain.com`

### Download & File Storage Security
- **Path Traversal Protection**: Song IDs and filenames are sanitized before disk persistence, blocking directory traversal (`../`) attacks.
- **Checksum Verification**: Track downloads verify byte-size and stream validity before marking tracks as ready; corrupt or interrupted downloads are automatically purged.
