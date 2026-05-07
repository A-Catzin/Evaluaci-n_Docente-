# 07 — Middleware de Dominio

## Propósito

Implementar la política de **"Dominio Cerrado"** definida en `docs/requerimientos.md`. Cada request a una ruta protegida es interceptado para verificar que el usuario tenga una sesión activa de Supabase y que su email pertenezca al dominio institucional `@tecplayacar.edu.mx`. Si no cumple, la sesión se destruye y se redirige al login.

## Archivos afectados

- `src/middleware.ts`

## Flujo de ejecución

```
Request entrante
    │
    ├── ¿Es ruta pública? (/auth, /, /api/auth/*, favicon)
    │       └── Sí → next() (sin validación)
    │
    ├── ¿Hay cookies sb-access-token y sb-refresh-token?
    │       └── No → redirect(/auth)
    │
    ├── ¿Supabase valida la sesión con los tokens?
    │       └── Error → limpiar cookies → redirect(/auth)
    │
    ├── ¿El email termina en @tecplayacar.edu.mx?
    │       ├── Sí → next()
    │       └── No  → signOut() → limpiar cookies → redirect(/auth)
```

## Funciones internas

### `esRutaPublica(pathname)`
```typescript
function esRutaPublica(pathname: string): boolean
```

**Propósito**: Determina si una ruta está exenta de validación de dominio.

**Rutas públicas**:
| Ruta | Motivo |
|------|--------|
| `/` | Landing page institucional |
| `/auth` | Página de login |
| `/api/auth/callback` | Callback OAuth de Supabase |
| `/api/auth/signout` | Endpoint de cierre de sesión |
| `/favicon.ico`, `/favicon.svg` | Recursos estáticos |

### `redirigirAlLogin(cookies, redirect)`
```typescript
function redirigirAlLogin(cookies, redirect): Response
```

**Propósito**: Limpia las cookies de sesión de Supabase y redirige al login.

**Cookies eliminadas**: `sb-access-token`, `sb-refresh-token`

## Restricciones de negocio

| Regla | Implementación |
|-------|---------------|
| **Dominio cerrado** | Validación `email.endsWith('@tecplayacar.edu.mx')` en cada request |
| **Sesión forzada** | Sin cookies de Supabase → redirect inmediato, sin excepciones |
| **Cierre automático** | Si el dominio no coincide, se llama a `supabase.auth.signOut()` para invalidar la sesión también en el servidor |
| **Logs de auditoría** | Cada acceso denegado se registra en consola con el email rechazado |

## Seguridad

- **Doble barrera**: La validación de dominio se aplica tanto en Supabase (Allowed Email Domains en Google Auth) como en el middleware de Astro. Si un administrador cambiara la config de Supabase, el middleware sigue protegiendo.
- **Sin información expuesta**: El usuario solo ve la redirección al login, nunca sabe por qué fue rechazado (no se expone el motivo en la UI).
- **Cookies limpiadas**: Al detectar una sesión inválida, se eliminan las cookies para evitar que el navegador las reenvíe.

## Dependencias

- `src/lib/supabaseClient.ts` — `obtenerClienteSuperbase()` para verificar sesión
- `astro:middleware` — `defineMiddleware` de Astro 4
