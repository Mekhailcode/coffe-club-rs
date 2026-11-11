-- 1. Hapus tabel lapor_bug jika sudah pernah ada sebelumnya
DROP TABLE IF EXISTS public.lapor_bug CASCADE;

-- 2. Buat tabel lapor_bug sesuai kueri JavaScript
CREATE TABLE public.lapor_bug (
    id SERIAL PRIMARY KEY,
    cabang_id VARCHAR(50) NOT NULL,
    kasir_nama VARCHAR(100) DEFAULT 'Petugas Outlet',
    modul VARCHAR(100) NOT NULL,
    urgensi VARCHAR(50) NOT NULL,
    perangkat VARCHAR(100) DEFAULT 'PC / Tablet POS',
    judul VARCHAR(200) NOT NULL,
    deskripsi TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'Menunggu Review',
    foto_url TEXT,
    dev_assigned VARCHAR(100) DEFAULT 'Tim IT Developer',
    dev_notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Aktifkan RLS & Buka Akses Penuh untuk Publik/Anonim
ALTER TABLE public.lapor_bug ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public All Lapor Bug" ON public.lapor_bug;

CREATE POLICY "Public All Lapor Bug" 
ON public.lapor_bug 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);