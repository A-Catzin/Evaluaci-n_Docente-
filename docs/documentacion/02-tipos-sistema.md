# 02 — Tipos del Sistema

## Propósito

Definir las interfaces TypeScript que reflejan fielmente el esquema SQL de Supabase. Centraliza las constantes del dominio de negocio (ponderaciones 360°, etiquetas Likert, etiquetas de actores) para que todo el sistema hable el mismo lenguaje de tipos.

## Archivos afectados

- `src/types/supabase.ts`

## Interfaces

### `Usuario`
```typescript
interface Usuario {
  id: string;        // UUID → auth.users
  email: string;
  rol: RolUsuario;   // 'alumno' | 'docente' | 'coordinador' | 'tecnico' | 'calidad' | 'admin'
}
```

### `CargaAcademica`
```typescript
interface CargaAcademica {
  id_carga: number;    // SERIAL
  id_docente: string;  // UUID → usuarios.id
  id_materia: string;
  id_periodo: string;  // Ej: "2025-1"
}
```

### `Evaluacion`
```typescript
interface Evaluacion {
  id_evaluacion: number;       // SERIAL
  id_evaluador: string;        // UUID → usuarios.id
  id_carga: number;            // → cargas_academicas.id_carga
  tipo_actor: TipoActor;       // 'ALUMNO' | 'COORDINADOR' | 'TECNICO' | 'CALIDAD' | 'AUTO'
  puntaje_promedio: number;    // DECIMAL(5,2)
  comentario: string | null;
  marcado_inapropiado: boolean;
  fecha_creacion: string;      // TIMESTAMP
}
```

## Constantes de dominio

### `PONDERACION_360`
Pesos del algoritmo 360° definidos por el manual institucional:

| Actor | Peso | Etiqueta |
|-------|------|----------|
| `ALUMNO` | 0.35 | Evaluación Estudiantil |
| `TECNICO` | 0.25 | Observación de Clase |
| `COORDINADOR` | 0.20 | Evaluación por Coordinación |
| `CALIDAD` | 0.15 | Evaluación de Planeación |
| `AUTO` | 0.05 | Autoevaluación |

### `ETIQUETAS_LIKERT`
```typescript
const ETIQUETAS_LIKERT = {
  1: 'Totalmente en desacuerdo',
  2: 'En desacuerdo',
  3: 'Neutral',
  4: 'De acuerdo',
  5: 'Totalmente de acuerdo',
};
```

### `PESOS_TOTALES`
Variable computada que verifica que la suma de ponderaciones sea 1.0 (100%). Si no suma exactamente 1.0, hay un error en la definición de constantes.

## Restricciones

- **Prohibido `any`**: Todos los tipos son explícitos. No se permite el uso de `any` en ninguna parte del sistema.
- **TipoActor en mayúsculas**: Los valores del enum `TipoActor` coinciden exactamente con el `CHECK` constraint SQL (`'ALUMNO'`, `'COORDINADOR'`, etc.) para evitar errores de mapeo.
- **Inmutabilidad**: `PONDERACION_360` se declara con `as const` para que TypeScript infiera tipos literales, no `number` genérico.

## Lógica clave

El archivo actúa como **Single Source of Truth** para los tipos del dominio. Cualquier cambio en el esquema SQL debe reflejarse primero aquí. Las constantes de ponderación son consumidas por `src/utils/normalizacion.ts` para el cálculo del puntaje global.
