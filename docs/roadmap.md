# Roadmap de Implementación — SED-360 v2

## Fase 1: Setup e Infraestructura ✅
- [x] Configurar Astro SSR + Tailwind + TypeScript
- [x] Configurar Supabase (PostgreSQL, Auth Google)
- [x] Crear esquema SQL v2 (15+ tablas, RLS, trigger)
- [x] Implementar middleware 4 roles + dominio
- [x] Layouts por rol (5 variantes)
- [x] Servicios CRUD (5 archivos)
- [x] Dashboards principales (4 roles)
- [x] Páginas secundarias placeholder

## Fase 2: Admin Dashboard Completo 🔲
- [ ] Componentes UI (ScoreCard, RadarChart, DocenteCard)
- [ ] Perfil detallado de docente con gráfico radar
- [ ] Gráficas (donut categorías, barras instrumentos, línea histórico)
- [ ] Gestión de docentes (CRUD completo)
- [ ] Cierre de cuatrimestre + cálculo de calificaciones

## Fase 3: Captura de Instrumentos 🔲
- [ ] Formulario CA: 6 dimensiones, cálculo en tiempo real
- [ ] Formulario PD: 11 criterios con selector visual
- [ ] Formulario OC: 5 dimensiones con slider
- [ ] Auto-evaluación docente: 10 ítems
- [ ] Validación y guardado

## Fase 4: Encuesta Estudiantil 🔲
- [ ] Wizard 4 pasos mobile-first
- [ ] Paso 1: Calidad general (6 opciones visuales)
- [ ] Paso 2: 18 ítems Likert en bloques
- [ ] Paso 3: Comentario abierto
- [ ] Paso 4: Confirmación y envío
- [ ] Anonimato garantizado (tabla de control separada)

## Fase 5: QA y Producción 🔲
- [ ] Seed data para pruebas
- [ ] Pruebas de estrés (concurrencia)
- [ ] Auditoría de anonimato
- [ ] Despliegue en Vercel
- [ ] Configuración Cloudflare WAF
