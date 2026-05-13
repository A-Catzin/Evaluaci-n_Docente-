# Estructura de Proyecto — SED-360 v2

```text
/
├── docs/                       # Documentación técnica
│   ├── documentacion/          # Documentación por módulo
│   ├── formularios/            # Especificaciones de formularios
│   │   ├── autodiagnostico.md
│   │   ├── observacion.md
│   │   └── gestion_planeaciones_docentes.md
│   ├── contexto.md
│   ├── requerimientos.md
│   ├── architecture_patterns.md
│   ├── estructura_de_carpetas.md
│   ├── ui_ux_guidelines.md
│   ├── roadmap.md
│   └── sistema_evaluacion.md
├── public/
├── src/
│   ├── components/             # UI atómica (futuro)
│   ├── features/               # Módulos por dominio (futuro)
│   ├── layouts/
│   │   ├── BaseLayout.astro
│   │   ├── Layout.astro
│   │   ├── LayoutAdmin.astro
│   │   ├── LayoutCoordinador.astro
│   │   ├── LayoutDocente.astro
│   │   └── LayoutEstudiante.astro
│   ├── lib/
│   │   └── supabaseClient.ts
│   ├── pages/
│   │   ├── index.astro
│   │   ├── auth.astro
│   │   ├── auth/callback.astro
│   │   ├── api/auth/           # guardar-sesion, signout, rol
│   │   ├── api/admin/          # cambiar-rol, catalogos, ofertas
│   │   ├── api/coordinador/    # observacion
│   │   ├── api/docente/        # autodiagnostico
│   │   ├── admin/              # dashboard, docentes, usuarios, roles, ofertas, campus, turnos, cuatrimestres, instrumentos
│   │   ├── coordinador/        # dashboard, captura/{observacion,planeacion}, reportes
│   │   ├── docente/            # dashboard, autodiagnostico, mis-grupos
│   │   └── estudiante/         # dashboard, encuesta
│   ├── services/
│   │   ├── catalogos.ts
│   │   ├── docentes.ts
│   │   ├── estudiantes.ts
│   │   ├── instrumentos.ts
│   │   ├── calificaciones.ts
│   │   ├── autodiagnostico.ts
│   │   ├── observaciones.ts
│   │   └── usuarios.ts
│   └── types/
│       └── supabase.ts
├── supabase/
│   └── migrations/
│       ├── 001_esquema_v2.sql
│       ├── 002_rls_v2.sql
│       ├── 003_autodiagnostico.sql
│       ├── 004_rls_docente_perfil.sql
│       ├── 005_rls_usuario_update.sql
│       ├── 006_ofertas_academicas.sql
│       ├── 007_campus_turnos.sql
│       └── 008_observaciones.sql
├── .env
├── astro.config.mjs
├── package.json
├── tailwind.config.mjs
└── tsconfig.json
```
