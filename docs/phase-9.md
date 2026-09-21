# Phase 9 — Personalized Music Recommendation & Intelligence Engine

## 1. Overview & Architecture

Phase 9 implements an explainable, deterministic, zero-external-cost, offline-capable personalized recommendation and music intelligence engine for Melo. The architecture operates entirely on-device and local-first, respecting user privacy and requiring **zero paid AI APIs, zero LLM keys, and zero external vector SaaS dependencies**.

### Architecture Highlights
- **100% Deterministic & Explainable**: Every recommended song is grounded directly in the listener's actual interaction history, favorite artists, playlist patterns, and explicit feedback. Every recommendation provides an honest, human-readable reason (e.g. *"Because you listened to [Artist]"*, *"Based on your love for [Genre]"*, *"Trending in Melo right now"*).
- **Zero External AI / LLM Cost**: Built using mathematical multi-attribute cosine/jaccard proximity, feature extraction, affinity scoring, and diversity filtering. No OpenAI, Gemini, Claude, or paid embedding APIs are invoked.
- **Offline Recommendation Support**: When the app operates in offline mode or the device has no network connectivity, the candidate generator automatically partitions and ranks exclusively from locally downloaded tracks stored on disk.
- **Drift SQLite Negative Feedback Loop**: User negative feedback (`hideSong`, `hideArtist`, `hideGenre`, `lessLikeThis`, `notInterested`) persists locally in Drift SQLite (`recommendation_feedback_table`) across app restarts and cloud syncs, immediately excluding or dampening unwanted tracks.
- **Multi-Factor Scoring Pipeline**:
  - `FeatureExtractor`: Extracts user taste profiles from favorites, play history, playlist inclusions, completion rates, and downloads.
  - `CandidateGenerator`: Collects candidate tracks from 10 distinct sources (favorite artists, top genres, recent history, frequently played, similar to favorites, trending, discover new, offline downloads, playlist neighbors, catalog fallback).
  - `CandidateScorer`: Computes normalized scores `[0.0, 1.0]` combining user affinity (35%), genre affinity (25%), similarity (20%), recency (10%), and popularity (10%), with repeat penalties and hard feedback filters.
  - `DiversityFilter`: Enforces artist caps (max 3 tracks per artist), album caps (max 2 tracks per album), and consecutive track smoothing.
  - `RecommendationExplainer`: Formulates transparent, data-grounded reasoning.
  - `RecommendationEngine`: Central orchestrator providing in-memory caching with 5-minute TTL, invalidation triggers, and section partitioning.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Melo Flutter Client                              │
│                                                                             │
│  ┌────────────────────┐     ┌───────────────────────┐   ┌─────────────────┐ │
│  │    HomeScreen      │     │   FullPlayerScreen    │   │  ProfileScreen  │ │
│  │ ("Made For You",   │     │  ("More Like This"    │   │ (Settings, Mode,│ │
│  │  "Because You Liked",    │   Modal Bottom Sheet) │   │  Reset Profile) │ │
│  │  "Discover Artists")     └───────────┬───────────┘   └────────┬────────┘ │
│  └─────────┬──────────┘                 │                        │          │
│            │                            │                        │          │
│  ┌─────────▼────────────────────────────▼────────────────────────▼────────┐ │
│  │                     RecommendationEngine (Facade)                      │ │
│  │  - In-memory cache (5m TTL)           - Manual/Pull-to-refresh invalid.│ │
│  │  - Section partitioning ("Made For You", "Because Liked", "Discover") │ │
│  │  - Provider-neutral track similarity search ("More Like This")         │ │
│  └──────┬──────────────────────┬──────────────────────┬───────────────────┘ │
│         │                      │                      │                     │
│  ┌──────▼──────────────┐┌──────▼──────────────┐┌──────▼───────────────────┐ │
│  │  FeatureExtractor   ││ CandidateGenerator  ││     CandidateScorer      │ │
│  │  - Taste Profile    ││ - 10 source pools   ││ - 5-factor scoring (0..1)│ │
│  │  - Interaction wts  ││ - Cold-start logic  ││ - Repeat play penalties  │ │
│  │  - Affinity vectors ││ - Offline downloads ││ - Negative feedback drop │ │
│  └─────────────────────┘└─────────────────────┘└──────┬───────────────────┘ │
│                                                       │                     │
│  ┌────────────────────────────────────────────────────▼───────────────────┐ │
│  │                   DiversityFilter & Explainer                          │ │
│  │  - Max 3 tracks/artist    - Max 2 tracks/album   - Consecutive smooth  │ │
│  │  - Deterministic natural language explanations ("Because you liked...")│ │
│  └──────┬─────────────────────────────────────────────────────────────────┘ │
│         │                                                                   │
│  ┌──────▼─────────────────────────────────────────────────────────────────┐ │
│  │       LocalRecommendationDataSource (Drift SQLite + SharedPreferences)  │ │
│  │  - Favorites Table        - Listening History Table   - Downloads Table│ │
│  │  - Playlists Table        - Feedback Table            - User Preferences││
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ Optional Discovery Metadata
                                      ▼
             ┌──────────────────────────────────────────────────┐
             │       Node.js Backend Recommendation Endpoints   │
             │ - GET /api/recommendations/trending              │
             │ - GET /api/recommendations/discover              │
             └──────────────────────────────────────────────────┘
