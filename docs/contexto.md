# Documento de Contexto: Sistema de Evaluación Docente 360° (SED-360) v2

## 1. Visión General
El SED-360 mide el desempeño docente desde **5 instrumentos**, cada uno evaluado por un actor diferente.

## 2. Actores y Roles (4 roles)
| Rol | Acceso |
|-----|--------|
| **Superadmin** | Dashboard institucional, KPIs, ranking, configuración, catálogos |
| **Coordinador** | Evalúa docentes de su área. Captura CA, PD y OC |
| **Docente** | Ve resultados al cierre. Responde autodiagnóstico y sube planeaciones |
| **Estudiante** | Responde encuesta estudiantil anónima |

## 3. Modelo de Calificación 360°
```
Nota Final = (EE × 0.35) + (CA × 0.20) + (PD × 0.15) + (OC × 0.25) + (AE × 0.05)
```

| Instrumento | Clave | Peso | Escala | Normalización |
|-------------|-------|------|--------|---------------|
| Encuesta Estudiantil | EE | 35% | 1-6 calidad + 18 ítems 1-4 | (calidad/6)×100 |
| Coordinación Académica | CA | 20% | 15 ítems 1-5 (máx 75) | (total/75)×100 |
| Planeación Docente | PD | 15% | 4 criterios 1-5 (máx 20) | (total/20)×100 |
| Observación de Clase | OC | 25% | Escolarizado(45), Virtual(20), Ejecutivo(17) | (total/(n×5))×100 |
| Auto-evaluación | AE | 5% | 24 ítems 1-5 (máx 120) | (total/120)×100 |

### Rangos de Calificación Final
| Rango | Categoría | Color |
|-------|-----------|-------|
| 90–100 | Sobresaliente | `#22c55e` |
| 80–89 | Distinguido | `#3b82f6` |
| 70–79 | Bueno | `#a855f7` |
| 60–69 | Aprobado | `#f59e0b` |
| 50–59 | A mejorar | `#f97316` |
| 0–49 | Insuficiente | `#ef4444` |

## 4. Reglas de Negocio
- **Anonimato**: Encuesta estudiantil usa tabla de control separada
- **Dominio cerrado**: Solo @tecplayacar.edu.mx (middleware)
- **Cierre de cuatrimestre**: Resultados visibles solo al cerrar
- **Modalidad**: Docentes pueden tener múltiples modalidades (Escolarizado, Virtual, Ejecutivo, Mixto)
- **Observación por modalidad**: El coordinador evalúa con el formulario correspondiente a la modalidad del docente
