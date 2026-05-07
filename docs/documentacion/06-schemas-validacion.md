# 06 — Schemas de Validación (Zod)

## Propósito

Definir los esquemas de validación Zod que protegen todas las entradas al sistema. Garantiza que ningún dato inválido llegue a la base de datos, actuando como primera barrera de defensa antes del Service Layer.

## Archivos afectados

- `src/schemas/validacion.ts`

## Schemas

### `schemaValorLikert`
```typescript
const schemaValorLikert = z.number().int().min(1).max(5)
```

**Propósito**: Validar que un valor individual de escala Likert sea un entero entre 1 y 5.

**Mensajes de error**:
- `"El valor mínimo es 1"` — si es menor a 1
- `"El valor máximo es 5"` — si es mayor a 5

### `schemaEnvioEvaluacion`
```typescript
const schemaEnvioEvaluacion = z.object({
  id_evaluador: z.string().uuid(),
  id_carga: z.number().int().positive(),
  tipo_actor: z.enum(['ALUMNO', 'COORDINADOR', 'TECNICO', 'CALIDAD', 'AUTO']),
  respuestas: z.record(z.string(), schemaValorLikert).refine(obj => Object.keys(obj).length > 0),
  comentario: z.string().max(1000).nullable().optional(),
})
```

**Propósito**: Validar el payload completo de envío de una evaluación antes de insertarlo en la base de datos.

**Validaciones**:
| Campo | Regla | Error |
|-------|-------|-------|
| `id_evaluador` | UUID válido | "ID de evaluador inválido" |
| `id_carga` | Entero positivo | "ID de carga académica inválido" |
| `tipo_actor` | Enum estricto | Error de Zod por defecto |
| `respuestas` | Objeto con keys string y valores Likert, al menos 1 respuesta | "Debe incluir al menos una respuesta" |
| `comentario` | Opcional, máximo 1000 caracteres | "El comentario no puede exceder 1000 caracteres" |

### `schemaPeriodo`
```typescript
const schemaPeriodo = z.string().regex(/^\d{4}-\d{1,2}$/)
```

**Propósito**: Validar el formato de periodo académico (ej: `"2025-1"`, `"2025-12"`).

**Error**: `"Formato de periodo inválido. Use AAAA-N"`

### `schemaEmailInstitucional`
```typescript
const schemaEmailInstitucional = z.string().email().refine(email => email.endsWith('@tecplayacar.edu.mx'))
```

**Propósito**: Validar que un email pertenezca al dominio institucional.

**Validaciones**:
- `email()`: Formato de email RFC 5322
- `refine()`: El dominio debe ser `@tecplayacar.edu.mx`

## Restricciones

- **Validación temprana**: Los schemas Zod deben aplicarse en el boundary del sistema (API endpoints, server actions) antes de que los datos lleguen al Service Layer.
- **Mensajes en español**: Todos los mensajes de error están en español para alinearse con el lenguaje de dominio institucional.
- **Sin `any`**: El tipo inferido `EnvioEvaluacion` es estricto, sin `any`.

## Dependencias

- `zod` — librería de validación
- `src/types/supabase.ts` — solo para referencia de tipos (no importado directamente)
