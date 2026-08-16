// ============================================================
//  missmat — конфиг Supabase
//  После создания проекта вставь свои данные:
//   1) Supabase Dashboard -> ваш проект -> Settings -> API
//   2) Project URL  -> в SUPABASE_URL
//   3) anon public key -> в SUPABASE_ANON_KEY
//  (Anonymous key безопасно хранить в клиенте)
// ============================================================

const SUPABASE_URL = "https://ЗАМЕНИТЕ.supabase.co";
const SUPABASE_ANON_KEY = "eyJЗАМЕНИТЕ";

// Админ-аккаунт (это ник, под которым заходишь в админку)
const ADMIN_USER = "mendix1337";
// Пароль админа НЕ храним в клиенте:
// в login.html пароль сверяется с записью profiles (password_hash),
// а запись админа создаётся скриптом admin-seed (см. README).