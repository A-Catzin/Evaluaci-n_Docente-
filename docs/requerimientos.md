# Blueprint Técnico: SED-360 v2

## 1. Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Storage | Supabase Storage (bucket `planeaciones`) | — |
| Validación | Zod | — |
| Gráficos | Chart.js (CDN) | — |
| Despliegue | Vercel | — |
| Seguridad DNS | Cloudflare WAF | — |

## 2. Autenticación

- **Google OAuth**: Login exclusivo con cuentas Google del dominio `@tecplayacar.edu.mx`
- **Flujo implícito**: Tokens en hash de URL → guardados en cookies via endpoint
- **Middleware**: Validación de dominio + autorización por rol en cada request
- **Roles**: `superadmin`, `coordinador`, `docente`, `estudiante` (ENUM en tabla `usuarios`)

## 3. Base de Datos (20+ tablas)

### Catálogo
- `cuatrimestres` — Periodos académicos (clave, fechas, activo, cerrado)
- `licenciaturas` — Carreras (clave, nombre, facultad)
- `ofertas_academicas` — Catálogo de carreras (normalizado)
- `campus` — Campus institucionales (normalizado)
- `turnos` — Turnos académicos (normalizado)
- `docentes` — Profesores (nombre, email, num_empleado, campus, turno, oferta, apellidos separados)
- `asignaturas` — Materias (clave, nombre, créditos, ligadas a oferta_academica_id)
- `grupos` — Grupos de clase (docente + asignatura + cuatrimestre)
- `estudiantes` — Alumnos (nombre, email, matrícula, licenciatura)
- `inscripciones` — Relación estudiante ↔ grupo (UNIQUE)

### Auth
- `usuarios` — Sincronizado con `auth.users` (id UUID, email, rol, entidad_id)

### Evaluaciones
- `autodiagnosticos` — Auto-evaluación docente: 24 reactivos Likert 1-5
- `observaciones` — Observación de clase: 43 reactivos en 8 secciones (A-H)
- `planeaciones` — Gestión de planeaciones: subida PDF + rúbrica coordinador 4 criterios
- `encuesta_estudiantil_respuestas` — EE: calidad_general (1-6) + 18 ítems Likert (1-4), ANÓNIMA
- `encuesta_control_envio` — Control de envío (estudiante_id, grupo_id, UNIQUE)
- `evaluacion_coordinacion` — CA: 0-75 puntos, 6 dimensiones
- `evaluacion_planeacion` — PD: 11 criterios 0-2, puntos_totales GENERATED
- `observacion_clase` — OC: 0-10 puntos, 5 dimensiones
- `autoevaluacion_docente` — AE: 10 ítems 1-3

### Resultados
- `calificacion_final_docente` — 5 scores individuales + calificación_final GENERATED + categoría

## 4. Supabase Storage

| Bucket | Uso | Tamaño máx/archivo |
|--------|-----|-------------------|
| `planeaciones` | PDFs de planeaciones docentes | 5 MB |

- Subida directa del navegador a Supabase (sin pasar por Vercel)
- Archivos organizados por: `{cuatrimestre_id}/{docente_id}/{archivo}.pdf`
- Limpieza automática al cerrar cuatrimestre
