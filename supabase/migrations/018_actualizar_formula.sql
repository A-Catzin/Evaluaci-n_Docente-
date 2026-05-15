-- Migración 018: Actualizar fórmula de ponderación 35/20/15/25/5 + documentación
-- Nueva fórmula: EE(35) + CA(20) + PD(15) + OC(25) + AE(5)

-- Recrear la columna GENERATED de calificacion_final con los nuevos pesos
ALTER TABLE calificacion_final_docente DROP COLUMN IF EXISTS calificacion_final;
ALTER TABLE calificacion_final_docente ADD COLUMN calificacion_final DECIMAL(5,2) GENERATED ALWAYS AS (
    COALESCE(score_encuesta_estudiantil, 0) * 0.35 +
    COALESCE(score_coordinacion, 0) * 0.20 +
    COALESCE(score_planeacion, 0) * 0.15 +
    COALESCE(score_observacion, 0) * 0.25 +
    COALESCE(score_autoevaluacion, 0) * 0.05
) STORED;
