# Blueprint Técnico: SED-360 v2

## 1. Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Validación | Zod | — |
| Gráficos | Chart.js (CDN) | — |
| Despliegue | Vercel | — |
| Seguridad DNS | Cloudflare WAF | — |

## 2. Autenticación

- **Google OAuth**: Login exclusivo con cuentas Google del dominio `@tecplayacar.edu.mx`
- **Flujo implícito**: Tokens en hash de URL → guardados en cookies via endpoint
- **Middleware**: Validación de dominio + autorización por rol en cada request
- **Roles**: `superadmin`, `coordinador`, `docente`, `estudiante` (ENUM en tabla `usuarios`)

## 3. Base de Datos (15+ tablas)

### Catálogo
- `cuatrimestres` — Periodos académicos (clave, fechas, activo, cerrado)
- `licenciaturas` — Carreras (clave, nombre, facultad)
- `docentes` — Profesores (nombre, email, num_empleado, licenciatura)
- `asignaturas` — Materias (clave, nombre, créditos)
- `grupos` — Grupos de clase (docente + asignatura + cuatrimestre)
- `estudiantes` — Alumnos (nombre, email, matrícula, licenciatura)
- `inscripciones` — Relación estudiante ↔ grupo (UNIQUE)

### Auth
- `usuarios` — Sincronizado con `auth.users` (id UUID, email, rol, entidad_id)

### Instrumentos (5)
- `encuesta_estudiantil_respuestas` — EE: calidad_general (1-6) + 18 ítems Likert (1-4), ANÓNIMA
- `encuesta_control_envio` — Control de envío (estudiante_id, grupo_id, UNIQUE)
- `evaluacion_coordinacion` — CA: 0-75 puntos, 6 dimensiones, score_normalizado GENERATED
- `evaluacion_planeacion` — PD: 11 criterios 0-2, puntos_totales GENERATED
- `observacion_clase` — OC: 0-10 puntos, 5 dimensiones, score_normalizado GENERATED
- `autoevaluacion_docente` — AE: 10 ítems 1-3, score_normalizado GENERATED

### Resultados
- `calificacion_final_docente` — 5 scores individuales + calificación_final GENERATED + categoría

## 4. Seguridad (RLS)

Todas las tablas tienen Row Level Security con políticas granulares por rol. Helper `rol_usuario(uid)` para consultas centralizadas. Ver `supabase/migrations/002_rls_v2.sql`.
