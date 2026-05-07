# Estructura de Proyecto - Plataforma SED-360

Esta organización de repositorio garantiza escalabilidad y sigue la filosofía "Feature Slices" de Clean Architecture.

## 📂 Árbol de Directorios

```text
/
├── docs/                   # Documentación técnica de negocio (.md)
│   ├── contexto.md
│   ├── requerimientos.md
│   ├── roadmap.md
│   ├── architecture_patterns.md
│   ├── ui_ux_guidelines.md
│   └── documentacion.md
├── public/                 # Activos estáticos, Logos institucionales
├── src/                    # Código fuente base (Astro)
│   ├── components/         # UI Atómica
│   │   ├── ui/             # Elementos sin estado (Botones, Cards, Inputs)
│   │   └── form/           # Controles interactivos (Likert Scales)
│   ├── features/           # Módulos separados por Dominio de Negocio
│   │   ├── evaluacion/     # Formularios y validaciones de alumnos/coordinadores
│   │   ├── dashboard/      # Vistas de progreso e interfaces de entrada
│   │   ├── analitica/      # Cálculos 360° y visualización de promedios
│   │   └── moderacion/     # Filtros de Blacklist para comentarios
│   ├── layouts/            # Plantillas maestras base (Layout.astro)
│   ├── lib/                # Inicialización de clientes (Supabase, Zod)
│   ├── pages/              # Enrutamiento basado en archivos
│   │   ├── api/            # Server actions y endpoints internos
│   │   ├── auth/           # Redirecciones y Login
│   │   ├── evaluador/      # Rutas para el flujo de captura
│   │   ├── admin/          # Rutas protegidas para coordinación
│   │   └── index.astro
│   ├── schemas/            # Validación de payloads con Zod
│   ├── services/           # Abstracción de base de datos (Supabase interactions)
│   └── utils/              # Funciones puras (Algoritmos matemáticos, normalizadores)
├── supabase/               # Configuración del Backend as a Service
│   ├── migrations/         # Control de versiones SQL (Constraints de Voto Único)
│   └── seed.sql            # Datos de prueba de cargas académicas
├── .env                    # Variables de entorno
├── astro.config.mjs        
├── package.json            
├── tailwind.config.mjs     
└── tsconfig.json