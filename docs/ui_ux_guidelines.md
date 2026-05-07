# Guía de Estilo UI/UX - Sistema de Evaluación Docente (SED)

Este documento define la interfaz enfocada exclusivamente en el flujo de evaluación. La premisa es: "Menos administración, más acción".

## 1. Concepto Visual: "Modern Institutional"
Para evitar la apariencia sobria y vacía de los sistemas tradicionales, utilizaremos:
* **Capas de Color:** Fondos con gradientes sutiles en lugar de blanco sólido (`bg-slate-50`).
* **Geometría Orgánica:** Uso de formas circulares o poligonales con opacidad baja (2-5%) situadas estratégicamente en los fondos para dar profundidad.
* **Tarjetas con Elevación:** Los elementos interactivos usarán sombras proyectadas para "flotar" sobre el fondo.

## 2. Paleta de Colores (Tailwind CSS)

| Aplicación | Clase Tailwind | Color Hex |
| :--- | :--- | :--- |
| **Primario (TecNM)** | `bg-[#1B396A]` | #1B396A |
| **Acento Acción** | `bg-blue-600` | #2563EB |
| **Fondo Dinámico** | `from-slate-50 to-blue-50` | Gradiente |
| **Estado Pendiente** | `text-amber-600` | #D97706 |
| **Estado Listo** | `text-emerald-600` | #059669 |

## 3. El Dashboard del Alumno: "Misión del Día"
El centro de la pantalla no será un calendario, sino un contenedor dinámico con las evaluaciones pendientes.

### A. Sección de Bienvenida (Hero)
* **Diseño:** Un bloque con gradiente azul institucional y esquinas muy redondeadas (`rounded-3xl`).
* **Contenido:** Un saludo breve y un contador visual de avance (Ej: "Tienes 3 de 5 evaluaciones completadas").
* **Visual:** Un gráfico circular de progreso a la derecha para romper la linealidad del texto.

### B. Grid de Docentes a Evaluar
En lugar de una tabla, usaremos tarjetas (`Cards`) interactivas:
* **Estructura:** Foto del docente (u avatar con iniciales), nombre completo y nombre de la asignatura.
* **Acción:** Un botón grande y claro de "Iniciar Evaluación".
* **Feedback Visual:** Si ya fue evaluado, la tarjeta se vuelve ligeramente traslúcida y muestra un check verde, bloqueando el acceso para cumplir la regla de **Voto Único**.

## 4. El Formulario de Evaluación (Interfaz de Captura)
Para que el alumno no se fatigue con las preguntas Likert:
* **Modo Enfoque:** Al evaluar a un docente, se oculta el resto de la interfaz (Navbar/Footer) para evitar distracciones.
* **Preguntas en Bloques:** Las preguntas aparecen en contenedores blancos con bordes suaves y una sombra sutil (`shadow-lg`).
* **Escala Visual:** Los números del 1 al 5 no son solo radios, son botones grandes. Al seleccionar uno, se ilumina con el azul de acento.

## 5. Elementos para "Romper la Sobriedad"
* **Micro-animaciones:** Al pasar el mouse sobre un docente, la tarjeta debe escalar suavemente (`hover:scale-105 transition-all`).
* **Fondos con Patrones:** Se puede añadir un patrón de líneas diagonales o puntos muy tenue al fondo del dashboard para que no se sienta "una hoja en blanco".
* **Glassmorphism:** En dispositivos desktop, los modales de confirmación pueden tener un efecto de desenfoque de fondo (`backdrop-blur-md`).

## 6. Accesibilidad y Estándares
* **Mobile-First:** La mayoría de los alumnos evaluarán desde su celular; los botones deben tener un tamaño mínimo de 44px para ser pulsables fácilmente.
* **Contraste:** El texto de las preguntas debe ser gris oscuro (`text-slate-800`), nunca gris claro, para asegurar legibilidad.