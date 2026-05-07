# Estándar de Documentación y Codificación - SED-360

Este documento dicta cómo el equipo de desarrollo o IA debe escribir código y documentarlo.

## 1. Estándar de Código (Clean Code)
* **Idioma:** Todo el código (variables, funciones), excepto por convenciones del framework, debe ser en **Español** para alinearse al lenguaje de dominio institucional.
* **Naming Convention:**
  * Variables/Funciones: `camelCase` (ej. `calcularPromedio`)
  * Componentes (Astro/React): `PascalCase` (ej. `TarjetaEvaluacion`)
  * Tablas SQL: `snake_case` (ej. `cargas_academicas`)
* **Tipado:** Es obligatorio el uso estricto de **TypeScript**. Queda prohibido el uso de `any`.

## 2. Formato de Documentación Interna
Cada módulo complejo debe llevar una cabecera en el archivo explicando:
1. **Propósito:** Qué problema de negocio resuelve.
2. **Dependencias:** Tablas de Supabase u otros servicios afectados.
3. **Restricciones:** Reglas de negocio (Ej: "Asegurar que se ejecute la validación de moderación de texto").

## 3. Manejo de Errores y Seguridad (RLS y Logs)
* **Privacidad (RLS):** Toda tabla en Supabase debe llevar su política `CREATE POLICY`. El Frontend jamás debe confiar en ocultar botones; la base de datos es la última barrera.
* **Mensajes de UI:** Nunca exponer errores técnicos al usuario (como un fallo SQL `UNIQUE CONSTRAINT`). Si el alumno intenta doble voto, el frontend captura el error del backend y muestra amablemente: *"Esta materia ya fue evaluada exitosamente."*

## 4. Estilos y Componentes
* Diseño **Mobile-First** obligatorio. La mayoría de los cuestionarios se responderán desde el smartphone de los alumnos.
* Inclusión de etiquetas `aria-label` en las escalas de Likert para cumplir con estándares de accesibilidad en la educación.