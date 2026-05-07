# Estándar de Documentación y Codificación - SED

Este documento define las reglas que la IA debe seguir al generar código, explicaciones o nueva documentación para el Sistema de Evaluación Docente (SED).

## 1. Estándar de Código (Clean Code)
* **Lenguaje:** Todo el código (variables, funciones, clases) debe escribirse en **Español**. Los comentarios de explicación deben ser en **Español**.
* **Naming Convention:** * Variables/Funciones: `camelCase`
    * Componentes (Astro/React): `PascalCase`
    * Tablas SQL: `snake_case` (en plural).
* **Tipado:** Es obligatorio el uso de **TypeScript** con tipado estricto (evitar el uso de `any`).

## 2. Estándar de Documentación Técnica (Markdown)
Cada vez que se genere un nuevo módulo o funcionalidad, la IA debe incluir:
1. **Descripción:** Qué hace el módulo.
2. **Endpoint/Tabla:** Qué recursos de Supabase utiliza.
3. **Snippet de Código:** El bloque de código funcional.
4. **Validaciones:** Qué medidas de seguridad o reglas de negocio se están aplicando.

## 3. Manejo de Errores y Seguridad
* **Logs:** No exponer errores internos de la base de datos al usuario final. Usar mensajes genéricos y loguear el error real en consola.
* **Supabase RLS:** Todo script de creación de tabla debe venir acompañado de su política de seguridad (Row Level Security).
* **Privacidad:** Recordar siempre el anonimato del `alumno_id` en las consultas de resultados.

## 4. Estilo de Componentes (Tailwind CSS)
* Los componentes deben ser **Mobile-First**.
* Usar la paleta de colores institucional (Sugerencia: Azules y Blancos para el TecNM).
* Accesibilidad: Asegurar contraste de texto y etiquetas `aria-label` en los formularios Likert.

## 5. Formato de Respuestas de la IA
Cuando se le pida a la IA generar documentación de una nueva función, debe usar esta estructura:
> ### [Nombre de la Función/Módulo]
> **Propósito:** ...
> **Archivos afectados:** `src/components/...` | `supabase/migrations/...`
> **Lógica clave:** Explicación del algoritmo de ponderación o validación usado.