# Roadmap de Implementación - SED-360

Esta es la ruta de sprints recomendada para llevar la plataforma de 0 a Producción de manera iterativa y segura.

## Fase 1: Setup e Infraestructura Base (Semana 1)
* [ ] Configurar Repositorio (Astro, Tailwind, TypeScript).
* [ ] Configurar Proyecto Supabase (PostgreSQL, Auth Google).
* [ ] Crear Esquema SQL Core (`usuarios`, `cargas_academicas`, `evaluaciones`).
* [ ] Implementar Restricción RLS y Constraint de Voto Único (`unique_vote`).
* [ ] Desarrollar Middleware de Astro para restringir dominio `@...edu.mx`.

## Fase 2: Flujo del Evaluador (Semana 2)
* [ ] Construir Layout Base y UI de Autenticación.
* [ ] Generar vista "Mis Cargas" (Dashboard del evaluador).
* [ ] Desarrollar Componente de Cuestionario Likert Interactivo.
* [ ] Implementar Servicio de Captura (`INSERT` en `evaluaciones`).
* [ ] Incorporar función utilitaria de Moderación de Textos (Filtro Blacklist).

## Fase 3: Algoritmo 360 y Análisis (Semana 3)
* [ ] Programar lógica TypeScript de Normalización Likert (Base 100).
* [ ] Desarrollar Servicio de Ponderación (Alumno 35%, Técnico 25%, Coord 20%, etc.).
* [ ] Crear Cron Job o Vista Materializada SQL para `resultados_agregados`.
* [ ] Construir Tablero Administrativo para Coordinadores (Gráficos tipo Radar).

## Fase 4: Pruebas, QA y Producción (Semana 4)
* [ ] Test de Estrés (Simulación de concurrencia estudiantil masiva).
* [ ] Auditoría de Anonimato (Verificación de desvinculación en interfaz de resultados).
* [ ] Carga Inicial de Datos (Seed de Cargas Académicas del periodo actual).
* [ ] Despliegue en Vercel y Configuración de Reglas WAF en Cloudflare.