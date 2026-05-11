# Guía de Estilo UI/UX — SED-360 v2

## 1. Paleta de Colores

| Aplicación | Clase Tailwind | Color Hex |
|:---|:---|:---|
| Primario TUP | `bg-tup` / `text-tup` | `#1e3a5f` |
| Acento Dorado | `bg-dorado` / `text-dorado` | `#e8a020` |
| Fondo | `bg-fondo-dashboard` | Gradiente `#f5f7fa → #eef2f7` |
| Hero | `bg-hero-tup` | Gradiente `#1e3a5f → #2d5a8e` |

### Categorías de Evaluación
| Categoría | Clase | Color |
|-----------|-------|-------|
| Sobresaliente | `text-sobresaliente` | `#22c55e` |
| Distinguido | `text-distinguido` | `#3b82f6` |
| Bueno | `text-bueno` | `#a855f7` |
| Aprobado | `text-aprobado` | `#f59e0b` |
| A mejorar | `text-a_mejorar` | `#f97316` |
| Insuficiente | `text-insuficiente` | `#ef4444` |

### Alertas de Comentarios
| Tipo | Clase | Color |
|------|-------|-------|
| Foco rojo | `text-foco-rojo` | `#dc2626` |
| Crítico | `text-critico-com` | `#f97316` |
| A mejorar | `text-a-mejorar-com` | `#f59e0b` |
| Neutro | `text-neutro-com` | `#6b7280` |
| Excelente | `text-excelente-com` | `#22c55e` |

## 2. Layouts por Rol

- **Admin**: Sidebar fijo (64px) con íconos + labels, fondo blanco con borde
- **Coordinador**: Top navigation con tabs, sin sidebar
- **Docente**: Top navigation simplificado, centrado (max-w-4xl)
- **Estudiante**: Full-screen centrado, sin navegación visible, modo enfoque tipo wizard

## 3. Componentes Clave

| Componente | Descripción |
|-----------|-------------|
| `ScoreCard` | Tarjeta de score por instrumento |
| `RadarChart` | Gráfico radar 5 ejes (Chart.js) |
| `DocenteCard` | Tarjeta de docente con mini-barras |
| `CalificacionFinalBadge` | Badge grande con categoría |
| `EncuestaStep` | Paso del wizard de encuesta |

## 4. Diseño Mobile-First

- Botones mínimo 44×44px
- Grid responsive (1 col mobile → 2 sm → 3 lg)
- Tipografía 15px base en móvil
- `min-h-dvh` para full-screen en móviles
