-- =============================================================================
-- Melo Cloud Database Schema (PostgreSQL / Supabase)
-- Phase 7: Cloud Identity, User Profile, Sync Metadata, and User-Owned Data
-- =============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table (Used when Supabase auth.users or standalone auth is active)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Favorites Table
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    song_id TEXT NOT NULL,
    song_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_favorites_user_song UNIQUE (user_id, song_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_updated_at ON public.favorites(updated_at);

-- 4. Listening History Table
CREATE TABLE IF NOT EXISTS public.listening_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    song_id TEXT NOT NULL,
    song_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    played_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    play_count INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_history_user_song UNIQUE (user_id, song_id)
);

CREATE INDEX IF NOT EXISTS idx_history_user_id ON public.listening_history(user_id);
CREATE INDEX IF NOT EXISTS idx_history_played_at ON public.listening_history(played_at DESC);

-- 5. Playlists Table
CREATE TABLE IF NOT EXISTS public.playlists (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    artwork_url TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_playlists_user_id ON public.playlists(user_id);

-- 6. Playlist Songs Table
CREATE TABLE IF NOT EXISTS public.playlist_songs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    playlist_id TEXT NOT NULL REFERENCES public.playlists(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    song_id TEXT NOT NULL,
    song_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    position INTEGER NOT NULL DEFAULT 0,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_playlist_songs_playlist_song UNIQUE (playlist_id, song_id)
);

CREATE INDEX IF NOT EXISTS idx_playlist_songs_playlist ON public.playlist_songs(playlist_id);
CREATE INDEX IF NOT EXISTS idx_playlist_songs_user_id ON public.playlist_songs(user_id);

-- 7. User Preferences Table
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    audio_quality TEXT NOT NULL DEFAULT 'High (320 kbps AAC)',
    gapless_playback BOOLEAN NOT NULL DEFAULT true,
    normalize_volume BOOLEAN NOT NULL DEFAULT true,
    crossfade_duration NUMERIC(4,1) NOT NULL DEFAULT 0.0,
    offline_only BOOLEAN NOT NULL DEFAULT false,
    download_on_wifi_only BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Sync Metadata Table
CREATE TABLE IF NOT EXISTS public.sync_metadata (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    last_sync_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    server_revision BIGINT NOT NULL DEFAULT 1
);

-- =============================================================================
-- Row Level Security (RLS) Policies
-- Enforces strict user isolation so each user only has access to their own data
-- =============================================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.playlist_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_metadata ENABLE ROW LEVEL SECURITY;

-- user_profiles policies
CREATE POLICY "Users can view own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- favorites policies
CREATE POLICY "Users can view own favorites"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own favorites"
    ON public.favorites FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);

-- listening_history policies
CREATE POLICY "Users can view own listening history"
    ON public.listening_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own listening history"
    ON public.listening_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own listening history"
    ON public.listening_history FOR UPDATE
    USING (auth.uid() = user_id);

-- playlists policies
CREATE POLICY "Users can view own playlists"
    ON public.playlists FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own playlists"
    ON public.playlists FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own playlists"
    ON public.playlists FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own playlists"
    ON public.playlists FOR DELETE
    USING (auth.uid() = user_id);

-- playlist_songs policies
CREATE POLICY "Users can view own playlist songs"
    ON public.playlist_songs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own playlist songs"
    ON public.playlist_songs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own playlist songs"
    ON public.playlist_songs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own playlist songs"
    ON public.playlist_songs FOR DELETE
    USING (auth.uid() = user_id);

-- user_preferences policies
CREATE POLICY "Users can view own preferences"
    ON public.user_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own preferences"
    ON public.user_preferences FOR ALL
    USING (auth.uid() = user_id);

-- sync_metadata policies
CREATE POLICY "Users can view own sync metadata"
    ON public.sync_metadata FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own sync metadata"
    ON public.sync_metadata FOR ALL
    USING (auth.uid() = user_id);
