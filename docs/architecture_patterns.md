# Patrones de Arquitectura — SED-360 v2

## 1. Service Layer

```
src/services/
├── catalogos.ts      # cuatrimestres, licenciaturas, asignaturas
├── docentes.ts       # docentes, grupos
├── estudiantes.ts    # estudiantes, inscripciones
├── instrumentos.ts   # EE, CA, PD, OC, AE
└── calificaciones.ts # calificacion_final_docente
```

Cada servicio encapsula las consultas a Supabase. Las páginas Astro NUNCA llaman a `supabase.from()` directamente.

## 2. Layouts por Rol

```
src/layouts/
├── BaseLayout.astro        # Shell HTML común (meta, fondos, CSS global)
├── LayoutAdmin.astro       # Sidebar fijo para superadmin
├── LayoutCoordinador.astro # Top nav para coordinador
├── LayoutDocente.astro     # Top nav para docente
└── LayoutEstudiante.astro  # Full-screen sin distracciones
```

## 3. Autorización (Middleware)

El middleware `src/middleware.ts` valida en cada request:
1. Cookies de sesión (sb-access-token, sb-refresh-token)
2. Dominio `@tecplayacar.edu.mx`
3. Rol autorizado para la ruta (mapa `ROLES_POR_RUTA`)

```
/admin/*        → superadmin
/coordinador/*  → coordinador, superadmin
/docente/*      → docente, superadmin, coordinador
/estudiante/*   → estudiante, superadmin
```

## 4. Flujo de Autenticación

```
/auth → Google OAuth → Supabase → /#access_token=...&refresh_token=...
                                         ↓
                              index.astro (script is:inline)
                                         ↓
                           POST /api/auth/guardar-sesion → cookies
                                         ↓
                              GET /api/auth/rol → redirigir según rol
```

## 5. Anonimato de Encuesta Estudiantil

Dos tablas separadas:
- `encuesta_estudiantil_respuestas` — SIN `estudiante_id`. Solo guarda docente_id, grupo_id, respuestas.
- `encuesta_control_envio` — CON `estudiante_id`. Solo registra QUE respondió (UNIQUE).

## 6. Normalización de Calificaciones

Cada instrumento tiene su propia fórmula, implementada como `GENERATED ALWAYS AS (...) STORED` en PostgreSQL para CA, PD, OC y AE. La calificación final también es GENERATED. Esto garantiza consistencia entre BD y aplicación.
