# Documentación Técnica — SED-360 v2

> Plataforma de Evaluación Docente 360° — TUP Playacar

## Índice de Módulos

| # | Módulo | Archivo | Estado |
|---|--------|---------|--------|
| 01 | [Esquema Core SQL v2](01-esquema-core.md) | `supabase/migrations/001_esquema_v2.sql` | ⚠️ Legacy v1 |
| 02 | [Tipos del Sistema v2](02-tipos-sistema.md) | `src/types/supabase.ts` | ⚠️ Legacy v1 |
| 08 | [Resumen de Implementación](08-resumen-implementacion.md) | Completo | ✅ v2 |

> **Nota**: Los documentos 01-07 son de la versión anterior (v1). Consultar `docs/sistema_evaluacion.md` y `docs/arquitecture_patterns.md` para la arquitectura v2 actual.

## Convenciones v2

- **Idioma**: Español (variables, funciones, comentarios)
- **Naming**: `camelCase` (funciones), `PascalCase` (componentes), `snake_case` (SQL)
- **Tipado**: TypeScript estricto, prohibido `any`
- **Seguridad**: RLS en todas las tablas + middleware de dominio y roles
- **Auth**: Google OAuth, flujo implícito con cookies

## Stack v2

| Capa | Tecnología |
|------|-----------|
| Frontend | Astro 4.16.18 SSR + Tailwind CSS 3 |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| Validación | Zod |
| Gráficos | Chart.js (CDN) |
| Despliegue | Vercel + Cloudflare WAF |
