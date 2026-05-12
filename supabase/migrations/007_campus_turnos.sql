-- Migración 007: Catálogos de Campus y Turnos

CREATE TABLE IF NOT EXISTS campus (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL UNIQUE,
  activo  BOOLEAN DEFAULT TRUE
);

ALTER TABLE campus ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura campus" ON campus FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona campus" ON campus FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

INSERT INTO campus (nombre) VALUES
  ('Tecnológico Universitario Tuxtla'),
  ('Tecnológico Universitario Playacar'),
  ('Facultad de Ciencias de la Salud')
ON CONFLICT (nombre) DO NOTHING;

-- Turnos
CREATE TABLE IF NOT EXISTS turnos (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(50) NOT NULL UNIQUE,
  activo  BOOLEAN DEFAULT TRUE
);

ALTER TABLE turnos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura turnos" ON turnos FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona turnos" ON turnos FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

INSERT INTO turnos (nombre) VALUES
  ('Matutino'), ('Vespertino'), ('Mixto'), ('Virtual')
ON CONFLICT (nombre) DO NOTHING;
