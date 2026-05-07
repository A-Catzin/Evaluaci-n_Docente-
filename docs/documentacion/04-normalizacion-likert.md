# 04 — Normalización Likert

## Propósito

Implementar las funciones matemáticas puras que convierten respuestas de escala Likert (1-5) a porcentajes base 100, permitiendo combinar evaluaciones de distintos actores en el algoritmo de ponderación 360°.

## Archivos afectados

- `src/utils/normalizacion.ts`

## Funciones

### `normalizarLikertAPorcentaje(valorObtenido, valorMaximo?)`
```typescript
function normalizarLikertAPorcentaje(
  valorObtenido: number,
  valorMaximo?: number
): number
```

**Propósito**: Convierte un valor individual de la escala Likert a un porcentaje en base 100.

**Fórmula institucional** (definida en `docs/architecture_patterns.md`):
```
Resultado = ((Valor_obtenido - 1) / (Valor_max - 1)) * 100
```

**Ejemplos**:
| Entrada | Fórmula | Resultado |
|---------|---------|-----------|
| 5 (Totalmente de acuerdo) | `((5-1)/(5-1))*100` | 100% |
| 4 (De acuerdo) | `((4-1)/(5-1))*100` | 75% |
| 3 (Neutral) | `((3-1)/(5-1))*100` | 50% |
| 2 (En desacuerdo) | `((2-1)/(5-1))*100` | 25% |
| 1 (Totalmente en desacuerdo) | `((1-1)/(5-1))*100` | 0% |

**Validación**: Lanza `Error` si el valor está fuera del rango `[1, valorMaximo]`.

### `esValorLikert(valor)`
```typescript
function esValorLikert(valor: number): valor is ValorLikert
```

**Propósito**: Type guard que verifica si un número es un valor Likert válido (entero entre 1 y 5). Útil para validación antes de normalizar.

### `calcularPromedioNormalizado(respuestas)`
```typescript
function calcularPromedioNormalizado(respuestas: ValorLikert[]): number
```

**Propósito**: Calcula el promedio de un conjunto de respuestas Likert, normalizando cada una individualmente antes de promediar.

**Lógica clave**: 
1. Normaliza cada respuesta individual a porcentaje
2. Suma todos los porcentajes
3. Divide por la cantidad de respuestas
4. Si el array está vacío, retorna 0

**Ejemplo**: `[4, 5, 3, 4, 5]` → `(75 + 100 + 50 + 75 + 100) / 5 = 80%`

### `calcularPuntajeGlobal(promedios, ponderaciones)`
```typescript
function calcularPuntajeGlobal(
  promedios: Partial<Record<string, number>>,
  ponderaciones: Record<string, number>
): number
```

**Propósito**: Aplica las ponderaciones 360° a los promedios normalizados de cada actor para obtener el Puntaje Global del docente.

**Lógica clave**:
1. Itera sobre cada actor definido en las ponderaciones
2. Multiplica el promedio del actor por su peso
3. Acumula los resultados
4. Si algún actor no ha evaluado aún (promedio `undefined`), su peso se excluye y el total se normaliza proporcionalmente
5. Si ningún actor evaluó, retorna 0

**Ejemplo**:
```
PROMEDIOS: { ALUMNO: 80, TECNICO: 75, COORDINADOR: 90, CALIDAD: 85, AUTO: 70 }
PESOS:     { ALUMNO: 0.35, TECNICO: 0.25, COORDINADOR: 0.20, CALIDAD: 0.15, AUTO: 0.05 }

= (80*0.35) + (75*0.25) + (90*0.20) + (85*0.15) + (70*0.05)
= 28 + 18.75 + 18 + 12.75 + 3.5
= 81.0%
```

## Restricciones

- **Funciones puras**: No dependen de ninguna API externa ni base de datos. Son deterministicas.
- **Sin efectos secundarios**: No modifican estado global. Reciben input, retornan output.
- **Validación estricta**: `normalizarLikertAPorcentaje` lanza error para valores fuera de rango, forzando al llamador a manejar datos inválidos temprano.

## Dependencias

- `src/types/supabase.ts` — solo para el tipo `ValorLikert` (type guard)
