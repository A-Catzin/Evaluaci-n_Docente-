# Estructura de Proyecto - Sistema de Evaluación Docente (SED)

Este documento define la organización del repositorio para garantizar la escalabilidad, el mantenimiento y una clara separación de responsabilidades entre el frontend (Astro) y el backend (Supabase), cumpliendo con los estándares de "Clean Code" definidos.

## 📂 Árbol de Directorios

```text
/
├── docs/                   # Documentación técnica y de negocio (.md)
│   ├── contexto.md
│   ├── requerimientos.md
│   ├── roadmap.md
│   ├── architecture_patterns.md
│   └── estructura_de_carpetas.md
├── public/                 # Activos estáticos (Logos, favicon, fuentes)
│   └── assets/             # Imágenes y recursos institucionales
├── src/                    # Código fuente de la aplicación (Astro)
│   ├── components/         # Componentes UI atómicos y reutilizables
│   │   ├── ui/             # Componentes base (Botones, Cards, Inputs)
│   │   └── shared/         # Componentes transversales (Navbar, Footer)
│   ├── features/           # Módulos por dominio de negocio
│   │   ├── evaluacion/     # Lógica del formulario Likert y validación
│   │   ├── dashboard/      # Paneles para alumnos y coordinadores
│   │   └── reportes/       # Generación de analítica para docentes
│   ├── layouts/            # Plantillas base de página (Layout.astro)
│   ├── lib/                # Configuración de librerías (supabaseClient.ts)
│   ├── pages/              # Enrutamiento basado en archivos (Astro Pages)
│   │   ├── api/            # Endpoints para Server-Side logic
│   │   ├── auth/           # Páginas de Login y Redirección
│   │   └── index.astro     # Página de inicio
│   ├── schemas/            # Definiciones de Zod para validación de datos
│   ├── services/           # Capa de datos (Abstracción de consultas a Supabase)
│   ├── styles/             # CSS Global y configuración de Tailwind
│   └── types/              # Definiciones de TypeScript e Interfaces
├── supabase/               # Configuración de Backend-as-a-Service
│   ├── migrations/         # Scripts SQL de control de versiones de DB
│   └── seed.sql            # Datos de prueba (Docentes, Materias, Alumnos)
├── .env                    # Variables de entorno (URL/Keys de Supabase)
├── astro.config.mjs        # Configuración del framework Astro (Modo SSR)
├── package.json            # Dependencias y scripts de ejecución
├── tailwind.config.mjs     # Temas y colores institucionales
└── tsconfig.json           # Configuración de TypeScript