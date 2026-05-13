# 08 — Resumen de Implementación SED-360 v2

> Documento final — Arquitectura v2 con 4 roles, 5 instrumentos, 20+ tablas, Supabase Storage.

## Stack

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Storage | Supabase Storage (bucket `planeaciones`) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Runtime | Node.js | 20.19.2 |

## Estado Actual (Mayo 2026)

| Módulo | Estado | Archivos clave |
|--------|--------|---------------|
| Auth + Middleware 4 roles | ✅ | `middleware.ts`, `auth.astro` |
| Admin Dashboard | ✅ | KPIs, docentes, usuarios, roles, catálogos |
| Autodiagnóstico | ✅ | Wizard 4 pasos, 24 reactivos |
| Observación de Clase | ✅ | 43 reactivos, 8 secciones, precarga automática |
| Planeaciones | 🔲 | Subida PDF + rúbrica coordinador |
| Encuesta Estudiantil | 🔲 | Wizard anónimo |
| Limpieza archivos | 🔲 | Al cerrar cuatrimestre |

## Problemas Resueltos

| Problema | Solución |
|----------|----------|
| WebSocket en Node 20 | `import ws from 'ws'` estático |
| Code verifier PKCE perdido | Flujo implícito con hash → guardar-sesion |
| RLS recursión infinita | Función `rol_usuario(uid)` SECURITY DEFINER |
| Redirect siempre a estudiante | Endpoint `/api/auth/rol` + redirección inteligente |
| Docente sin perfil | Creación automática al enviar autodiagnóstico |
| Campus/Ofertas/Turnos hardcodeados | Tablas normalizadas + admin CRUD |
| Observación sin precarga | Datos desde perfil docente |

## Tablas de BD (20+)

- **Catálogo normalizado**: cuatrimestres, licenciaturas, ofertas_academicas, campus, turnos
- **Entidades**: docentes, asignaturas, grupos, estudiantes, inscripciones
- **Auth**: usuarios (4 roles)
- **Evaluaciones**: autodiagnosticos (24 ítems), observaciones (43 ítems), planeaciones (PDF + 4 criterios)
- **Resultados**: calificacion_final_docente
- **Control**: encuesta_control_envio

## Páginas Implementadas

| Ruta | Rol | Descripción |
|------|-----|-------------|
| `/` | Público | Landing + OAuth |
| `/auth` | Público | Login Google |
| `/admin/dashboard` | superadmin | KPIs, ranking |
| `/admin/docentes` | superadmin | Gestión con buscador |
| `/admin/usuarios` | superadmin | Tablas por rol con KPIs |
| `/admin/roles` | superadmin | Cambio rápido de roles |
| `/admin/ofertas` | superadmin | CRUD ofertas académicas |
| `/admin/campus` | superadmin | CRUD campus |
| `/admin/turnos` | superadmin | CRUD turnos |
| `/admin/cuatrimestres` | superadmin | Gestión periodos |
| `/coordinador/dashboard` | coord/superadmin | Panel con docentes |
| `/coordinador/captura/observacion` | coord | 43 reactivos |
| `/docente/dashboard` | docente/coord/superadmin | Resultados |
| `/docente/autodiagnostico` | docente | Wizard 4 pasos |
| `/estudiante/dashboard` | estudiante | Encuestas |
