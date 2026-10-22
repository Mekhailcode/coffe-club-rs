// js/route-guard.js

function checkAuthGuard() {
    const sessionData = localStorage.getItem('user_session');
    
    // 1. Cek apakah sesi login tersedia
    if (!sessionData) {
        window.location.replace('../../login/login.html');
        return;
    }

    try {
        const user = JSON.parse(sessionData);
        const currentPath = window.location.pathname.toLowerCase();

        // 2. Proteksi Akses Lintas Role
        if (currentPath.includes('/owner/pages/') && user.role !== 'owner') {
            window.location.replace('../../login/login.html');
        } else if (currentPath.includes('/kepala-cabang/pages/') && user.role !== 'kepala_cabang') {
            window.location.replace('../../login/login.html');
        } else if (currentPath.includes('/kasir/pages/') && user.role !== 'kasir') {
            window.location.replace('../../login/login.html');
        }
    } catch (e) {
        localStorage.removeItem('user_session');
        window.location.replace('../../login/login.html');
    }
}

// Jalankan pengecekan pertama kali
checkAuthGuard();

// PENTING: Paksa jalankan pengecekan jika halaman dimuat ulang dari bfcache/memori tombol BACK
window.addEventListener('pageshow', function (event) {
    if (event.persisted || (performance && performance.getEntriesByType && performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
        checkAuthGuard();
    }
});

// Fungsi Logout
function handleLogout() {
    localStorage.removeItem('user_session');
    // Gunakan location.replace agar halaman ini ditimpa dan tidak bisa ditekan BACK
    window.location.replace('../../login/login.html');
}