-- Migración 014: Modalidad en docentes
ALTER TABLE docentes ADD COLUMN IF NOT EXISTS modalidad TEXT DEFAULT 'Escolarizado';
