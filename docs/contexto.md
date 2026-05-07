# Documento de Contexto: Sistema de Evaluación Docente 360° (SED-360)

## 1. Visión General
El Sistema de Evaluación del Desempeño Docente 360° (SED-360) es una metodología integral diseñada para medir la calidad educativa a través de la convergencia de múltiples perspectivas. A diferencia de los métodos tradicionales y unidireccionales, el SED-360 busca un equilibrio entre la percepción del cliente directo (el alumno) y la observación técnica institucional. 

Los objetivos y puntos clave del sistema son:
* **Integralidad:** Evaluar competencias académicas, administrativas y actitudinales.
* **Confidencialidad:** Los resultados se manejan bajo estricto anonimato para proteger la integridad del proceso de evaluación.
* **Mejora Continua:** El fin primordial es identificar brechas de capacitación pedagógica e institucional, no aplicar sanciones directas.

## 2. Definición de Actores y Roles (Flujo 360°)
El docente es el único sujeto evaluado en este flujo, y su calificación se compone de las siguientes perspectivas:
* **Alumno (Evaluación Estudiantil):** Evalúa la experiencia en el aula, la claridad del docente y la metodología empírica.
* **Evaluador Técnico (Observación de Clase):** Realiza una observación in situ sobre las técnicas didácticas aplicadas.
* **Coordinador Académico (Evaluación por Coordinación):** Evalúa el cumplimiento del sílabo, puntualidad y dominio de la materia.
* **Coordinación / Calidad (Evaluación de Planeación):** Revisa el aspecto administrativo y la entrega de planeaciones en tiempo y forma.
* **Docente (Autoevaluación):** Reflexión del propio docente sobre su desempeño.
* **Administrador:** Gestiona periodos académicos, carga de datos y visualiza el tablero de control institucional.

## 3. Algoritmo de Ponderación 360°
Para obtener el **Puntaje Global 360°**, se aplica la siguiente ponderación dictada por el manual institucional:
* Evaluación Estudiantil: **35%**
* Observación de Clase: **25%**
* Evaluación por Coordinación: **20%**
* Evaluación de Planeación: **15%**
* Autoevaluación: **5%**

## 4. Reglas de Integridad (Business Rules)
* **Voto Único Estricto:** Un evaluador solo puede enviar sus resultados una vez por materia (carga académica). Protegido mediante Constraints SQL.
* **Anonimato Absoluto:** La base de datos guarda el identificador para la auditoría y control de voto único, pero en la capa de interfaz los comentarios se muestran mezclados, sin fechas y sin ID de grupo.
* **Moderación Institucional:** Textos de comentarios abiertos deben pasar por un filtro de lenguaje. Comentarios con lenguaje inapropiado son retenidos por el sistema.