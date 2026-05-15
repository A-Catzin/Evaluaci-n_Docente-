-- Migración 012: Mejorar editor de preguntas con tipo de respuesta y opciones
ALTER TABLE instrumento_preguntas ADD COLUMN IF NOT EXISTS tipo_respuesta VARCHAR(20) DEFAULT 'cerrada' CHECK (tipo_respuesta IN ('abierta','cerrada','opcion_multiple'));
ALTER TABLE instrumento_preguntas ADD COLUMN IF NOT EXISTS opciones JSONB DEFAULT '[]';
