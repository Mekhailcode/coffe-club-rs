-- 1. Buat Tabel Profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('owner', 'kepala_cabang', 'kasir')),
    cabang_id VARCHAR(50) DEFAULT 'Senopati',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Policy Akses Baca Publik
DROP POLICY IF EXISTS "Public Read Profiles" ON public.profiles;
CREATE POLICY "Public Read Profiles" ON public.profiles FOR SELECT USING (true);

-- 4. Insert Data Profil (Ganti UUID dengan ID Asli dari Auth -> Users)
INSERT INTO public.profiles (id, username, nama_lengkap, role, cabang_id) VALUES
('5bd61c69-9e25-4523-b316-b858a2f150b5', 'owner', 'Executive Owner', 'owner', 'Semua Cabang'),
('79fadfc1-1e9f-4fde-81ec-ddb778169d0b', 'kcabang_senopati', 'Manajer Senopati', 'kepala_cabang', 'Senopati'),
('d3a31842-0286-43bd-8459-d44b29e05cab', 'kcabang_kemang', 'Manajer Kemang', 'kepala_cabang', 'Kemang'),
('bd05cfce-b2df-45bf-8ac5-4e1a02360006', 'kasir_senopati', 'Kasir Senopati', 'kasir', 'Senopati'),
('dcd877a5-37a8-422b-b66c-850d6b39b90f', 'kasir_kemang', 'Kasir Kemang', 'kasir', 'Kemang')
ON CONFLICT (id) DO UPDATE 
SET 
    username = EXCLUDED.username,
    nama_lengkap = EXCLUDED.nama_lengkap,
    role = EXCLUDED.role,
    cabang_id = EXCLUDED.cabang_id;