# Documento de Contexto: Sistema de Evaluación Docente 360°

## 1. Visión General
Este sistema tiene como objetivo centralizar y automatizar la evaluación del desempeño docente. A diferencia de otros sistemas, aquí el flujo es estrictamente unidireccional: el **Docente** es el único sujeto evaluado por múltiples actores (Alumnos y Coordinadores).

## 2. Definición de Actores y Roles
* **Alumno:** Usuario con acceso a cuestionarios rápidos. Su evaluación se basa en la experiencia en el aula.
* **Coordinador:** Perfil técnico/académico. Evalúa el cumplimiento del sílabo y la metodología pedagógica.
* **Docente:** Sujeto pasivo de la evaluación. Solo tiene acceso a ver sus resultados agregados y comentarios anónimos.
* **Administrador:** Gestiona periodos académicos, carga de datos (mapeo alumno-docente) y visualiza reportes globales.

## 3. Lógica de Negocio y Ponderación
Para obtener una calificación final del docente, se aplica la siguiente fórmula:
**Nota Final = (Promedio Likert Alumnos * 0.60) + (Evaluación Rúbrica Coordinador * 0.40)**

### Escala Likert
Se utiliza una escala de 1 a 5:
1. Totalmente en desacuerdo
2. En desacuerdo
3. Neutral
4. De acuerdo
5. Totalmente de acuerdo

## 4. Reglas de Integridad (Business Rules)
* **Voto Único:** Un alumno solo puede evaluar una vez a un docente específico por materia dentro de un mismo periodo académico.
* **Anonimato Estricto:** La base de datos debe permitir auditar quién votó, pero la interfaz del docente/coordinador nunca debe mostrar la identidad del alumno ligada a un comentario o puntaje.
* **Disponibilidad:** El sistema debe soportar picos de tráfico (concurrencia alta) durante la "Semana de Evaluación".