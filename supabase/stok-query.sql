-- 1. Hapus constraint unik yang ada saat ini agar proses UPDATE/DELETE tidak terhalang
ALTER TABLE stok_cabang 
DROP CONSTRAINT IF EXISTS stok_cabang_cabang_id_menu_id_key;

ALTER TABLE stok_cabang 
DROP CONSTRAINT IF EXISTS stok_cabang_cabang_menu_unique;

-- 2. Seragamkan semua nama cabang menjadi huruf kecil
UPDATE stok_cabang 
SET cabang_id = LOWER(cabang_id);

-- 3. Hapus baris duplikat (menyimpan baris dengan ID paling besar/terbaru)
DELETE FROM stok_cabang a
USING stok_cabang b
WHERE a.id < b.id 
  AND a.cabang_id = b.cabang_id
  AND a.menu_id = b.menu_id;

-- 4. Pasang kembali Unique Constraint yang bersih
ALTER TABLE stok_cabang 
ADD CONSTRAINT stok_cabang_cabang_menu_unique UNIQUE (cabang_id, menu_id);

-- 1. Pastikan RLS aktif pada tabel
ALTER TABLE stok_cabang ENABLE ROW LEVEL SECURITY;

-- 2. Hapus kebijakan lama yang memblokir
DROP POLICY IF EXISTS "Izinkan Akses Penuh Stok" ON stok_cabang;
DROP POLICY IF EXISTS "Akses Penuh Stok Cabang" ON stok_cabang;

-- 3. Buat kebijakan baru untuk semua operasi (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY "Akses Penuh Stok Cabang" 
ON stok_cabang 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);