# Documentación Técnica — SED-360

> Plataforma de Evaluación Docente 360° — Tecnológico Universitario Playacar

## Índice de Módulos

| # | Módulo | Archivo(s) | Fase |
|---|--------|-----------|------|
| 01 | [Esquema Core SQL](01-esquema-core.md) | `supabase/migrations/001_esquema_core.sql` | 1 |
| 02 | [Tipos del Sistema](02-tipos-sistema.md) | `src/types/supabase.ts` | 1 |
| 03 | [Cliente de Supabase](03-cliente-supabase.md) | `src/lib/supabaseClient.ts` | 1 |
| 04 | [Normalización Likert](04-normalizacion-likert.md) | `src/utils/normalizacion.ts` | 1 |
| 05 | [Servicio de Evaluaciones](05-servicio-evaluaciones.md) | `src/services/evaluaciones.ts` | 1 |
| 06 | [Schemas de Validación](06-schemas-validacion.md) | `src/schemas/validacion.ts` | 1 |
| 07 | [Middleware de Dominio](07-middleware-dominio.md) | `src/middleware.ts` | 1 |

## Convenciones

- **Idioma**: Español para variables, funciones, comentarios y documentación.
- **Naming**: `camelCase` (funciones/variables), `PascalCase` (componentes), `snake_case` (tablas SQL).
- **Tipado**: TypeScript estricto, prohibido `any`.
- **Seguridad**: Toda tabla SQL incluye políticas RLS. Errores técnicos nunca se exponen al usuario.

## Stack

| Capa | Tecnología |
|------|-----------|
| Frontend | Astro 4 SSR + Tailwind CSS 3 |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| Validación | Zod |
| Despliegue | Vercel + Cloudflare WAF |
