# Especificaciones Técnicas: Instrumento de Observación de Clase (Modalidad Ejecutiva)

Este documento define la estructura y métricas para la evaluación de desempeño docente en la modalidad ejecutiva, centrada en la eficiencia de las sesiones sabatinas y el soporte al trabajo autónomo.

---

## 1. Protocolo de Observación Ejecutiva
**Objetivo:** Evaluar la capacidad del docente para sintetizar contenidos y guiar el aprendizaje independiente durante las sesiones presenciales o sincrónicas de fin de semana.

### Instrucciones Críticas:
* **Foco Temporal:** Evaluar EXCLUSIVAMENTE lo que ocurre durante la sesión sabatina.
* **Registro de Evidencia:** Es obligatorio anotar acciones específicas de retroalimentación, aclaración de dudas e integración de contenidos de Moodle.
* **Criterio N/A:** Si un criterio no aplica, debe marcarse como N/A y fundamentar la razón en el bloque de observaciones.

---

## 2. Escala Institucional de Desempeño
| Nivel | Descripción | Características |
| :--- | :--- | :--- |
| **5** | Ejemplar | Sobresaliente, altamente profesional e innovador. |
| **4** | Eficaz | Cumple con calidad superior a lo esperado. |
| **3** | Adecuado | Cumple con lo esperado (Desarrollo funcional). |
| **2** | En proceso | Evidencias mínimas, inconsistencias o fallas de claridad. |
| **1** | No logrado | No se evidencia el criterio o fallas continuas. |

---

## 3. Dimensiones de la Rúbrica Ejecutiva

### A. Dimensión Cognitiva (CCO)
* **1CCO:** Claridad, síntesis y precisión en la explicación de contenidos clave.
* **2CCO:** Vinculación de aprendizajes previos con temas actuales.
* **3CCO:** Integración efectiva de contenidos de Moodle con la sesión presencial.
* **4CCO:** Aclaración de conceptos esenciales para el trabajo autónomo semanal.
* *Requiere: Bloque de observaciones cognitivas.*

### B. Dimensión Metacognitiva (CME)
* **1CME:** Reflexión sobre los avances logrados durante la semana previa.
* **2CME:** Orientación sobre estrategias de organización para el trabajo independiente.
* **3CME:** Retroalimentación sobre errores comunes detectados en plataforma.
* **4CME:** Propuesta de momentos de autoevaluación del progreso.
* *Requiere: Bloque de observaciones metacognitivas.*

### C. Dimensión Comunicativa (CCOM)
* **1CCOM:** Comunicación clara, ordenada y con secuencia lógica.
* **2CCOM:** Claridad en las instrucciones de tareas y actividades en Moodle.
* **3CCOM:** Apertura del ambiente para la expresión de dudas.
* **4CCOM:** Verificación de comprensión antes de finalizar bloques temáticos.
* *Requiere: Bloque de observaciones comunicativas.*

### D. Dimensión Social y Afectiva (CSO/CAF)
* **Social:** Reconocimiento de la carga laboral del estudiante ejecutivo y estrategias de participación inclusivas.
* **Afectiva:** Clima de empatía, motivación al proceso independiente y reconocimiento de avances semanales.

### E. Gestión, Tecno-Pedagogía y Normativa (CGE/CTE-PE/CNO)
* **Gestión:** Administración óptima del tiempo en bloques compactos y alineación con Moodle.
* **Tecno-Pedagogía:** Manejo de Moodle como herramienta central y retroalimentación de trabajos mediante la plataforma.
* **Normativa:** Puntualidad sabatina, desarrollo según programa ejecutivo y registro de evidencias en Moodle.

---

## 4. Implementación en Base de Datos (Supabase)

Para mantener la consistencia con los módulos anteriores, se debe extender el esquema:

### Tabla: `observaciones_ejecutivo`
* `id`: uuid.
* `docente_id`: uuid (FK -> `profiles`).
* `evaluador`: text (Selección de lista institucional).
* `oferta_academica`: text (Carrera evaluada).
* `cuatrimestre`: text (1ro al 12vo).
* `ciclo`: text (Ej: 26-2, 26-3).
* `datos_rubrica`: jsonb (Almacena los códigos 1CCO...4CNO y sus valores).
* `evidencia_objetiva`: jsonb (Comentarios por cada dimensión).
* `campus_contrato`: text.

---

## 5. Listado de Evaluadores y Carreras
**Evaluadores:** Oriana Nah, Eslivet Aguilar, Mari Carmen Martínez, Zulma Martínez, Elsa Garcia, Noadia González, Mario Medina, Karla Ponce, Cristhian Alvarado, Roberto Méndez, Lidia Medina, Roxana Landero, Josué Delgado, Jesús Aguilar, Merit Bazán, entre otros.

**Oferta:** Administración, Arquitectura, Derecho, Sistemas Computacionales, Enfermería, etc..

---