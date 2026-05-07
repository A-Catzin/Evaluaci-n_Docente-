# Blueprint Técnico: Sistema de Evaluación Docente (SED) - v2.0

Este documento define la arquitectura, lógica de negocio y estándares de seguridad para la plataforma de evaluación docente institucional.

## 1. Stack Tecnológico (High Performance / Low Cost)

Para maximizar la eficiencia y minimizar costos operativos, se ha seleccionado el siguiente ecosistema:

*   **Frontend (UI):** **Astro** en modo SSR (Server Side Rendering) para un rendimiento óptimo y carga rápida de formularios.
*   **Backend & DB:** **Supabase** (PostgreSQL) para gestión de datos en tiempo real.
*   **Autenticación:** **Google Auth** (Restringido a dominio institucional).
*   **Despliegue:** **Vercel** para integración continua.
*   **Seguridad DNS:** **Cloudflare** como escudo WAF contra ataques DDoS.

---

## 2. Protocolo de Acceso Institucional (Seguridad de Dominio)

Para garantizar la integridad de las evaluaciones, el sistema implementa una política de "Dominio Cerrado".

*   **Validación de Dominio:** Solo se permiten correos con el sufijo `@tecplayacar.edu.mx` (ejemplo: `tup7433@tecplayacar.edu.mx`).
*   **Implementación en Supabase:**
    1.  Configurar en el Dashboard de Supabase: *Authentication -> Providers -> Google -> "Allowed Email Domains"*: `tecplayacar.edu.mx`.
    2.  **Middleware de Astro:** El sistema verifica en cada carga de página que el `user.email` termine en el dominio permitido. Si no coincide, se cierra la sesión automáticamente y se redirige al login.

---

## 3. Modelado de Datos (Esquema SQL)
```sql
-- 1. Perfiles de Usuario (Sincronizados con Auth)
CREATE TABLE perfiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    rol TEXT CHECK (rol IN ('alumno', 'coordinador', 'admin')),
    nombre_completo TEXT,
    avatar_url TEXT
);

-- 2. Catálogo de Docentes (Sujetos de evaluación)
CREATE TABLE docentes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    departamento TEXT,
    foto_url TEXT
);

-- 3. Tabla de Vinculaciones (La llave del sistema)
-- Relaciona quién evalúa a quién en qué periodo.
CREATE TABLE vinculaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    periodo_id TEXT NOT NULL, -- Ej: "2024-1"
    alumno_id UUID REFERENCES perfiles(id),
    docente_id UUID REFERENCES docentes(id), 
    materia_id TEXT NOT NULL,
    completado BOOLEAN DEFAULT FALSE,
    UNIQUE(alumno_id, docente_id, materia_id, periodo_id) -- Bloqueo de doble voto
);

-- 4. Captura de Evaluaciones
CREATE TABLE evaluaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vinculacion_id UUID REFERENCES vinculaciones(id) ON DELETE CASCADE,
    tipo_evaluador TEXT CHECK (tipo_evaluador IN ('alumno', 'coordinador')),
    respuestas JSONB NOT NULL, -- Estructura: {"p1": 5, "p2": 4...}
    comentario TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);