# 05 — Servicio de Evaluaciones

## Propósito

Implementar el patrón **Service Layer** para todas las operaciones contra la tabla `evaluaciones` de Supabase. Desacopla la lógica de acceso a datos de los componentes UI, permitiendo cambiar la base de datos o la lógica de negocio en un solo lugar.

## Archivos afectados

- `src/services/evaluaciones.ts`

## Funciones

### `enviarEvaluacion(evaluacion)`
```typescript
async function enviarEvaluacion(evaluacion: {
  id_evaluador: string;
  id_carga: number;
  tipo_actor: TipoActor;
  puntaje_promedio: number;
  comentario?: string | null;
}): Promise<Evaluacion>
```

**Propósito**: Inserta una nueva evaluación en la base de datos.

**Lógica clave**:
1. Recibe los datos de evaluación validados previamente por Zod
2. Inserta en la tabla `evaluaciones` con `.insert().select().single()`
3. Si Supabase devuelve error `23505` (UNIQUE CONSTRAINT violation), lo traduce al mensaje amigable: *"Esta carga académica ya fue evaluada."*
4. Cualquier otro error se loguea en consola y se devuelve un mensaje genérico al usuario: *"Error al guardar la evaluación. Intente nuevamente."*

**Tabla Supabase**: `evaluaciones`

### `obtenerEvaluacionesPorUsuario(idEvaluador)`
```typescript
async function obtenerEvaluacionesPorUsuario(
  idEvaluador: string
): Promise<Evaluacion[]>
```

**Propósito**: Consulta todas las evaluaciones realizadas por un usuario específico. Útil para la vista "Mis Evaluaciones" del dashboard del evaluador.

**Lógica clave**:
- Filtra por `id_evaluador`
- Ordena por `fecha_creacion` descendente (más recientes primero)
- Respeta las políticas RLS: solo devuelve evaluaciones cuyo `id_evaluador` coincide con `auth.uid()`

**Tabla Supabase**: `evaluaciones`

### `obtenerEvaluacionesPorCarga(idCarga)`
```typescript
async function obtenerEvaluacionesPorCarga(
  idCarga: number
): Promise<Evaluacion[]>
```

**Propósito**: Consulta todas las evaluaciones asociadas a una carga académica. Para uso interno en reportes y agregaciones.

**⚠️ Advertencia de anonimato**: Esta función retorna el `id_evaluador` en los datos crudos. La capa de UI que consuma este resultado es **responsable de nunca exponer el `id_evaluador`** en la interfaz visible al docente. Los comentarios deben mostrarse mezclados, sin fechas y sin identificadores de grupo.

**Tabla Supabase**: `evaluaciones`

## Restricciones de negocio

| Regla | Implementación |
|-------|---------------|
| **Voto único** | El `CONSTRAINT unique_vote` en SQL lo garantiza. El servicio traduce el error a mensaje amigable. |
| **Anonimato** | El servicio retorna datos crudos. La responsabilidad de anonimizar recae en la capa de UI/features. |
| **No exponer errores SQL** | El error `23505` se traduce. Otros errores se loguean en consola pero se retorna mensaje genérico. |
| **Moderación** | El campo `marcado_inapropiado` es gestionado por un filtro externo (`src/features/moderacion/`). |

## Dependencias

- `src/lib/supabaseClient.ts` — cliente de Supabase
- `src/types/supabase.ts` — tipos `Evaluacion`, `TipoActor`
- Tabla Supabase: `evaluaciones`
