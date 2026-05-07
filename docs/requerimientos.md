# Blueprint Técnico: Plataforma SED-360 - v2.0

Este documento define la arquitectura, lógica de negocio y estándares de seguridad para la plataforma institucional.

## 1. Stack Tecnológico (High Performance / Low Cost)
Para maximizar la eficiencia operativa y soportar cientos de alumnos concurrentes:
* **Frontend (UI):** **Astro** en modo SSR (Server Side Rendering) para rendimiento y carga ultrarrápida. Las interacciones de captura usarán React/Preact.
* **Backend & DB:** **Supabase** (PostgreSQL) para la gestión relacional, triggers y políticas RLS.
* **Autenticación:** **Google Auth** (Restringido al dominio institucional).
* **Despliegue:** **Vercel** para integración continua.
* **Seguridad DNS:** **Cloudflare** como escudo WAF contra ataques.

## 2. Protocolo de Acceso Institucional
El sistema implementa una política de "Dominio Cerrado":
* Se permiten exclusivamente correos del dominio institucional (Ej: `@tecplayacar.edu.mx`).
* El middleware de Astro verificará cada solicitud de página; si el usuario no tiene el dominio válido, se destruye la sesión y redirige al login.

## 3. Modelado de Datos Core (Esquema SQL)
Para garantizar el soporte de concurrencia y prevenir fraude, se aplicará esta estructura base:

```sql
-- 1. Usuarios y Roles (Sincronizado con Auth)
CREATE TABLE usuarios (
    id UUID REFERENCES auth.users PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    rol VARCHAR(50) CHECK (rol IN ('alumno', 'docente', 'coordinador', 'tecnico', 'calidad', 'admin'))
);

-- 2. El Nexo Central: Cargas Académicas
-- Relaciona al docente con la materia en un periodo específico.
CREATE TABLE cargas_academicas (
    id_carga SERIAL PRIMARY KEY,
    id_docente UUID REFERENCES usuarios(id),
    id_materia TEXT NOT NULL,
    id_periodo TEXT NOT NULL,
    UNIQUE (id_docente, id_materia, id_periodo)
);

-- 3. Captura de Evaluaciones (Normalizada para Escalabilidad)
CREATE TABLE evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    id_evaluador UUID REFERENCES usuarios(id),
    id_carga INT REFERENCES cargas_academicas(id_carga),
    tipo_actor VARCHAR(20) CHECK (tipo_actor IN ('ALUMNO', 'COORDINADOR', 'TECNICO', 'CALIDAD', 'AUTO')),
    puntaje_promedio DECIMAL(5,2),
    comentario TEXT,
    marcado_inapropiado BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Regla de prevención de fraude: Nadie vota dos veces la misma carga académica
    CONSTRAINT unique_vote UNIQUE (id_evaluador, id_carga, tipo_actor)
);