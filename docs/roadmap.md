# roadmap.md
La secuencia de pasos para la ejecución.

```markdown
# Roadmap de Implementación - SED

## Fase 1: Setup & Auth (Día 1-2)
* [ ] Configurar proyecto en Supabase con Google Auth.
* [ ] Crear tablas de `perfiles` y `docentes`.
* [ ] Implementar Middleware de Astro para restringir el dominio de correo.

## Fase 2: Flujo de Evaluación (Día 3-5)
* [ ] Generar vista de "Mis Materias" para el alumno basada en `vinculaciones`.
* [ ] Crear formulario dinámico con escala Likert 1-5.
* [ ] Programar el guardado en `JSONB` y marcar `completado = true`.

## Fase 3: Analítica y Admin (Día 6-8)
* [ ] Desarrollar lógica SQL para promediar valores dentro del JSONB.
* [ ] Crear dashboard para Coordinadores con visualización de resultados por docente.
* [ ] Aplicar filtro de palabras prohibidas en la sección de comentarios.

## Fase 4: QA y Despliegue (Día 9-10)
* [ ] Pruebas de estrés para concurrencia de alumnos.
* [ ] Auditoría de anonimato en los reportes.
* [ ] Despliegue en producción vía Vercel.