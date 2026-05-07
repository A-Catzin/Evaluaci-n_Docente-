# Patrones de Arquitectura - SED

Este documento establece la estructura lógica y el flujo de datos para garantizar la separación de responsabilidades.

## 1. Estructura de Carpetas (Astro + Supabase)
* `/src/components/`: Componentes UI atómicos (Botones, Inputs, Cards).
* `/src/features/`: Lógica compleja agrupada por funcionalidad (ej. `evaluacion/`, `reportes/`).
* `/src/lib/`: Configuraciones de clientes (Supabase client, utilidades de formato).
* `/src/services/`: Capa de datos. Funciones puras de TypeScript que interactúan con Supabase.
* `/src/schemas/`: Definiciones de **Zod** para validar formularios y respuestas de la DB.

## 2. Flujo de Datos y Renderizado
* **SSR (Server Side Rendering):** Se usará para páginas que requieren autenticación y datos frescos (Dashboard, Listado de Materias).
* **Islas de Interactividad (React/Preact):** Los formularios de escala Likert serán componentes interactivos para mejorar la experiencia de usuario (UX).
* **Server Actions (Astro):** Para el envío de evaluaciones, procesando la lógica de negocio en el servidor para proteger la integridad del voto.

## 3. Patrón de Acceso a Datos (Service Layer)
No se llamará a `supabase.from()` directamente en los archivos `.astro`. 
* **Ejemplo:** Se crea `src/services/evaluaciones.ts` que exporta la función `enviarEvaluacion()`. Esto permite cambiar la lógica o la base de datos en un solo lugar.

## 4. Estrategia de Seguridad
* **Validación de Dominio:** Implementada en el `middleware.ts` de Astro.
* **Anonimato por Capas:** La base de datos guarda el `vinculacion_id`, pero el servicio de reportes solo consume una **Vista SQL** que ya viene anonimizada y agregada.