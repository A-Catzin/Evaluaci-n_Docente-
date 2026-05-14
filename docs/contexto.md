# Documento de Contexto: Sistema de Evaluación Docente 360° (SED-360) v2

## 1. Visión General
El SED-360 es una plataforma integral que mide el desempeño docente desde **5 perspectivas** (instrumentos). Cada instrumento es evaluado por un actor diferente y contribuye con un peso específico a la calificación final del docente.

## 2. Actores y Roles (4 roles)

| Rol | Descripción | Acceso |
|-----|-------------|--------|
| **Superadmin** | Dirección académica. Acceso total. | Dashboard institucional, KPIs, ranking, configuración |
| **Coordinador** | Evalúa docentes de su área. Captura instrumentos CA, PD y OC. | Dashboard de área, formularios de captura, reportes |
| **Docente** | Sujeto evaluado. Responde auto-evaluación. Ve resultados al cierre. | Dashboard personal, auto-evaluación, historial |
| **Estudiante** | Responde encuesta estudiantil anónima. | Dashboard de encuestas pendientes/completadas |

## 3. Modelo de Calificación 360°

```
Nota Final = (EE × 0.40) + (CA × 0.25) + (PD × 0.15) + (OC × 0.15) + (AE × 0.05)
```

| Instrumento | Clave | Peso | Escala | Normalización |
|-------------|-------|------|--------|---------------|
| Encuesta Estudiantil | EE | 40% | calidad_general 1–6, 18 ítems Likert 1–4 | (calidad/6) × 100 |
| Coordinación Académica | CA | 25% | 0–75 puntos, 6 dimensiones | (puntos/75) × 100 |
| Planeación Docente | PD | 15% | 11 criterios 0–2 (máx 22) | (total/22) × 100 |
| Observación de Clase | OC | 15% | 0–10 puntos, 5 dimensiones | puntuacion × 10 |
| Auto-evaluación | AE | 5% | 10 ítems 1–3 (máx 30) | (total/30) × 100 |

### Rangos de Calificación Final

| Rango | Categoría | Color |
|-------|-----------|-------|
| 90–100 | Sobresaliente | `#22c55e` |
| 80–89 | Distinguido | `#3b82f6` |
| 70–79 | Bueno | `#a855f7` |
| 60–69 | Aprobado | `#f59e0b` |
| 50–59 | A mejorar | `#f97316` |
| 0–49 | Insuficiente | `#ef4444` |

## 4. Reglas de Integridad

- **Anonimato estricto**: La encuesta estudiantil es 100% anónima. Se usa tabla de control separada (`encuesta_control_envio`) que solo registra QUE el estudiante respondió, no QUÉ respondió.
- **Voto único**: Constraints UNIQUE en cada instrumento previenen doble envío.
- **Cierre de cuatrimestre**: Los resultados del docente solo son visibles cuando el cuatrimestre está cerrado. Coordinadores y admin ven en tiempo real.
- **Dominio cerrado**: Solo correos `@tecplayacar.edu.mx` pueden acceder (validado en middleware).
- **Comentarios foco rojo**: Comentarios clasificados como "foco rojo" o "crítico" generan alertas para el coordinador.
