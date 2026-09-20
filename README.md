# Melo — Mobile Music Streaming Application

Melo is a production-quality, dark-first mobile music streaming application designed with an original brand identity, Material 3 design system, and clean, scalable Flutter architecture.

---

## Architecture Overview

```text
lib/
├── core/              # Global application infrastructure
│   ├── constants/     # App strings, labels, assets
│   ├── router/        # GoRouter navigation & route definitions
│   ├── theme/         # Material 3 dark-first tokens (colors, typography, dimensions)
│   ├── utils/         # Helpers (DurationFormatter, etc.)
│   └── errors/        # Typed failure models
│
├── features/          # Feature-first domain modules
│   ├── home/          # Feeds, recommendations, trending songs
│   ├── search/        # Debounced search, genre discovery, category chips
│   ├── library/       # Playlists, liked tracks, offline downloads
│   ├── profile/       # Account status, audio preferences, settings
│   └── player/        # Centralized audio player state & persistent mini player
│
├── shared/            # Common domain assets
│   ├── models/        # Normalized models (Song, etc.)
│   ├── data/          # Seeded mock catalog
│   └── widgets/       # Reusable components (SongCard, EmptyState, SectionHeader)
│
└── main.dart          # Application entrypoint with ProviderScope & MaterialApp.router
```

---

## Design System: Melo Dark Aura

* **Surfaces**: Deep obsidian (`#090A0C`), elevated card layers (`#12151A`, `#1A1E26`).
* **Accents**: Vibrant electric mint / cyan (`#00E5BF`) and electric indigo (`#818CF8`).
* **Typography**: Material 3 standard typography scale.
* **Navigation**: Persistent 4-tab bottom navigation shell with floating Mini Player.

---

## Verification

Run tests and analysis from the project root:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

---

## Phase 3: Backend & Music Provider Architecture

Melo includes a lightweight, modular Node.js/TypeScript backend service under `backend/`.

```text
backend/
├── src/
│   ├── config/env.ts              # Zod environment configuration
│   ├── controllers/               # Health, Search, and Track controllers
│   ├── middleware/                # Error handling and 404 middleware
│   ├── providers/                 # MusicProvider interface (Audius, Jamendo)
│   ├── routes/                    # API routes (/api/health, /api/search, /api/tracks)
│   ├── services/                  # MusicService and ProviderRegistry
│   └── types/music.ts             # Normalized provider-agnostic domain models
└── tests/                         # Vitest unit & normalization tests
```

### Running the Backend

```bash
cd backend
npm install
npm test
npm run build
npm start
```
