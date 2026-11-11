-- Membuka akses RLS SELECT agar route-guard.js dapat memverifikasi role user
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read access for all users" ON public.users;

CREATE POLICY "Allow read access for all users"
ON public.users FOR SELECT
TO authenticated, anon
USING (true);