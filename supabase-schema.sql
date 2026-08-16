-- ============================================================
-- missmat — схема для Supabase
-- Выполните этот SQL в редакторе Supabase: SQL Editor -> New query
-- (Supabase Dashboard -> ваш проект -> SQL Editor)
-- ============================================================

-- Таблица пользователей
CREATE TABLE IF NOT EXISTS public.profiles (
    id          BIGSERIAL PRIMARY KEY,
    username    TEXT UNIQUE NOT NULL,
    email       TEXT DEFAULT '',                -- необязательный
    password_hash TEXT NOT NULL,
    ip          TEXT NOT NULL DEFAULT '',
    reg_month   TEXT NOT NULL DEFAULT '',
    license_end BIGINT NOT NULL DEFAULT 0,      -- unix (МСК) до которого активна лицензия
    license_key TEXT DEFAULT '',                -- последний использованный ключ
    is_admin    INTEGER NOT NULL DEFAULT 0,     -- 1 = админ
    banned      INTEGER NOT NULL DEFAULT 0,
    muted       INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Лимит 1 регистрация с IP в месяц
CREATE TABLE IF NOT EXISTS public.registrations (
    id          BIGSERIAL PRIMARY KEY,
    ip          TEXT NOT NULL,
    month       TEXT NOT NULL,
    username    TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (ip, month)
);

-- Ключи активации (генерирует админ)
CREATE TABLE IF NOT EXISTS public.license_keys (
    id          BIGSERIAL PRIMARY KEY,
    key         TEXT UNIQUE NOT NULL,           -- кодовое слово для активации
    days        INTEGER NOT NULL DEFAULT 30,    -- сколько дней даёт ключ
    used_by     TEXT DEFAULT '',                -- кто активировал
    used_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_profiles_license ON public.profiles (license_end);
CREATE INDEX IF NOT EXISTS idx_keys_used ON public.license_keys (used_by);

-- Дополнить старые таблицы недостающими колонками (если запускаешь повторно)
DO $$
BEGIN
    BEGIN ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS license_key TEXT DEFAULT ''; EXCEPTION WHEN duplicate_column THEN NULL; END;
    BEGIN ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin INTEGER NOT NULL DEFAULT 0; EXCEPTION WHEN duplicate_column THEN NULL; END;
    BEGIN ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS banned INTEGER NOT NULL DEFAULT 0; EXCEPTION WHEN duplicate_column THEN NULL; END;
    BEGIN ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS muted INTEGER NOT NULL DEFAULT 0; EXCEPTION WHEN duplicate_column THEN NULL; END;
END $$;

-- ---- RLS (политики) ----
-- ВАЖНО: для простоты статичной версии политики открытые.
-- Для продакшена: перенесите проверки на Edge Functions / RPC.
-- Схему можно запускать повторно: политики и таблицы
-- пересоздаются без ошибок (IF NOT EXISTS / DROP IF EXISTS).

ALTER TABLE public.profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.license_keys  ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_public_all"      ON public.profiles;
DROP POLICY IF EXISTS "registrations_public_all" ON public.registrations;
DROP POLICY IF EXISTS "license_keys_public_all"  ON public.license_keys;

CREATE POLICY "profiles_public_all"      ON public.profiles      FOR ALL      USING (true) WITH CHECK (true);
CREATE POLICY "registrations_public_all" ON public.registrations FOR ALL      USING (true) WITH CHECK (true);
CREATE POLICY "license_keys_public_all"  ON public.license_keys  FOR ALL      USING (true) WITH CHECK (true);

-- ---- Админ-аккаунт ----
-- Логин: mendix1337, пароль: dimaster1212
-- password_hash = SHA-256("mm:dimaster1212") — считается на клиенте функцией sha()
INSERT INTO public.profiles (username, email, password_hash, ip, reg_month, license_end, license_key, is_admin, banned, muted)
SELECT 'mendix1337', 'admin@missmat.com', '03e55c38f3597ee1d86ac9e7125c05df0f9ffc6d55fba67a8c930e6de2a743f6', '', '', 0, '', 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE username = 'mendix1337');