# Roadmap de Implementación — SED-360 v2

## Fase 1: Setup e Infraestructura ✅
- [x] Configurar Astro SSR + Tailwind + TypeScript
- [x] Configurar Supabase (PostgreSQL, Auth Google)
- [x] Crear esquema SQL v2 (15+ tablas, RLS, trigger)
- [x] Implementar middleware 4 roles + dominio
- [x] Layouts por rol (5 variantes)
- [x] Servicios CRUD
- [x] Dashboards principales (4 roles)
- [x] Páginas secundarias placeholder

## Fase 2: Admin Dashboard ✅
- [x] Dashboard con KPIs, ranking docentes
- [x] Gestión de docentes con buscador
- [x] Gestión de usuarios con filtros por rol
- [x] Gestión de roles (cambio rápido)
- [x] Catálogos: ofertas académicas, campus, turnos
- [x] Cuatrimestres

## Fase 3: Autodiagnóstico Docente ✅
- [x] Wizard 4 pasos (identificación, datos, 24 reactivos, cierre)
- [x] Cálculo automático de nivel de desempeño
- [x] Creación automática de perfil docente
- [x] Modal de resultado con feedback

## Fase 4: Observación de Clase ✅
- [x] Formulario 43 reactivos en 8 secciones (A-H)
- [x] Escala 1-5 + N/A
- [x] Precarga automática desde perfil del docente
- [x] Cálculo de promedio y alimentación a Prom. Obs.

## Fase 5: Planeaciones Didácticas 🔲
- [ ] Subida de PDFs a Supabase Storage (bucket `planeaciones`)
- [ ] Formulario de planeación con datos precargados
- [ ] Múltiples planeaciones por docente (una por materia)
- [ ] Rúbrica del coordinador (4 criterios 1-5)
- [ ] Cálculo automático → Prom. Plan. en dashboard admin
- [ ] Estados: Pendiente / Aprobado / Corrección
- [ ] Retroalimentación opcional para el docente
- [ ] Gestión de asignaturas por carrera
- [ ] Limpieza de archivos al cerrar cuatrimestre

## Fase 6: Encuesta Estudiantil 🔲
- [ ] Wizard 4 pasos mobile-first
- [ ] 18 ítems Likert en bloques
- [ ] Anonimato garantizado

## Fase 7: QA y Producción 🔲
- [ ] Seed data para pruebas
- [ ] Pruebas de estrés (concurrencia)
- [ ] Auditoría de anonimato
- [ ] Despliegue en Vercel
- [ ] Configuración Cloudflare WAF
