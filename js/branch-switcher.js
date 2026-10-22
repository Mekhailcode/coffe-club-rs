// js/branch-switcher.js

function initBranchState() {
    const savedBranch = localStorage.getItem('activeBranch') || 'senopati';
    const selector = document.getElementById('branchSelector');
    if (selector) {
        selector.value = savedBranch;
    }
    updateBranchUI(savedBranch);
    
    // Panggil fungsi pemuat data cabang jika ada di halaman aktif
    if (typeof loadBranchData === 'function') {
        loadBranchData(savedBranch);
    }
}

function switchActiveBranch(branchKey) {
    localStorage.setItem('activeBranch', branchKey);
    if (typeof playAudio === 'function') playAudio('click');
    updateBranchUI(branchKey);
    
    if (typeof loadBranchData === 'function') {
        loadBranchData(branchKey);
    } else {
        location.reload();
    }
}

function updateBranchUI(branchKey) {
    const branchName = branchKey === 'kemang' ? 'Cabang Kemang' : 'Cabang Senopati';
    
    // Update label lokasi di sidebar
    const sidebarScope = document.getElementById('sidebarScopeText');
    if (sidebarScope) {
        sidebarScope.innerHTML = `<i class="fa-solid fa-location-dot mr-1.5 text-amber-400"></i>${branchName}`;
    }

    // Update banner/badge lokasi di konten utama jika ada
    const bannerScope = document.getElementById('bannerBranchText');
    if (bannerScope) {
        bannerScope.innerText = branchName.toUpperCase();
    }
}

document.addEventListener('DOMContentLoaded', initBranchState);