# 01 — Esquema Core SQL

## Propósito

Crear la estructura base de la base de datos SED-360 con las tres tablas fundamentales del sistema: `usuarios`, `cargas_academicas` y `evaluaciones`. Implementa las políticas de Row Level Security (RLS) para que la base de datos sea la última barrera de protección, no la interfaz.

## Archivos afectados

- `supabase/migrations/001_esquema_core.sql`

## Tablas

### `usuarios`
Sincronizada con `auth.users` de Supabase. Almacena el rol del usuario en el sistema.

| Columna | Tipo | Restricción |
|---------|------|------------|
| `id` | UUID | PK, FK → auth.users |
| `email` | TEXT | UNIQUE, NOT NULL |
| `rol` | VARCHAR(50) | CHECK IN ('alumno','docente','coordinador','tecnico','calidad','admin') |

### `cargas_academicas`
Nexo central que relaciona un docente con una materia en un periodo específico.

| Columna | Tipo | Restricción |
|---------|------|------------|
| `id_carga` | SERIAL | PK |
| `id_docente` | UUID | FK → usuarios.id |
| `id_materia` | TEXT | NOT NULL |
| `id_periodo` | TEXT | NOT NULL |
| — | — | UNIQUE(id_docente, id_materia, id_periodo) |

### `evaluaciones`
Captura de evaluaciones normalizada. Cada fila representa la evaluación de un actor sobre una carga académica.

| Columna | Tipo | Restricción |
|---------|------|------------|
| `id_evaluacion` | SERIAL | PK |
| `id_evaluador` | UUID | FK → usuarios.id |
| `id_carga` | INT | FK → cargas_academicas.id_carga |
| `tipo_actor` | VARCHAR(20) | CHECK IN ('ALUMNO','COORDINADOR','TECNICO','CALIDAD','AUTO') |
| `puntaje_promedio` | DECIMAL(5,2) | — |
| `comentario` | TEXT | — |
| `marcado_inapropiado` | BOOLEAN | DEFAULT FALSE |
| `fecha_creacion` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| — | — | **CONSTRAINT unique_vote** UNIQUE(id_evaluador, id_carga, tipo_actor) |

## Políticas RLS

| Tabla | Política | Operación | Condición |
|-------|----------|-----------|-----------|
| `usuarios` | Leer perfil propio | SELECT | `auth.uid() = id` |
| `usuarios` | Admin gestiona | ALL | `rol = 'admin'` |
| `cargas_academicas` | Lectura autenticados | SELECT | `auth.uid() IS NOT NULL` |
| `cargas_academicas` | Admin gestiona | ALL | `rol = 'admin'` |
| `evaluaciones` | Insertar propia | INSERT | `auth.uid() = id_evaluador` |
| `evaluaciones` | Leer propias | SELECT | `auth.uid() = id_evaluador` |
| `evaluaciones` | Admin/Coord leen todas | SELECT | `rol IN ('admin','coordinador','calidad')` |

## Restricciones de negocio aplicadas

- **Voto único**: El `CONSTRAINT unique_vote` impide que un mismo evaluador envíe dos evaluaciones del mismo tipo sobre la misma carga académica. El error SQL `23505` es capturado por el service layer y traducido a un mensaje amigable: *"Esta carga académica ya fue evaluada."*
- **Anonimato**: La política RLS de `evaluaciones` permite que admin/coordinador lean todas las evaluaciones para generar reportes, pero la capa de UI es responsable de nunca exponer `id_evaluador` en los resultados visibles al docente.
- **Dominio cerrado**: No se aplica a nivel SQL (se gestiona en el middleware de Astro y en la configuración de Google Auth de Supabase).

## Índices

| Índice | Columna | Propósito |
|--------|---------|-----------|
| `idx_evaluaciones_id_carga` | `id_carga` | Optimizar agregaciones por carga |
| `idx_evaluaciones_tipo_actor` | `tipo_actor` | Optimizar filtros por tipo de evaluador |
| `idx_evaluaciones_fecha` | `fecha_creacion` | Optimizar ordenamiento cronológico |

## Lógica clave

La migración está diseñada para ser **idempotente** (`CREATE TABLE IF NOT EXISTS`). El orden de creación respeta las dependencias: primero `usuarios` (referenciado por ambas tablas), luego `cargas_academicas`, finalmente `evaluaciones` (que referencia a las dos anteriores).
