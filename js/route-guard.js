// js/route-guard.js

function checkAuthGuard() {
    const sessionData = sessionStorage.getItem('user_session');
    const currentPath = window.location.pathname.toLowerCase();

    // 1. Mencegah infinite loop jika skrip berjalan di halaman login
    if (currentPath.includes('login.html')) return;
    
    // 2. Cek apakah sesi login tersedia
    if (!sessionData) {
        window.location.replace('../../login/login.html');
        return;
    }

    try {
        const user = JSON.parse(sessionData);
        // Normalisasi role menjadi huruf kecil dan bersihkan spasi
        const role = (user.role || user.peran || '').toLowerCase().trim();

        // 3. Proteksi Akses Lintas Role (Dukungan penuh untuk variasi nama role)
        if (currentPath.includes('/owner/pages/')) {
            // Khusus Halaman Owner
            if (role !== 'owner') {
                window.location.replace('../../login/login.html');
            }
        } else if (currentPath.includes('/kepala-cabang/pages/')) {
            // Halaman Kepala Cabang (Menerima role: manager, kepala_cabang, kepala cabang, atau owner)
            if (role !== 'kepala_cabang' && role !== 'kepala cabang' && role !== 'manager' && role !== 'owner') {
                window.location.replace('../../login/login.html');
            }
        } else if (currentPath.includes('/kasir/pages/')) {
            // Halaman Kasir POS (Menerima role: kasir, manager, kepala_cabang, atau owner)
            if (role !== 'kasir' && role !== 'manager' && role !== 'kepala_cabang' && role !== 'kepala cabang' && role !== 'owner') {
                window.location.replace('../../login/login.html');
            }
        }
    } catch (e) {
        console.error("Auth Guard Error:", e);
        sessionStorage.removeItem('user_session');
        window.location.replace('../../login/login.html');
    }
}

// Jalankan pengecekan pertama kali
checkAuthGuard();

// Paksa jalankan pengecekan jika halaman dimuat ulang dari bfcache/memori tombol BACK
window.addEventListener('pageshow', function (event) {
    if (event.persisted || (performance && performance.getEntriesByType && performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
        checkAuthGuard();
    }
});

// Fungsi Logout Global
function handleLogout() {
    sessionStorage.removeItem('user_session');
    window.location.replace('../../login/login.html');
}