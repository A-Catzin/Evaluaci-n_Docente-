# Patrones de Arquitectura y Flujo de Datos - SED-360

Este documento establece la estructura lógica para separar responsabilidades y evitar cuellos de botella en la base de datos.

## 1. Patrón de Escalabilidad: "Separación de Escritura y Lectura"
Debido a que la evaluación estudiantil suele ocurrir de forma masiva en las últimas semanas del periodo:
* **Flujo de Captura (High-Write):** La aplicación cliente (Astro) se limita a hacer `INSERT` sobre la tabla `evaluaciones`. No hace cálculos pesados en el momento.
* **Flujo de Reporte (Low-Read):** Se utilizará una tabla secundaria consolidada (`resultados_agregados`). Esta se alimentará mediante un *Cron Job* nocturno o una *Materialized View* en PostgreSQL. Esto asegura que el Dashboard del Admin o Coordinador cargue en milisegundos sin calcular miles de filas en vivo.

## 2. Metodología Likert y Normalización a Base 100
Para poder sumar las respuestas de escala Likert (1 a 5) y combinarlas con porcentajes de rúbricas, aplicamos la fórmula de normalización matemática:

**Fórmula Institucional:** `Resultado = ((Valor_obtenido - 1) / (Valor_max - 1)) * 100`

**Implementación en Service Layer (TypeScript):**
```typescript
/**
 * Normaliza un valor de escala Likert (ej. 1-5) a un porcentaje (0-100).
 * Ej: Un voto de 4 (De acuerdo) en escala de 5 -> ((4-1)/(5-1))*100 = 75%
 */
export const normalizarLikert = (valorObtenido: number, valorMaximo: number = 5): number => {
    if (valorObtenido < 1 || valorObtenido > valorMaximo) {
        throw new Error("Valor fuera del rango Likert permitido");
    }
    return ((valorObtenido - 1) / (valorMaximo - 1)) * 100;
};