-- =============================================================
-- Migración 004: Agregar created_at a periodos
-- =============================================================
-- Propósito: Agregar columna de auditoría created_at a la tabla
-- periodos para cumplir con el spec PA-1.
-- =============================================================

-- Agregar columna created_at con valor por defecto
ALTER TABLE periodos
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Nota: los registros existentes mantienen el valor por defecto NOW()
-- automáticamente al agregar la columna con DEFAULT.
