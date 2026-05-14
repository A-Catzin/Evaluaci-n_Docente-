# Especificaciones Técnicas: Módulo de Evaluación por Coordinación Académica (SED-360)

Este documento detalla los requerimientos para el sistema de evaluación docente realizado por la coordinación, correspondiente al modelo **SED-360-INST-COORD-GENERICO-01-web**.

---

## 1. Identificación y Contexto
**Objetivo:** Registrar la evaluación del desempeño docente por parte del personal administrativo y académico del campus.

### Datos de Control (Obligatorios):
* **Docente a Evaluar:** [Lookup/Texto] Nombre completo del docente, permite escribir pero funciona como un buscador de maestros y si aparece en poder seleccionarlo para poder normalizar las respuestas y si no esta dejar ponerlo por que posiblemente no esta en la base de datos.
* **Ciclo Escolar:** [Radio] Selección entre **26-2** o **26-3**.
* **Campus:** [Radio] Tuxtla, Playa del Carmen o Facultad de Ciencias de la Salud.
* **Evaluador:** [Dropdown] Lista institucional sacada de la base de datos de coordinadores, pero como el usuario ya es coordinador ese campo se rellenara automaticamente.

---

## 2. Rúbrica de Evaluación (Escala Likert 1-5)
Cada ítem debe evaluarse del **1 al 5**, donde:
* **5:** Excelente (Supera ampliamente lo esperado).
* **4:** Bueno (Cumple en tiempo y forma).
* **3:** Aceptable (Cumple parcialmente).
* **2:** Deficiente (Fallas importantes).
* **1:** Insuficiente (No cumple).

### Categorías e Ítems:

#### A. Cumplimiento Académico
1.  Cumplimiento del programa, planeación y avance académico.
2.  Organización y conducción de sesiones (presenciales, virtuales o ejecutivas).
3.  Uso y disponibilidad de materiales didácticos o recursos en plataforma.

#### B. Gestión y Organización
4.  Entrega de calificaciones en tiempo y forma.
5.  Puntualidad, asistencia y cumplimiento administrativo.
6.  Uso adecuado de plataformas institucionales (Moodle, Saeko, sistemas).

#### C. Desempeño Profesional y Comunicación
7.  Comunicación clara, oportuna y profesional con estudiantes y coordinación.
8.  Trabajo colaborativo con docentes y áreas institucionales.
9.  Participación en reuniones, actividades y procesos institucionales.

#### D. Innovación y Mejora Continua
10. Implementación de estrategias didácticas innovadoras.
11. Participación en procesos de capacitación o actualización docente.
12. Aplicación de mejoras en su práctica docente.

#### E. Compromiso Institucional y Ética
13. Cumplimiento de normatividad institucional.
14. Trato respetuoso, ético y profesional.
15. Representación institucional adecuada en entornos presenciales o digitales.

---

## 3. Lógica de Sistema y Backend (Supabase)

### Cálculo de Score:
El sistema debe generar un **promedio general** y un **promedio por categoría** (A, B, C, D, E) para alimentar el tablero de control del Sistema de Evaluación 360.

### Estructura de Tabla: `evaluaciones_coordinacion`
| Campo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | uuid | PK. |
| `docente_id` | uuid | FK -> `profiles`. |
| `evaluador_id` | text | Nombre del coordinador. |
| `ciclo` | text | Ej: "26-3". |
| `respuestas` | jsonb | Array de 15 valores (1-5). |
| `promedio_final` | float | Calculado en el edge function. |
| `comentarios` | text | Opcional. |

---

## 4. Observaciones Finales
* **Privacidad:** Los resultados son visibles para el docente solo después de que la Coordinación Académica cierre el periodo de evaluación.
* **Integración:** Este módulo debe cruzar datos con el de "Planeación Docente" para verificar si lo planeado coincide con lo evaluado.