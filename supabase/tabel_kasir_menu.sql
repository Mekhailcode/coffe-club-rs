-- ==========================================
-- 1. TABEL MENU PRODUK
-- ==========================================
CREATE TABLE IF NOT EXISTS public.menu (
    id SERIAL PRIMARY KEY,
    nama_menu VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL CHECK (kategori IN ('kopi', 'nonkopi', 'pastry', 'makanan')),
    harga NUMERIC(12, 2) NOT NULL,
    badge VARCHAR(50) DEFAULT 'Spesial',
    icon VARCHAR(50) DEFAULT 'fa-mug-hot',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 2. TABEL STOK CABANG
-- ==========================================
CREATE TABLE IF NOT EXISTS public.stok_cabang (
    id SERIAL PRIMARY KEY,
    cabang_id VARCHAR(50) NOT NULL,
    menu_id INT REFERENCES public.menu(id) ON DELETE CASCADE,
    stok INT NOT NULL DEFAULT 50 CHECK (stok >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(cabang_id, menu_id)
);

-- ==========================================
-- 3. TABEL TRANSAKSI PENJUALAN
-- ==========================================
CREATE TABLE IF NOT EXISTS public.transaksi (
    id VARCHAR(50) PRIMARY KEY,
    cabang_id VARCHAR(50) NOT NULL,
    kasir_nama VARCHAR(100) NOT NULL DEFAULT 'Kasir On-Duty',
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    tipe_pesanan VARCHAR(50) DEFAULT 'Dine-In',
    customer_meta VARCHAR(100) DEFAULT 'General',
    metode_bayar VARCHAR(20) NOT NULL CHECK (metode_bayar IN ('Cash', 'QRIS', 'Debit')),
    subtotal NUMERIC(12, 2) NOT NULL,
    pajak NUMERIC(12, 2) NOT NULL,
    total_bayar NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 4. TABEL DETAIL TRANSAKSI ITEM
-- ==========================================
CREATE TABLE IF NOT EXISTS public.detail_transaksi (
    id SERIAL PRIMARY KEY,
    transaksi_id VARCHAR(50) REFERENCES public.transaksi(id) ON DELETE CASCADE,
    menu_id INT REFERENCES public.menu(id) ON DELETE SET NULL,
    nama_menu VARCHAR(100) NOT NULL,
    qty INT NOT NULL,
    harga_satuan NUMERIC(12, 2) NOT NULL,
    subtotal_item NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 5. RE-CREATE TABEL BUG REPORTS (HAPUS LAMA & BUAT BARU)
-- ==========================================
DROP TABLE IF EXISTS public.bug_reports CASCADE;

CREATE TABLE public.bug_reports (
    id SERIAL PRIMARY KEY,
    cabang_id VARCHAR(50) NOT NULL,
    kasir_nama VARCHAR(100) DEFAULT 'Kepala Cabang / Kasir',
    modul VARCHAR(100) NOT NULL,
    urgensi VARCHAR(50) NOT NULL,
    perangkat VARCHAR(100) DEFAULT 'PC / Tablet POS',
    judul VARCHAR(200) NOT NULL,
    deskripsi TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'Menunggu Review',
    dev_assigned VARCHAR(100) DEFAULT 'Tim IT Developer',
    dev_notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 6. AKTIFKAN RLS & ATUR POLICY AKSES
-- ==========================================
ALTER TABLE public.menu ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stok_cabang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaksi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detail_transaksi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bug_reports ENABLE ROW LEVEL SECURITY;

-- Clean Up Policy Lama Agar Tidak Bentrok
DROP POLICY IF EXISTS "Public Read Menu" ON public.menu;
DROP POLICY IF EXISTS "Public All Menu" ON public.menu;
DROP POLICY IF EXISTS "Public Read Stok" ON public.stok_cabang;
DROP POLICY IF EXISTS "Public All Stok Update" ON public.stok_cabang;
DROP POLICY IF EXISTS "Public All Transaksi" ON public.transaksi;
DROP POLICY IF EXISTS "Public All Detail Transaksi" ON public.detail_transaksi;
DROP POLICY IF EXISTS "Public All Bug Reports" ON public.bug_reports;
DROP POLICY IF EXISTS "Akses Penuh Bug Reports" ON public.bug_reports;

-- Buat Policy Baru Berizin Akses Penuh
CREATE POLICY "Public All Menu" ON public.menu FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Stok Update" ON public.stok_cabang FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Transaksi" ON public.transaksi FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Detail Transaksi" ON public.detail_transaksi FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Bug Reports" ON public.bug_reports FOR ALL USING (true) WITH CHECK (true);

-- ==========================================
-- 7. DATA AWAL (SEEDING MENU PRODUK)
-- ==========================================
INSERT INTO public.menu (id, nama_menu, kategori, harga, badge, icon) VALUES
(1, 'Kopi Susu Coffe Club', 'kopi', 25000, 'Best Seller', 'fa-mug-hot'),
(2, 'Americano Ice Doppio', 'kopi', 24000, 'Favorit', 'fa-whiskey-glass'),
(3, 'Caramel Macchiato Oat', 'kopi', 38000, 'Premium', 'fa-mug-saucer'),
(4, 'Matcha Latte Uji', 'nonkopi', 35000, 'Non-Kopi', 'fa-leaf'),
(5, 'Choco Belgia Premium', 'nonkopi', 25000, 'Manis', 'fa-cubes-stacked'),
(6, 'Artisan Butter Croissant', 'pastry', 20000, 'Fresh Bake', 'fa-bread-slice'),
(7, 'Pain Au Chocolat', 'pastry', 22000, 'Popular', 'fa-cookie'),
(8, 'Nasi Gila Senopati', 'makanan', 30000, 'Spesial', 'fa-bowl-rice'),
(9, 'Spaghetti Aglio Olio', 'makanan', 40000, 'Hot', 'fa-utensils'),
(10, 'French Fries Truffle', 'makanan', 23000, 'Snack', 'fa-box-tissue')
ON CONFLICT (id) DO NOTHING;

-- Resynchronize Sequence ID Menu
SELECT setval(pg_get_serial_sequence('public.menu', 'id'), COALESCE(max(id), 1)) FROM public.menu;

-- ==========================================
-- 8. DATA AWAL (STOK CABANG SENOPATI & KEMANG)
-- ==========================================
INSERT INTO public.stok_cabang (cabang_id, menu_id, stok) VALUES
('Senopati', 1, 50), ('Senopati', 2, 40), ('Senopati', 3, 30), ('Senopati', 4, 25), ('Senopati', 5, 35),
('Senopati', 6, 20), ('Senopati', 7, 15), ('Senopati', 8, 30), ('Senopati', 9, 25), ('Senopati', 10, 40),
('Kemang', 1, 45), ('Kemang', 2, 35), ('Kemang', 3, 25), ('Kemang', 4, 30), ('Kemang', 5, 30),
('Kemang', 6, 18), ('Kemang', 7, 12), ('Kemang', 8, 25), ('Kemang', 9, 20), ('Kemang', 10, 35)
ON CONFLICT (cabang_id, menu_id) DO NOTHING;