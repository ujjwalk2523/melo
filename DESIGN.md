# Melo Design System: "Melo Dark Aura"

## 1. Visual Atmosphere & Philosophy
- **Identity:** "Melo Dark Aura" — an evocative nocturnal sonic sanctuary. Deep obsidian and charcoal indigo layered surfaces lit by electric violet and cyan luminescence.
- **Anti-Generic Mandate:** Not a Spotify clone (no neon-green branding or plain lists), not an Apple Music clone (no sterile white sheets), not a YouTube Music clone. Melo features dark ambient gradient glows, glassmorphic perimeter borders, procedural generative artwork, and tactile micro-interactions.
- **Density:** Balanced Mobile Music Streaming (Score: 6/10). Generous touch targets (min 48px), scannable vertical typography, and fluid horizontal carousels.

---

## 2. Color Calibration

| Token Name | Hex Value | Role |
| :--- | :--- | :--- |
| `background` | `#090A0F` | Deepest obsidian canvas / root scaffold |
| `surface` | `#12141F` | Base elevation (app bars, navigation background) |
| `surfaceElevated` | `#1A1D2E` | Cards, bottom sheets, modal dialogues |
| `surfaceHighlight` | `#24283B` | Active tiles, pressed states, hover feedback |
| `surfaceBorder` | `#2E334D` / `rgba(255, 255, 255, 0.08)` | Subtle luminous dividing outlines |
| `primary` | `#7C3AED` | Electric Violet — primary CTAs, active badges, player scrub |
| `primaryGlow` | `rgba(124, 58, 237, 0.25)` | Ambient lighting shadow on active artwork |
| `secondary` | `#06B6D4` | Cyan Glow — stream progress, secondary highlights |
| `tertiary / success` | `#10B981` | Emerald Glow — liked tracks, download complete, online status |
| `warning` | `#F59E0B` | Amber Flame — alerts, network warnings |
| `error` | `#EF4444` | Ruby Crimson — errors, delete actions |
| `textPrimary` | `#F8FAFC` | 100% white-slate for titles, headings, and high emphasis |
| `textSecondary` | `#94A3B8` | Subtext, artists, duration, secondary metadata |
| `textTertiary / muted` | `#64748B` | Subtle captions, timestamps, inactive icons |

---

## 3. Typographic Architecture

- **Primary Font:** Inter / System Sans-Serif
- **Scale:**
  - **Display (Large/Medium):** `28px - 32px`, Weight: 800, Tracking: `-0.5px`
  - **Headline (Medium/Small):** `20px - 24px`, Weight: 700, Tracking: `-0.2px`
  - **Title (Large/Medium/Small):** `14px - 18px`, Weight: 600
  - **Body (Large/Medium/Small):** `12px - 16px`, Weight: 400
  - **Label (Large/Medium/Small):** `10px - 14px`, Weight: 600, Tracking: `+0.2px`

---

## 4. Shape & Radii Hierarchy

- **Subtle / Badge Radius:** `8px` (`radiusSm`)
- **Tile / Artwork Radius:** `12px` - `16px` (`radiusMd` / `radiusLg`)
- **Card / Container Radius:** `16px` (`radiusLg`)
- **Full Player Artwork Radius:** `20px` - `24px`
- **Bottom Navigation / Sheet Top Radius:** `24px` (`radiusXl`)
- **Pill / Button Radius:** `999px` (`radiusFull`)

---

## 5. Layout & Spacing Tokens

- `space2`: `2.0px`
- `space4`: `4.0px`
- `space8`: `8.0px`
- `space12`: `12.0px`
- `space16`: `16.0px`
- `space20`: `20.0px`
- `space24`: `24.0px`
- `space32`: `32.0px`

---

## 6. Component Specs

### 6.1 Mini Player
- Positioned floating above bottom navigation with `8px` side margins.
- Surface color: `surfaceElevated` with subtle border stroke and `12px` blur.
- Live progress indicator along the top or bottom edge.
- Direct tap opens the high-fidelity Full Player.

### 6.2 Full Player Screen
- Implemented as an immersive modal sheet or route.
- Header: playlist/source indicator with minimize chevron.
- Central feature: 280x280 artwork with radiant ambient shadow glow matching track aura.
- Scannable scrub bar with animated elapsed/remaining durations.
- Controls: Shuffle, Previous, 64px Glowing Play/Pause, Next, Repeat.
- Secondary footer: Audio quality badge, Queue sheet button, Favorite heart button, Download indicator.

### 6.3 Procedural Aura Artwork
- For mock songs, artwork generates dynamic multi-stop gradients with geometric overlays (Synthwave gradients, Cosmic nebulae, Deep ocean waves) matching the track's genre and title hash.
- Supports external URLs with zero-flicker fallbacks.
