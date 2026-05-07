# 03 — Cliente de Supabase

## Propósito

Proveer una interfaz unificada para la conexión con Supabase desde el servidor (SSR). Implementa inicialización perezosa (lazy) para evitar errores durante el build de Astro cuando las variables de entorno no están disponibles.

## Archivos afectados

- `src/lib/supabaseClient.ts`

## Funciones

### `obtenerClienteSuperbase()`
```typescript
function obtenerClienteSuperbase(): SupabaseClient
```

**Propósito**: Devuelve una instancia singleton del cliente de Supabase. La primera llamada inicializa el cliente; las subsecuentes retornan la misma instancia.

**Lógica clave**: Lazy initialization. El cliente no se crea en el top-level del módulo porque Astro ejecuta los imports durante el build, y en ese momento las variables de entorno (`PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY`) pueden no estar definidas. Al diferir la inicialización a la primera llamada, evitamos crashes en build.

**Configuración**:
- `persistSession: false` — El servidor no persiste sesiones en storage.
- `autoRefreshToken: false` — La renovación de tokens se maneja explícitamente.

### `crearClienteConSesion(tokenAcceso)`
```typescript
function crearClienteConSesion(tokenAcceso: string): SupabaseClient
```

**Propósito**: Crea un cliente de Supabase contextualizado con el token de acceso de un usuario específico. Útil para operaciones que requieren el contexto RLS del usuario autenticado.

**Lógica clave**: Inyecta el token JWT en el header `Authorization: Bearer {token}`. Esto permite que las políticas RLS de Supabase evalúen `auth.uid()` correctamente para el usuario correspondiente.

## Variables de entorno requeridas

| Variable | Descripción |
|----------|-------------|
| `PUBLIC_SUPABASE_URL` | URL del proyecto Supabase (ej: `https://abc123.supabase.co`) |
| `PUBLIC_SUPABASE_ANON_KEY` | Clave anónima (pública) de Supabase |

## Restricciones

- **Sin SERVICE_ROLE en cliente**: Este cliente usa exclusivamente la clave anónima. La `SERVICE_ROLE_KEY` solo debe usarse en migraciones o seed scripts, nunca en código accesible desde el frontend.
- **Sin sesión persistente en servidor**: `persistSession: false` evita que el servidor intente escribir cookies o localStorage, lo cual no tiene sentido en SSR.

## Dependencias

- `@supabase/supabase-js` v2
- Variables de entorno de Astro (`import.meta.env`)
