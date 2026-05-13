# Patrones de Arquitectura — SED-360 v2

## 1. Service Layer

```
src/services/
├── catalogos.ts        # cuatrimestres, licenciaturas, asignaturas, ofertas, campus, turnos
├── docentes.ts         # docentes, grupos
├── estudiantes.ts      # estudiantes, inscripciones
├── instrumentos.ts     # EE, CA, PD, OC, AE
├── calificaciones.ts   # calificacion_final_docente
├── autodiagnostico.ts  # auto-evaluación 24 reactivos
├── observaciones.ts    # observación de clase 43 reactivos
├── planeaciones.ts     # gestión de planeaciones + subida PDF
└── usuarios.ts         # gestión de roles y perfiles
```

## 2. Subida de Archivos (Storage)

**Patrón: Subida directa cliente → Supabase Storage**

```
Navegador                    Supabase Storage           Backend (Astro SSR)
   │                              │                         │
   ├─ selecciona PDF              │                         │
   ├─ supabase.storage.upload()──→│                         │
   │                              ├─ guarda archivo         │
   │←────── URL pública ──────────┤                         │
   │                              │                         │
   ├─ POST /api/... con URL ──────────────────────────────→│
   │                              │                         ├─ guarda registro BD
```

**Ventajas:**
- El archivo NUNCA pasa por Vercel (ahorra bandwidth)
- Subida directa más rápida
- Supabase gestiona la seguridad del bucket

## 3. Layouts por Rol

```
src/layouts/
├── BaseLayout.astro        # Shell HTML común
├── Layout.astro            # Páginas públicas (landing, auth)
├── LayoutAdmin.astro       # Sidebar fijo
├── LayoutCoordinador.astro # Top nav
├── LayoutDocente.astro     # Top nav
└── LayoutEstudiante.astro  # Full-screen
```

## 4. Autorización (Middleware)

Mapa `ROLES_POR_RUTA`:
```
/admin/*        → superadmin
/coordinador/*  → coordinador, superadmin
/docente/*      → docente, superadmin, coordinador
/estudiante/*   → estudiante, superadmin
```

## 5. Flujo de Autenticación

```
/auth → Google OAuth → Supabase → /#access_token=...
    ↓
POST /api/auth/guardar-sesion → cookies
    ↓
GET /api/auth/rol → redirigir según rol
```

## 6. Anonimato de Encuesta Estudiantil

Dos tablas separadas:
- `encuesta_estudiantil_respuestas` — SIN `estudiante_id`
- `encuesta_control_envio` — CON `estudiante_id` (solo registra QUE respondió)

## 7. Limpieza de Archivos al Cerrar Ciclo

Al finalizar un cuatrimestre, el superadmin ejecuta limpieza:
- Borra prefijo `{cuatrimestre_id}/` del bucket `planeaciones`
- Muestra cuántos archivos y MB se liberan
- Solo superadmin puede ejecutarlo
