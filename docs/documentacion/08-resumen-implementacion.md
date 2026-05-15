# 08 — Resumen de Implementación SED-360 v2

> Documento final — Mayo 2026. 4 roles, 5 instrumentos, 20+ tablas, Supabase Storage.

## Stack
| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Astro SSR | 4.16.18 |
| CSS | Tailwind CSS | 3.4.17 |
| Backend/DB | Supabase (PostgreSQL) | — |
| Storage | Supabase Storage (bucket `planeaciones`) | — |
| Auth | Supabase Auth + Google OAuth | — |
| Runtime | Node.js | 20.19.2 |

## Fórmula de Ponderación 360°
```
Nota Final = EE(35%) + CA(20%) + PD(15%) + OC(25%) + AE(5%)
```

## Estado de Instrumentos
| # | Instrumento | Peso | Reactivos | Estado |
|---|-------------|------|-----------|--------|
| 1 | Autoevaluación Docente | 5% | 24 (1-5) | ✅ Completo |
| 2 | Planeación Docente | 15% | 4 criterios (1-5) + PDF | ✅ Completo |
| 3 | Observación de Clase | 25% | Escolarizado(45), Virtual(20), Ejecutivo(17) | ✅ Completo |
| 4 | Coordinación Académica | 20% | 15 ítems en 5 categorías (1-5) | ✅ Completo |
| 5 | Encuesta Estudiantil | 35% | 1-6 + 18 ítems 1-4 | 🔲 Pendiente |

## Páginas Implementadas
| Ruta | Rol | Descripción |
|------|-----|-------------|
| `/` | Público | Landing + OAuth |
| `/auth` | Público | Login Google |
| `/admin/dashboard` | superadmin | KPIs, ranking docentes |
| `/admin/docentes` | superadmin | Tabla con scores + buscador + Coordinador |
| `/admin/coordinadores` | superadmin | Métricas + docentes evaluados |
| `/admin/usuarios` | superadmin | Tablas por rol (simplificadas) |
| `/admin/roles` | superadmin | Cambio rápido de roles |
| `/admin/ofertas` | superadmin | CRUD ofertas académicas |
| `/admin/asignaturas` | superadmin | CRUD materias por carrera |
| `/admin/campus` | superadmin | CRUD campus |
| `/admin/turnos` | superadmin | CRUD turnos |
| `/admin/cuatrimestres` | superadmin | Gestión periodos |
| `/admin/instrumentos` | superadmin | Estado + editor de preguntas |
| `/admin/instrumentos/editar` | superadmin | Editor de preguntas por instrumento |
| `/coordinador/dashboard` | coord/superadmin | KPIs, pendientes/completados |
| `/coordinador/captura/observacion` | coord | 45 reactivos escolarizado |
| `/coordinador/captura/observacion-virtual` | coord | 20 reactivos virtual |
| `/coordinador/captura/observacion-ejecutivo` | coord | 17 reactivos ejecutivo |
| `/coordinador/captura/coordinacion` | coord | 15 reactivos CA |
| `/coordinador/planeaciones` | coord | Evaluar planeaciones |
| `/coordinador/planeaciones/evaluar/[id]` | coord | Rúbrica 4 criterios |
| `/docente/dashboard` | docente | Resultados |
| `/docente/autodiagnostico` | docente | Wizard 4 pasos, 24 ítems |
| `/docente/planeaciones` | docente | Subir PDF + lista |
| `/estudiante/dashboard` | estudiante | Encuestas pendientes |

## Base de Datos
| Tabla | Descripción |
|-------|-------------|
| `cuatrimestres`, `licenciaturas`, `ofertas_academicas`, `campus`, `turnos` | Catálogos |
| `docentes`, `asignaturas`, `grupos`, `estudiantes`, `inscripciones` | Entidades |
| `usuarios` | Auth + roles (superadmin, coordinador, docente, estudiante) |
| `autodiagnosticos` | AE: 24 ítems |
| `planeaciones` | PD: PDF + rúbrica 4 criterios |
| `observaciones` | OC escolarizado: 45 ítems |
| `evaluacion_coordinacion` | CA: 15 ítems, score normalizado |
| `encuesta_estudiantil_respuestas` | EE: anónima |
| `encuesta_control_envio` | Control de envío EE |
| `calificacion_final_docente` | Puntaje final 360° (GENERATED) |
| `instrumento_preguntas` | Preguntas editables por instrumento |

## Migraciones (18 archivos)
001 → 018 en `supabase/migrations/`. Cubren esquema completo, RLS, catálogos, instrumentos, fórmulas y limpieza.

## Problemas Resueltos
| Problema | Solución |
|----------|----------|
| WebSocket Node 20 | `import ws from 'ws'` estático |
| OAuth code_verifier | Flujo implícito con hash |
| RLS recursión | Función `rol_usuario()` SECURITY DEFINER |
| Redirect por rol | Endpoint `/api/auth/rol` |
| Docente inactivo al cambiar rol | Trigger `limpiar_entidad_al_cambiar_rol()` |
| Preguntas hardcodeadas | Tabla `instrumento_preguntas` + editor |
| Storage bucket privado | URLs firmadas para PDFs |
| DECIMAL overflow | `DECIMAL(5,2)` para puntajes de 100 |
