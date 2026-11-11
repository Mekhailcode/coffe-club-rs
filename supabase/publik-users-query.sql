-- 1. Buat tabel public.users jika belum ada
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nama TEXT,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL DEFAULT 'kasir',
    cabang_id TEXT NOT NULL DEFAULT 'all',
    status TEXT NOT NULL DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Aktifkan RLS dan izin akses baca-tulis
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Akses Publik Users" ON public.users;
CREATE POLICY "Akses Publik Users" ON public.users FOR ALL USING (true) WITH CHECK (true);

-- 3. SINKRONISASI AKUN LAMA: Salin 5 akun dari auth.users ke public.users
INSERT INTO public.users (id, nama, email, role, cabang_id, status)
SELECT 
    id,
    COALESCE(raw_user_meta_data->>'nama', initcap(replace(split_part(email, '@', 1), '.', ' '))) AS nama,
    email,
    COALESCE(
        raw_user_meta_data->>'role',
        CASE 
            WHEN email LIKE '%owner%' THEN 'owner'
            WHEN email LIKE '%kc%' THEN 'manager'
            ELSE 'kasir'
        END
    ) AS role,
    COALESCE(
        raw_user_meta_data->>'cabang_id',
        CASE 
            WHEN email LIKE '%senopati%' THEN 'senopati'
            WHEN email LIKE '%kemang%' THEN 'kemang'
            ELSE 'all'
        END
    ) AS cabang_id,
    'aktif' AS status
FROM auth.users
ON CONFLICT (id) DO UPDATE SET 
    email = EXCLUDED.email,
    nama = EXCLUDED.nama;

-- 4. OTOMATISASI (TRIGGER): Setiap ada registrasi di Auth, otomatis masuk ke public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, nama, email, role, cabang_id, status)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nama', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'kasir'),
    COALESCE(NEW.raw_user_meta_data->>'cabang_id', 'all'),
    'aktif'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    nama = EXCLUDED.nama;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();