```

---

## 2. Interaction Signals & Taste Profile Extraction

The `FeatureExtractor` processes local interaction datasets to build a normalized `TasteProfile`.

### Interaction Weights
- **Favorites**: `+5.0` (Strongest explicit positive signal)
- **Playlists**: `+2.5` (Explicit curation signal)
- **Completed Plays** (>85% completion): `+3.0`
- **Partial Plays** (25%–85% completion): `+1.0`
- **Repeat Plays**: `+2.0` bonus per repeated listen
- **Downloaded Tracks**: `+3.0` (Explicit high intent)
- **Early Skips** (<25% completion): `-2.0` penalty (dampens artist/genre affinity)
- **Negative Feedback**:
  - `hideSong`: Filtered completely
  - `hideArtist`: Filtered completely
  - `hideGenre`: Filtered completely
  - `lessLikeThis`: 0.4x penalty multiplier

### Cold-Start Behavior
For new users with zero interaction history, `TasteProfile.isColdStart` defaults to `true`. In this state, `CandidateGenerator` draws from trending and discovery tracks with diverse genres and emerging artists. As soon as the user bookmarks a favorite or listens to tracks, `FeatureExtractor` transitions the profile seamlessly to personalized affinity ranking.

---

## 3. Multi-Factor Candidate Scoring & Diversity

Each candidate track is evaluated and assigned a score normalized strictly between `0.0` and `1.0`:

$$\text{Score} = w_{\text{artist}} \cdot A_{\text{artist}} + w_{\text{genre}} \cdot A_{\text{genre}} + w_{\text{sim}} \cdot S_{\text{sim}} + w_{\text{rec}} \cdot R_{\text{rec}} + w_{\text{pop}} \cdot P_{\text{pop}}$$

Where:
- $w_{\text{artist}} = 0.35$ (Artist affinity weight)
- $w_{\text{genre}} = 0.25$ (Genre affinity weight)
- $w_{\text{sim}} = 0.20$ (Similarity to user favorites)
- $w_{\text{rec}} = 0.10$ (Recency weight)
- $w_{\text{pop}} = 0.10$ (Platform popularity / freshness)

### Discovery Levels
Users can adjust their discovery appetite in Profile settings:
1. **Familiar** (85% familiar / 15% discovery): Favors top artists and favorite genres.
2. **Balanced** (70% familiar / 30% discovery): Melo default setting.
3. **Explore** (50% familiar / 50% discovery): Boosts discovery weight and introduces unfamiliar genres/artists.

### Diversity Rules
To prevent algorithmic echo chambers and artist monopolization:
- **Artist Cap**: Maximum 3 tracks per artist in any section.
- **Album Cap**: Maximum 2 tracks per album in any section.
- **Consecutive Artist Smoothing**: No two adjacent tracks from the same artist unless candidate pool size necessitates deferred recovery.

---

## 4. UI Touchpoints

1. **HomeScreen**:
   - **Made For You**: Algorithmically tailored tracks dynamically adapting to taste profile.
   - **Because You Liked**: Directly grounded in the user's top bookmarked song.
   - **Discover New Artists**: Emerging artists from adjacent genres.
   - **Pull-to-Refresh**: Invalidates recommendation cache and executes a fresh generation pipeline.
2. **FullPlayerScreen**:
   - **More Like This**: Action button (`Icons.auto_awesome_rounded`) in player options.
   - Opens a modal bottom sheet displaying provider-neutral similar songs ranked by `SongSimilarityCalculator` with instant queue/play support.
3. **ProfileScreen**:
   - **Personalized Recommendations**: Master toggle enabling/disabling recommendation personalization.
   - **Use Listening History**: Toggle to factor or ignore listening history in taste extraction.
   - **Discovery Level**: Interactive dialog switching between Familiar, Balanced, and Explore modes.
   - **Reset Recommendation Profile**: Dialog allowing users to wipe taste signals, feedback, and cached recommendations without affecting favorites, playlists, or downloads.

---

## 5. Verification & Test Matrix

### Flutter Test Suite
- Total tests: **127 passing (100%)**
  - Phase 1–2 UI & Navigation: 7 tests
  - Phase 3 Backend Search: 5 tests
  - Phase 4 Audio Player: 15 tests
  - Phase 5 Background Playback: 12 tests
  - Phase 6 Local Persistence: 17 tests
  - Phase 7 Auth & Cloud Sync: 18 tests
  - Phase 8 Authorized Downloads: 24 tests
  - Phase 9 Recommendations & Intelligence: 29 tests
- `flutter analyze`: **0 issues found**
- Debug APK: `flutter build apk --debug` succeeded (`build\app\outputs\flutter-apk\app-debug.apk`).

### Backend Test Suite (Vitest)
- Total tests: **50 passing (100%)** across 8 test suites:
  - `recommendations.test.ts` (6 tests)
  - `download.test.ts` (8 tests)
  - `auth.test.ts` (14 tests)
  - `sync.test.ts` (7 tests)
  - `search-validation.test.ts` (4 tests)
  - `provider-normalization.test.ts` (5 tests)
  - `music-service.test.ts` (4 tests)
  - `health.test.ts` (2 tests)
- TypeScript build (`npm run build`): Clean with 0 errors.
