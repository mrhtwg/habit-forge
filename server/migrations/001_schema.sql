-- HabitForge schema (PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       TEXT NOT NULL UNIQUE,
    password    TEXT NOT NULL DEFAULT '',
    nickname    TEXT NOT NULL DEFAULT '',
    avatar_url  TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth_providers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider    TEXT NOT NULL,
    provider_id TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_auth_providers_user ON auth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_providers_provider ON auth_providers(provider, provider_id);

CREATE TABLE IF NOT EXISTS user_prefs (
    user_id                 UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    charactor_class         TEXT NOT NULL DEFAULT '',
    current_gold            BIGINT NOT NULL DEFAULT 0,
    current_gems            BIGINT NOT NULL DEFAULT 0,
    notifications_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
    sound_enabled           BOOLEAN NOT NULL DEFAULT TRUE,
    haptic_enabled          BOOLEAN NOT NULL DEFAULT TRUE,
    onboarding_completed    BOOLEAN NOT NULL DEFAULT FALSE,
    last_onboarding_step    INT NOT NULL DEFAULT 0,
    total_tasks_completed   BIGINT NOT NULL DEFAULT 0,
    total_tasks             BIGINT NOT NULL DEFAULT 0,
    today_tasks_completed   BIGINT NOT NULL DEFAULT 0,
    today_tasks             BIGINT NOT NULL DEFAULT 0,
    first_task_date         BIGINT NOT NULL DEFAULT 0,
    last_penalty_date       BIGINT NOT NULL DEFAULT 0,
    last_active_date        BIGINT NOT NULL DEFAULT 0,
    death_count             BIGINT NOT NULL DEFAULT 0,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS characters (
    id                     UUID PRIMARY KEY,
    user_id                UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    character_class        TEXT NOT NULL DEFAULT '',
    level                  INT NOT NULL DEFAULT 1,
    current_exp            BIGINT NOT NULL DEFAULT 0,
    max_exp                BIGINT NOT NULL DEFAULT 100,
    current_hp             INT NOT NULL DEFAULT 100,
    strength               INT NOT NULL DEFAULT 0,
    intelligence           INT NOT NULL DEFAULT 0,
    agility                INT NOT NULL DEFAULT 0,
    defense                INT NOT NULL DEFAULT 0,
    vitality               INT NOT NULL DEFAULT 0,
    luck                   INT NOT NULL DEFAULT 0,
    available_stat_points  INT NOT NULL DEFAULT 0,
    equipment              JSONB NOT NULL DEFAULT '{}',
    is_dead                BOOLEAN NOT NULL DEFAULT FALSE,
    death_recovery_until   BIGINT NOT NULL DEFAULT 0,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tasks (
    id                  UUID PRIMARY KEY,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title               TEXT NOT NULL,
    description         TEXT NOT NULL DEFAULT '',
    type                TEXT NOT NULL,
    difficulty          TEXT NOT NULL DEFAULT 'easy',
    tags                JSONB NOT NULL DEFAULT '[]',
    is_completed        BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at        BIGINT NOT NULL DEFAULT 0,
    due_date            BIGINT NOT NULL DEFAULT 0,
    repeat_days         JSONB NOT NULL DEFAULT '[]',
    streak              INT NOT NULL DEFAULT 0,
    last_streak_date    BIGINT NOT NULL DEFAULT 0,
    custom_exp_reward   INT NOT NULL DEFAULT 0,
    custom_gold_reward  INT NOT NULL DEFAULT 0,
    priority            TEXT NOT NULL DEFAULT '',
    hp_penalty          INT NOT NULL DEFAULT 0,
    is_skipped          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at_millis   BIGINT NOT NULL DEFAULT 0,
    updated_at_millis   BIGINT NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tasks_user ON tasks(user_id);

CREATE TABLE IF NOT EXISTS owned_items (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id    TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, item_id)
);
CREATE INDEX IF NOT EXISTS idx_owned_items_user ON owned_items(user_id);

CREATE TABLE IF NOT EXISTS user_achievements (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achieve_id  TEXT NOT NULL,
    unlocked_at BIGINT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, achieve_id)
);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

CREATE TABLE IF NOT EXISTS shop_items (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    price       BIGINT NOT NULL,
    slot        TEXT NOT NULL DEFAULT '',
    rarity      TEXT NOT NULL DEFAULT 'common',
    currency    TEXT NOT NULL DEFAULT 'gold',
    icon        TEXT NOT NULL DEFAULT '',
    category    TEXT NOT NULL DEFAULT 'equipment',
    stat_str    INT NOT NULL DEFAULT 0,
    stat_int    INT NOT NULL DEFAULT 0,
    stat_agi    INT NOT NULL DEFAULT 0,
    stat_def    INT NOT NULL DEFAULT 0,
    stat_vit    INT NOT NULL DEFAULT 0,
    stat_luk    INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS achievement_defs (
    id             TEXT PRIMARY KEY,
    title          TEXT NOT NULL,
    description    TEXT NOT NULL DEFAULT '',
    condition_type TEXT NOT NULL,
    threshold      INT NOT NULL,
    gem_reward     INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS game_constants (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
