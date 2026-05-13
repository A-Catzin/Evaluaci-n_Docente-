# Especificaciones Técnicas: Sistema de Gestión de Planeaciones Didácticas (Ciclo 26-3)

Este documento define la estructura técnica y funcional para el módulo de entrega y evaluación de planeaciones del **Tecnológico Universitario Playacar**.

---

## 1. Módulo del Docente (Buzón de Entrega)
**Objetivo:** Permitir el registro individual de cada planeación por asignatura y grupo para el **Sistema de Evaluación del Desempeño Docente 360**.

### Interfaz de Usuario y Campos Obligatorios:
* **Identidad:** Captura automática del nombre, foto y correo institucional (`@tecplayacar.edu.mx`) mediante la cuenta de Google vinculada y su autodiagnostico
* **Campus Asignado:** [Radio] Tecnológico Universitario Tuxtla / Tecnológico Universitario Playacar / Otros. Si ya se teniene con su autodiagnostico se completa en automatico 
* **Licenciatura:** [Dropdown] (Ej: Sistemas Computacionales, Enfermería, Administración, etc.). Se saca segun su autodiagnostico
* **Cuatrimestre:** [Dropdown] Del 1er al 12vo cuatrimestre.
* **Turno y Modalidad:** [Radio] (Matutino/Vespertino) y (Escolarizada/Ejecutiva). Se saca segun su autodiagnostico 
* **Asignatura y Grupo:** [Texto] Registro individual por cada grupo asignado.
* **Preguntas de Integración Académica:**
    * ¿Se genera algún proyecto en la asignatura? (Sí/No).
    * ¿Integras uso de laboratorio? (Sí/No/No aplica).
    * ¿Integra visitas académicas, empresariales o foros? (Sí/No/No aplica).
* **Comentario:** [TextArea] Espacio opcional para observaciones adicionales.

---

## 2. Estándares de Carga de Archivos
El sistema debe validar los siguientes parámetros técnicos antes de procesar el envío a **Supabase Storage**:

* **Formato Único:** PDF.
* **Tamaño Máximo:** 100 MB.
* **Nomenclatura Institucional Obligatoria:** `Asignatura_Grupo_Modalidad_ApellidoDocente_26-3.pdf`o si se puede cambiarle el nombre al archivo cuando lo suba para tener esa parte estandarizada 
  *Ejemplo: Fundamentos_Enfermeria_3A_Escolarizada_Perez_26-3.pdf*.

---

## 3. Calendario y Fechas Límite
El sistema bloqueará automáticamente la subida de archivos según el calendario académico vigente:

* **Docentes Continuantes:** Aun por definir por el administrador
* **Docentes de Nuevo Ingreso:** Aun por definir por el administrador

---

## 4. Estructura de Datos (Supabase)
Basado en la arquitectura del proyecto (Next.js + Supabase):

### Tabla: `planeaciones`
| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | uuid | Llave primaria. |
| `docente_id` | uuid | FK -> `profiles(id)`. |
| `campus` | text | Campus seleccionado. |
| `licenciatura` | text | Carrera correspondiente. |
| `url_pdf` | text | Ruta del archivo en el Storage Bucket. |
| `estado` | enum | 'Pendiente', 'Aprobado', 'Corrección'. |
| `comentarios_coordinador` | text | Obligatorio si el estado es 'Corrección'. |

---

## 5. Módulo del Coordinador (Evaluación)
Los coordinadores evaluarán cada registro bajo una rúbrica de escala 1-5 que incluye:
1. **Alineación Curricular.**
2. **Secuencia Didáctica.**
3. **Recursos y Materiales (NTIC).**
4. **Sistemas de Evaluación.**

Si el estado se marca como **Corrección**, el sistema notificará al docente y habilitará el botón de "Re-subir archivo".