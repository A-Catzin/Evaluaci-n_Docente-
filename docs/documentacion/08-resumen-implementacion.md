# 08 — Resumen de Implementación SED-360

> Documento generado al finalizar las Fases 1, 2 y 3 del desarrollo.

## Stack Final

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Validación | Zod | — |
| Gráficos | Chart.js (CDN) | — |
| Runtime | Node.js | 20.19.2 |
| Paquetes extra | ws, @supabase/ssr, @astrojs/check | — |

---

## Arquitectura

```
src/
├── components/          # UI atómica
│   └── EscalaLikert.astro    # 5 bloques táctiles vanilla JS
├── features/
│   └── moderacion/
│       └── blacklist.ts       # Filtro de 22 palabras
├── layouts/
│   └── Layout.astro           # Base con navbar por rol
├── lib/
│   └── supabaseClient.ts      # Cliente lazy + polyfill WebSocket
├── pages/
│   ├── index.astro            # Landing + detector OAuth (hash)
│   ├── auth.astro             # Login Google
│   ├── auth/callback.astro    # Callback (obsoleto en flujo final)
│   ├── api/auth/
│   │   ├── signout.ts         # Cerrar sesión
│   │   └── guardar-sesion.ts  # POST: guarda tokens en cookies
│   ├── api/evaluar.ts         # POST: recibe Likert → normaliza → inserta
│   ├── api/admin/
│   │   └── refrescar-resultados.ts  # GET: refresca MV
│   ├── evaluador/
│   │   ├── index.astro        # Dashboard "Mis Evaluaciones"
│   │   └── evaluar/[id].astro # Formulario modo enfoque
│   └── admin/
│       ├── dashboard.astro    # Panel admin con progreso
│       └── dashboard/docente/
│           └── [id].astro     # Detalle: radar + comentarios
├── schemas/
│   └── validacion.ts          # Zod schemas
├── services/
│   ├── evaluaciones.ts        # CRUD evaluaciones
│   ├── cargas.ts              # Consulta cargas con estado
│   ├── periodos.ts            # CRUD periodos
│   └── agregacion.ts          # Consulta MV + comentarios anónimos
├── types/
│   └── supabase.ts            # Interfaces + constantes 360°
└── utils/
    └── normalizacion.ts       # Fórmula Likert → base 100

supabase/migrations/
├── 001_esquema_core.sql       # usuarios, cargas_academicas, evaluaciones
├── 002_trigger_usuario.sql    # on_auth_user_created
├── 003_periodos_y_agregados.sql  # periodos + MV resultados_agregados
└── 004_created_at_periodos.sql   # columna created_at
```

---

## Flujo de Autenticación (problema más complejo)

### Problema original
El login con Google OAuth no funcionaba. Se probaron múltiples enfoques.

### Intentos fallidos

| # | Enfoque | Error |
|---|---------|-------|
| 1 | Callback API (`/api/auth/callback`) con `exchangeCodeForSession` en servidor | `code` no llegaba (venía en hash, no en query string) |
| 2 | PKCE con `flowType: 'pkce'` | `code_verifier` no disponible en servidor (está en sessionStorage) |
| 3 | Callback como página Astro con `createClient` + `exchangeCodeForSession` | Script no se ejecutaba (Vite no empaquetaba supabase-js) |
| 4 | Callback con `@supabase/ssr` `createBrowserClient` | Botón dejó de funcionar |
| 5 | Callback con `fetch` directo a API de Supabase | `redirectTo` impedía que llegaran tokens |

### Solución final (flujo implícito sin callback)

```
auth.astro → signInWithOAuth({ provider: 'google' })  ← sin redirectTo
     │
     ▼
Google OAuth → Supabase
     │
     ▼
http://localhost:4321/#access_token=...&refresh_token=...
     │
     ▼
index.astro → script is:inline extrae tokens del hash
     │
     ▼
POST /api/auth/guardar-sesion → cookies sb-access-token, sb-refresh-token
     │
     ▼
window.location = '/evaluador'
     │
     ▼
middleware.ts → lee cookies → setSession → valida dominio → next()
```

### Otros problemas resueltos

| Problema | Causa | Solución |
|----------|-------|----------|
| `secure: true` en cookies | HTTP localhost no acepta cookies secure | `secure: import.meta.env.PROD` |
| WebSocket no disponible | Node 20 sin WebSocket nativo | Polyfill con `ws` via `createRequire` |
| Error esbuild "componentes" | Texto en comentario confundía a esbuild | `is:inline` en script + eliminar texto |
| RLS recursión infinita | Políticas que se llamaban a sí mismas | Función `obtener_rol()` SECURITY DEFINER |
| `esRolAutorizado is not defined` | Función borrada en edit anterior | Restaurar definición |
| Navegación solo a evaluador | Layout no mostraba enlaces según rol | Layout consulta rol y muestra enlaces |

---

## Configuración de Supabase Requerida

### 1. Migraciones SQL
Ejecutar en orden: `001 → 002 → 003 → 004`

### 2. Authentication → URL Configuration
| Campo | Valor |
|-------|-------|
| Site URL | `http://localhost:4321` |
| Redirect URLs | `http://localhost:4321` |

### 3. Authentication → Providers → Google
- Habilitar Google
- Client ID y Secret de Google Cloud Console

### 4. Variables de entorno (`.env`)
```bash
PUBLIC_SUPABASE_URL=https://snavhkdyowjmqojcqmqu.supabase.co
PUBLIC_SUPABASE_ANON_KEY=sb_publishable_hAKrPlVqWi_RNTvtAwMJ6g_fRczwCby
```

---

## Páginas y Rutas

| Ruta | Acceso | Descripción |
|------|--------|-------------|
| `/` | Público | Landing page con hero y ponderaciones |
| `/auth` | Público | Login con Google |
| `/auth/callback` | Público | Callback OAuth (no usado en flujo final) |
| `/evaluador` | Autenticado | Dashboard "Mis Evaluaciones" |
| `/evaluador/evaluar/[id]` | Autenticado | Formulario Likert modo enfoque |
| `/admin/dashboard` | Admin/Coord/Calidad | Panel con progreso y tabla docentes |
| `/admin/dashboard/docente/[id]` | Admin/Coord/Calidad | Detalle con radar + comentarios |
| `/api/auth/signout` | Público | Cerrar sesión |
| `/api/auth/guardar-sesion` | Público | Guardar tokens en cookies |
| `/api/evaluar` | Autenticado | POST: procesar evaluación |
| `/api/admin/refrescar-resultados` | Admin | Refrescar MV |

---

## Navegación por Rol

| Rol | Enlaces visibles en navbar |
|-----|---------------------------|
| `alumno` | Mis Evaluaciones \| Salir |
| `docente` | Mis Evaluaciones \| Salir |
| `tecnico` | Mis Evaluaciones \| Salir |
| `coordinador` | Mis Evaluaciones \| **Admin** \| Salir |
| `calidad` | Mis Evaluaciones \| **Admin** \| Salir |
| `admin` | Mis Evaluaciones \| **Admin** \| Salir |

---

## Para Ejecutar

```bash
# 1. Clonar e instalar
npm install

# 2. Configurar .env con credenciales de Supabase

# 3. Ejecutar migraciones en Supabase SQL Editor

# 4. Iniciar
npm run dev
# → http://localhost:4321
```
