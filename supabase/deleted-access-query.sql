-- 1. Buat fungsi SQL Security Definer untuk menghapus user dari auth.users & public.users sekaligus
CREATE OR REPLACE FUNCTION delete_user_complete(target_user_id UUID)
RETURNS void AS $$
BEGIN
    -- Hapus dari tabel public.users
    DELETE FROM public.users WHERE id = target_user_id;
    
    -- Hapus dari tabel auth.users (Engine Login Supabase)
    DELETE FROM auth.users WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Pastikan kebijakan RLS pada tabel users mengizinkan perintah DELETE
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow delete access for all users" ON public.users;

CREATE POLICY "Allow delete access for all users"
ON public.users FOR DELETE
TO authenticated, anon
USING (true);

-- 1. Buat fungsi RPC penghapusan akun dari auth.users & public.users
CREATE OR REPLACE FUNCTION delete_user_complete(target_user_id UUID)
RETURNS void 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
    -- Hapus dari tabel public.users
    DELETE FROM public.users WHERE id = target_user_id;
    
    -- Hapus dari tabel auth.users (Engine Login Supabase)
    DELETE FROM auth.users WHERE id = target_user_id;
END;
$$;

-- 2. Berikan hak akses eksekusi fungsi ke API Supabase
GRANT EXECUTE ON FUNCTION delete_user_complete(UUID) TO authenticated, anon, service_role;