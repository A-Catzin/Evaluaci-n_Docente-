# Especificaciones Técnicas: Clonación de Formulario de Autodiagnóstico Docente 26-3

Este documento contiene la estructura completa, textos íntegros y lógica de negocio para la implementación del formulario en la aplicación.

## 1. Configuración General
* **Título:** Tecnológico Universitario Región Sureste "Auto Evaluación Docente" 26-3
* **Páginas:** 4 secciones con navegación (Siguiente/Atrás).
* **Validación:** Todos los campos son obligatorios excepto "Comentarios".

---

## 2. Estructura por Páginas

### Página 1: Identificación
**Texto de Introducción:**
Estimado Docente:
La Autoevaluación de Competencias Docentes es un instrumento que forma parte del Sistema Institucional de Evaluación del Desempeño Docente 360°, cuya finalidad es promover la reflexión crítica y consciente del docente sobre su propio desempeño profesional.
A través de este ejercicio, el docente tiene la oportunidad de identificar sus fortalezas, reconocer áreas de mejora y reflexionar sobre acciones formativas que contribuyan al fortalecimiento de su práctica educativa, en coherencia con el Modelo Educativo institucional y los principios de mejora continua.
La aplicación de la Autoevaluación Docente tiene una duración aproximada de entre 5 y 7 minutos, lo que permite una participación ágil, accesible y enfocada en la reflexión personal.
Es importante destacar que los resultados obtenidos no tienen un carácter punitivo, sino formativo, y se integran como una de las múltiples perspectivas que conforman el Sistema de Evaluación 360°, contribuyendo a una valoración integral, objetiva y orientada al desarrollo profesional docente.
Para quienes ya realizaron este ejercicio en el ciclo 26-2, se les invita a generar un breve espacio de reflexión, retomando su autodiagnóstico previo, con el fin de identificar avances, áreas de mejora atendidas y acciones implementadas en su práctica docente.
Para quienes lo realizan por primera vez en este ciclo 26-3, este instrumento les servirá como un punto de partida para la reflexión y el fortalecimiento de su desempeño docente.
Agradecemos su participación y compromiso con el fortalecimiento de la calidad educativa institucional.

**Campos:**
* **Nombre (s):** [Input Texto Corto]
* **Apellido Paterno:** [Input Texto Corto]
* **Apellido Materno:** [Input Texto Corto]
* **Campus asignado (según contrato):** [Radio Button]
    * Tecnológico Universitario Tuxtla
    * Tecnológico Universitario Playacar / Facultad de Ciencias de la Salud

### Página 2: Datos Académicos
* **Oferta académica:** [Checkboxes]
    (Arquitectura, Administración de Empresas, Administración de Empresas Turísticas, Mercadotecnia, Sistemas Computacionales, Enfermería, Nutrición, Contaduría, Derecho, Pedagogía, Criminología, Comercio Internacional, Diseño Grafico Digital, Ingles, Otros).
* **Turno:** [Checkboxes]
    (Matutino, Vespertino, Mixto, Virtual).

### Página 3: Evaluación (Escala Likert)
**Instrucción:** Seleccione la más acorde al caso.
**Escala de puntos:**
* (5) Siempre: Más del 90%
* (4) Casi siempre: 70% - 89%
* (3) Algunas veces: 50% - 69%
* (2) Pocas veces: 20% - 49%
* (1) Nunca: Menos del 20%

**Reactivos:**
1. Domino los conceptos para la construcción del aprendizaje en los cursos o programas académicos que imparto.
2. Expongo, organizó, desarrollo y vinculó los contenidos en forma clara.
3. Adapto los contenidos a los diversos estilos y necesidades de los estudiantes.
4. Organizó espacios de reflexión antes, durante y después de las actividades de aprendizaje.
5. Incluyó actividades en clase que promueven el aprendizaje autónomo en los estudiantes.
6. Propongo ejercicios para promover la metacognición en su ambiente de aprendizaje (parafrasear, recapitular lo hecho, etc.).
7. Propongo nuevas estrategias para mejorar los resultados obtenidos en el desempeño de los estudiantes.
8. Me comunico con claridad y precisión.
9. Escucho activamente a mis estudiantes.
10. Fomento la participación y el diálogo respetuoso.
11. Mantengo un trato respetuoso con mis estudiantes.
12. Atiendo situaciones grupales con sensibilidad y objetividad.
13. Organizo los objetivos y contenidos de manera coherente con el modelo educativo de la institución y las particularidades de sus estudiantes.
14. Implemento diversas estrategias para inducir el aprendizaje significativo (colaborativo, basado en proyectos, análisis de caso, basado en problemas, etc.).
15. Considero saberes previos, intereses y experiencias de sus estudiantes.
16. Género oportunidades de desarrollo del pensamiento crítico y creativo.
17. Motivo al aprendizaje, la indagación y la búsqueda de conocimiento.
18. Ofrezco retroalimentación oportuna, pertinente y cálida a los estudiantes.
19. Promuevo un ambiente de confianza y respeto.
20. Manejo mis emociones de forma profesional en clase.
21. Utilizo herramientas tecnológicas para enriquecer mi enseñanza.
22. Integro recursos digitales de forma adecuada a los contenidos.
23. Conozco y aplico la normatividad institucional.
24. Respeto el reglamento y lineamientos académicos.

### Página 4: Cierre y Comentarios
**Texto final:** Agradecemos sinceramente el tiempo y la disposición que han dedicado al llenado del Autodiagnóstico Docente. Su participación refleja el compromiso con la reflexión profesional, la mejora continua y el fortalecimiento de la calidad educativa.

La información compartida será de gran valor para orientar acciones de acompañamiento académico y consolidar procesos que impulsen la excelencia en la práctica docente, siempre con una visión formativa y colaborativa.

Gracias por contribuir activamente a la construcción de una comunidad académica reflexiva, responsable y comprometida con el aprendizaje de nuestros estudiantes.
* **Comentarios:** [TextArea - Opcional]

---

## 3. Lógica de Calificación y Feedback

### Cálculo del Puntaje
* **Total de ítems:** 24
* **Puntaje máximo:** 120 (24 * 5)
* **Fórmula:** `Promedio = (Suma_Puntos / 120) * 100`

### Niveles de Desempeño
| Porcentaje | Nivel | Feedback Visual |
| :--- | :--- | :--- |
| 90% - 100% | Excelente | Destacar fortalezas. |
| 75% - 89% | Satisfactorio | Continuar con la mejora continua. |
| 60% - 74% | En Desarrollo | Sugerir capacitación pedagógica. |
| Menos de 60% | Necesita Mejora | Intervención académica requerida. |

---

## 4. Requerimientos de la App
* **Backend:** Almacenar respuestas en tabla `evaluaciones_docentes`.
* **Frontend:** Barra de progreso dinámica.
* **Salida:** Al dar clic en "Enviar", mostrar modal con el porcentaje obtenido y el Nivel de Desempeño.
