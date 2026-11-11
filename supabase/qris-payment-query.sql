-- 1. Tambahkan kolom status ke tabel transaksi
ALTER TABLE public.transaksi 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'LUNAS';

-- 2. Pasang validasi isi status
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'transaksi_status_check'
    ) THEN
        ALTER TABLE public.transaksi 
        ADD CONSTRAINT transaksi_status_check 
        CHECK (status IN ('PENDING', 'LUNAS', 'BATAL'));
    END IF;
END $$;

-- 3. Set REPLICA IDENTITY FULL agar payload event Realtime lengkap
ALTER TABLE public.transaksi REPLICA IDENTITY FULL;