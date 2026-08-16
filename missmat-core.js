// ============================================================
//  missmat — общий JS (подключается на всех страницах)
//  Подключает Supabase-клиент, хэширование пароля, утилиты
// ============================================================

// SHA-256 хэш (Web Crypto). Используем с солью "mm:"
async function sha(text) {
    const data = new TextEncoder().encode('mm:' + text);
    const buf = await crypto.subtle.digest('SHA-256', data);
    return [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('');
}

// месяц по МСК (UTC+3)
function mscMonth() {
    const d = new Date(Date.now() + 3 * 3600 * 1000);
    return d.toISOString().slice(0, 7);
}
// unix-время по МСК (секунды)
function mscNow() {
    return Math.floor(Date.now() / 1000) + 3 * 3600;
}

// реальный IP клиента (через безключевой сервис, используется для лимита регистраций)
async function getClientIP() {
    try {
        const r = await fetch('https://api.ipify.org?format=json', { cache: 'no-store' });
        const j = await r.json();
        return j.ip || '';
    } catch (e) {
        return '';
    }
}

// генерация кода ключа активации: XXXXX-XXXXX-XXXXX
function makeKeyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    const part = len => {
        let s = '';
        for (let i = 0; i < len; i++) s += chars[Math.floor(Math.random() * chars.length)];
        return s;
    };
    return part(5) + '-' + part(5) + '-' + part(5);
}

// ---------------- инициализация Supabase ----------------
let supabaseClient = null;
let SUPABASE_OK = false;

try {
    if (typeof SUPABASE_URL !== 'undefined' && typeof SUPABASE_ANON_KEY !== 'undefined'
        && !SUPABASE_URL.includes('ЗАМЕНИТЕ') && SUPABASE_ANON_KEY.includes('eyJ')) {
        supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        SUPABASE_OK = true;
    }
} catch (e) {
    SUPABASE_OK = false;
}

async function sb() {
    if (!SUPABASE_OK) throw new Error('Supabase не настроен. Заполните supabase-config.js');
    return supabaseClient;
}

// ---------- helpers ----------
function redirectIfNotLogged() {
    const u = localStorage.getItem('mm_session');
    if (!u) { location.href = 'login.html'; return null; }
    return u;
}