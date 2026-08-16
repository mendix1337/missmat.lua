// ============================================================
//  missmat — конфиг Supabase
//
//  Где взять данные (новый интерфейс Supabase):
//    В правом верхнем углу панели проекта нажмите "Connect"
//    -> App Frameworks / API Keys:
//
//    1) Project URL -> в SUPABASE_URL
//       (вид: https://XXXXXXX.supabase.co)
//
//    2) NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY -> в SUPABASE_ANON_KEY
//       Это тот же клиентский ключ (раньше назывался "anon public").
//       Начинается с "eyJ". Его можно хранить в клиенте.
// ============================================================

const SUPABASE_URL = "qfnjaajrzcduhnonwxft.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_TB6No8Qk4-jOWB7dPbP7KA_Aba7xmd_";

// Админ-аккаунт (ник, под которым заходишь в админку)
const ADMIN_USER = "mendix1337";