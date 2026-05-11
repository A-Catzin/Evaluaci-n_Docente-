# 08 — Resumen de Implementación SED-360 v2

> Documento final — Arquitectura v2 con 4 roles, 5 instrumentos, 15+ tablas.

## Stack

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Runtime | Node.js | 20.19.2 |

## Arquitectura

```
src/
├── layouts/    5 layouts (Base, Admin, Coordinador, Docente, Estudiante)
├── services/   5 servicios CRUD (catalogos, docentes, estudiantes, instrumentos, calificaciones)
├── pages/      4 dashboards + 8 páginas secundarias
├── types/      18 interfaces TypeScript
├── lib/        supabaseClient.ts (polyfill ws)
└── middleware.ts  Dominio + autorización 4 roles
```

## Base de Datos (15+ tablas)

- **Catálogo**: cuatrimestres, licenciaturas, docentes, asignaturas, grupos, estudiantes, inscripciones
- **Auth**: usuarios (sync con auth.users, 4 roles)
- **Instrumentos**: encuesta_estudiantil_respuestas (anónima), encuesta_control_envio, evaluacion_coordinacion, evaluacion_planeacion, observacion_clase, autoevaluacion_docente
- **Resultados**: calificacion_final_docente (GENERATED)

## Problemas Resueltos

| Problema | Solución |
|----------|----------|
| WebSocket en Node 20 | `import ws from 'ws'` estático + polyfill |
| Code verifier PKCE perdido | Flujo implícito con hash → guardar-sesion |
| RLS recursión infinita | Función `rol_usuario(uid)` SECURITY DEFINER |
| Redirect siempre a estudiante | Endpoint `/api/auth/rol` + redirección inteligente |
| Middleware crashea en dev | Import estático de ws (no createRequire dinámico) |
| esbuild "componentes" | `is:inline` en scripts problemáticos |

## Páginas y Rutas

| Ruta | Acceso | Descripción |
|------|--------|-------------|
| `/` | Público | Landing + detector OAuth |
| `/auth` | Público | Login Google |
| `/admin/dashboard` | superadmin | KPIs, ranking docentes |
| `/admin/docentes` | superadmin | CRUD docentes |
| `/admin/cuatrimestres` | superadmin | Gestión periodos |
| `/coordinador/dashboard` | coord/superadmin | Panel de área |
| `/coordinador/captura/*` | coord/superadmin | CA, PD, OC |
| `/docente/dashboard` | docente/coord/superadmin | Resultados |
| `/docente/autoevaluacion` | docente | 10 ítems AE |
| `/estudiante/dashboard` | estudiante/superadmin | Encuestas |
| `/estudiante/encuesta/[id]` | estudiante | Wizard 4 pasos |

## Para Ejecutar

```bash
git checkout feature/v2
npm install
# Configurar .env con credenciales Supabase
# Ejecutar migraciones 001 y 002 en Supabase SQL Editor
npm run dev
```
