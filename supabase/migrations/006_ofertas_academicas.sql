-- Migración 006: Catálogo de Ofertas Académicas
-- Tabla reutilizable en todos los formularios

CREATE TABLE IF NOT EXISTS ofertas_academicas (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL UNIQUE,
  activa  BOOLEAN DEFAULT TRUE
);

ALTER TABLE ofertas_academicas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura ofertas" ON ofertas_academicas FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona ofertas" ON ofertas_academicas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- Seed data: las 15 carreras del documento
INSERT INTO ofertas_academicas (nombre) VALUES
  ('Arquitectura'), ('Administración de Empresas'), ('Administración de Empresas Turísticas'),
  ('Mercadotecnia'), ('Sistemas Computacionales'), ('Enfermería'), ('Nutrición'),
  ('Contaduría'), ('Derecho'), ('Pedagogía'), ('Criminología'), ('Comercio Internacional'),
  ('Diseño Gráfico Digital'), ('Inglés'), ('Otros')
ON CONFLICT (nombre) DO NOTHING;
