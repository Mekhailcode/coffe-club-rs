-- 1. Buat tabel users jika belum ada
CREATE TABLE IF NOT EXISTS public.users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nama TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT DEFAULT '123456',
    role TEXT NOT NULL DEFAULT 'kasir',
    cabang_id TEXT NOT NULL DEFAULT 'all',
    status TEXT NOT NULL DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Aktifkan RLS dan berikan izin akses CRUD
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Akses Publik Users" ON public.users;
CREATE POLICY "Akses Publik Users" 
ON public.users 
FOR ALL 
USING (true) 
WITH CHECK (true);