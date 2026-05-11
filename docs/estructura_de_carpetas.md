# Estructura de Proyecto — SED-360 v2

```text
/
├── docs/                       # Documentación técnica (.md)
│   ├── documentacion/          # Documentación por módulo
│   ├── contexto.md
│   ├── requerimientos.md
│   ├── architecture_patterns.md
│   ├── estructura_de_carpetas.md
│   ├── ui_ux_guidelines.md
│   ├── roadmap.md
│   └── sistema_evaluacion.md   # Especificación técnica completa
├── public/                     # Activos estáticos
├── src/
│   ├── components/             # UI atómica (ScoreCard, RadarChart, etc. — futuro)
│   ├── features/               # Módulos por dominio (futuro)
│   ├── layouts/
│   │   ├── BaseLayout.astro    # Shell HTML común
│   │   ├── Layout.astro        # Layout público (landing, auth)
│   │   ├── LayoutAdmin.astro   # Sidebar fijo
│   │   ├── LayoutCoordinador.astro
│   │   ├── LayoutDocente.astro
│   │   └── LayoutEstudiante.astro
│   ├── lib/
│   │   └── supabaseClient.ts   # Cliente Supabase + polyfill WebSocket
│   ├── pages/
│   │   ├── index.astro         # Landing + detector OAuth
│   │   ├── auth.astro          # Login Google
│   │   ├── auth/callback.astro # Callback OAuth
│   │   ├── api/auth/           # guardar-sesion, signout, rol
│   │   ├── admin/              # dashboard, docentes, cuatrimestres, instrumentos
│   │   ├── coordinador/        # dashboard, captura/{CA,PD,OC}, reportes
│   │   ├── docente/            # dashboard, autoevaluacion, mis-grupos
│   │   └── estudiante/         # dashboard, encuesta/[grupo_id]
│   ├── services/
│   │   ├── catalogos.ts
│   │   ├── docentes.ts
│   │   ├── estudiantes.ts
│   │   ├── instrumentos.ts
│   │   └── calificaciones.ts
│   └── types/
│       └── supabase.ts         # 18 interfaces + constantes v2
├── supabase/
│   └── migrations/
│       ├── 001_esquema_v2.sql  # 15+ tablas
│       └── 002_rls_v2.sql      # Políticas RLS centralizadas
├── .env
├── astro.config.mjs
├── package.json
├── tailwind.config.mjs         # Paleta v2 (tup, dorado, categorías)
└── tsconfig.json
```
