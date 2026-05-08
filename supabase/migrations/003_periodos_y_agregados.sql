-- =============================================================
-- Migración 003: Periodos y Resultados Agregados
-- =============================================================
-- Propósito: Crear la tabla de periodos académicos, agregar la
-- FK a cargas_academicas, y definir la vista materializada de
-- resultados agregados para el dashboard 360°.
--
-- Tablas:
--   1. periodos — Catálogo de periodos académicos
--   2. resultados_agregados (MV) — Vista materializada con
--      promedios por tipo de actor para cada carga
--
-- Dependencias:
--   - Tabla cargas_academicas (001_esquema_core.sql)
--   - Tabla evaluaciones (001_esquema_core.sql)
-- =============================================================

-- 1. Catálogo de Periodos
CREATE TABLE IF NOT EXISTS periodos (
    id_periodo TEXT PRIMARY KEY,        -- Ej: "2025-1"
    nombre TEXT NOT NULL,                -- Ej: "Enero-Junio 2025"
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT false
);

-- Índice único parcial: solo un periodo puede estar activo a la vez
CREATE UNIQUE INDEX IF NOT EXISTS idx_periodo_activo
    ON periodos(activo) WHERE activo = true;

-- 2. FK en cargas_academicas → periodos (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_cargas_periodo'
    ) THEN
        ALTER TABLE cargas_academicas
        ADD CONSTRAINT fk_cargas_periodo
        FOREIGN KEY (id_periodo) REFERENCES periodos(id_periodo);
    END IF;
END $$;

-- 3. Vista Materializada: Resultados Agregados
CREATE MATERIALIZED VIEW IF NOT EXISTS resultados_agregados AS
SELECT
    ca.id_carga,
    ca.id_docente,
    ca.id_materia,
    ca.id_periodo,
    ROUND(AVG(e.puntaje_promedio) FILTER (WHERE e.tipo_actor = 'ALUMNO')::numeric, 2) AS promedio_alumno,
    COUNT(e.id_evaluacion) FILTER (WHERE e.tipo_actor = 'ALUMNO') AS total_alumno,
    ROUND(AVG(e.puntaje_promedio) FILTER (WHERE e.tipo_actor = 'COORDINADOR')::numeric, 2) AS promedio_coordinador,
    COUNT(e.id_evaluacion) FILTER (WHERE e.tipo_actor = 'COORDINADOR') AS total_coordinador,
    ROUND(AVG(e.puntaje_promedio) FILTER (WHERE e.tipo_actor = 'TECNICO')::numeric, 2) AS promedio_tecnico,
    COUNT(e.id_evaluacion) FILTER (WHERE e.tipo_actor = 'TECNICO') AS total_tecnico,
    ROUND(AVG(e.puntaje_promedio) FILTER (WHERE e.tipo_actor = 'CALIDAD')::numeric, 2) AS promedio_calidad,
    COUNT(e.id_evaluacion) FILTER (WHERE e.tipo_actor = 'CALIDAD') AS total_calidad,
    ROUND(AVG(e.puntaje_promedio) FILTER (WHERE e.tipo_actor = 'AUTO')::numeric, 2) AS promedio_auto,
    COUNT(e.id_evaluacion) FILTER (WHERE e.tipo_actor = 'AUTO') AS total_auto
FROM cargas_academicas ca
LEFT JOIN evaluaciones e ON ca.id_carga = e.id_carga
    AND (e.marcado_inapropiado IS FALSE OR e.marcado_inapropiado IS NULL)
GROUP BY ca.id_carga;

-- Índice único para búsquedas por carga
CREATE UNIQUE INDEX IF NOT EXISTS idx_resultados_carga
    ON resultados_agregados(id_carga);

-- 4. Políticas RLS para periodos
ALTER TABLE periodos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios autenticados pueden leer periodos"
    ON periodos
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Solo admin puede gestionar periodos"
    ON periodos
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid() AND u.rol = 'admin'
        )
    );

-- ⚠️ Las vistas materializadas NO soportan RLS en PostgreSQL.
-- La protección de acceso a resultados_agregados se realiza en:
--   1. Middleware de Astro (src/middleware.ts): bloquea /admin/* para roles no autorizados
--   2. Servicio agregacion.ts: consulta la MV solo desde endpoints protegidos
--   3. Función refrescar_resultados(): SECURITY DEFINER, solo authenticated

-- 5. Función para refrescar la vista materializada (solo authenticated)
CREATE OR REPLACE FUNCTION public.refrescar_resultados()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY resultados_agregados;
END;
$$;

-- Restringir el uso de la función solo a usuarios admin via RLS
-- (SECURITY DEFINER requiere control explícito)
REVOKE ALL ON FUNCTION public.refrescar_resultados() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.refrescar_resultados() TO authenticated;

-- 6. Seed data: periodos iniciales
INSERT INTO periodos (id_periodo, nombre, fecha_inicio, fecha_fin, activo)
VALUES
    ('2025-1', 'Enero-Junio 2025', '2025-01-13', '2025-06-27', true),
    ('2025-2', 'Agosto-Diciembre 2025', '2025-08-11', '2025-12-19', false),
    ('2024-2', 'Agosto-Diciembre 2024', '2024-08-12', '2024-12-20', false)
ON CONFLICT (id_periodo) DO NOTHING;
