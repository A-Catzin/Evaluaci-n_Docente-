# Guía de Estilo UI/UX - SED-360

Este documento define la interfaz enfocada en reducir la fatiga cognitiva y evitar distracciones durante la evaluación.

## 1. Concepto Visual: "Modern Institutional"
* **Capas de Color:** Fondos con gradientes sutiles (`bg-slate-50`).
* **Geometría Orgánica:** Uso de formas circulares con opacidad baja situadas estratégicamente en fondos.
* **Tarjetas con Elevación:** Elementos interactivos usarán sombras proyectadas (`shadow-lg`).

## 2. Paleta de Colores (Tailwind)

| Aplicación | Clase Tailwind | Color Hex |
| :--- | :--- | :--- |
| **Primario (Institucional)** | `bg-[#1B396A]` | #1B396A |
| **Acento / Acción** | `bg-blue-600` | #2563EB |
| **Fondo Dinámico** | `from-slate-50 to-blue-50` | Gradiente |
| **Pendiente** | `text-amber-600` | #D97706 |
| **Completado** | `text-emerald-600` | #059669 |

## 3. El Flujo de Evaluación Estudiantil: "Misión del Día"
* **Dashboard Central:** Muestra contenedores dinámicos con los docentes pendientes de evaluar. 
* **Prevención de Fraude Visual:** Una evaluación completada se vuelve translúcida y muestra un icono verde. Si el usuario intenta hacer clic, el UI denegará la acción, en sintonía con la regla de Voto Único.
* **Modo Enfoque:** Dentro del formulario, desaparece el menú lateral y footer. El estudiante debe centrarse 100% en el Likert.

## 4. El Cuestionario y Escala Visual
* **Bloques Táctiles:** Adiós a los 'radio buttons' minúsculos. Usaremos botones tipo bloque (mínimo 44x44px) para ser táctiles en móviles.
* **Interactividad:** Al seleccionar una opción del 1 al 5, el bloque debe iluminarse con el color de acento (`bg-blue-600 text-white transition-colors`).

## 5. Tableros para Docentes y Coordinadores
* **Gráficos Spider/Radar:** Para visualizar la brecha entre la autoevaluación, el alumno y el coordinador, la UI empleará gráficos tipo Radar.
* **Muro de Comentarios:** Los comentarios se presentarán como tarjetas asíncronas para fortalecer la regla de *Anonimato Estricto*. No llevarán fecha, hora ni ID visual del grupo.