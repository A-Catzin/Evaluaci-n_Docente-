-- Migración 011: Tabla de preguntas editables para instrumentos
CREATE TABLE IF NOT EXISTS instrumento_preguntas (
  id SERIAL PRIMARY KEY,
  instrumento VARCHAR(50) NOT NULL, -- 'autodiagnostico','observacion','coordinacion','planeacion','encuesta'
  seccion VARCHAR(10),              -- 'A','B', etc. o NULL
  orden SMALLINT NOT NULL,
  texto TEXT NOT NULL,
  escala_min SMALLINT DEFAULT 1,
  escala_max SMALLINT DEFAULT 5,
  activa BOOLEAN DEFAULT TRUE,
  UNIQUE(instrumento, orden)
);

ALTER TABLE instrumento_preguntas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff gestiona preguntas" ON instrumento_preguntas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');
CREATE POLICY "Todos leen preguntas" ON instrumento_preguntas FOR SELECT USING (auth.uid() IS NOT NULL);

-- Seed: preguntas de autodiagnóstico (24 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('autodiagnostico',NULL,1,'Domino los conceptos para la construcción del aprendizaje en los cursos o programas académicos que imparto.'),
('autodiagnostico',NULL,2,'Expongo, organizo, desarrollo y vinculo los contenidos en forma clara.'),
('autodiagnostico',NULL,3,'Adapto los contenidos a los diversos estilos y necesidades de los estudiantes.'),
('autodiagnostico',NULL,4,'Organizo espacios de reflexión antes, durante y después de las actividades de aprendizaje.'),
('autodiagnostico',NULL,5,'Incluyo actividades en clase que promueven el aprendizaje autónomo en los estudiantes.'),
('autodiagnostico',NULL,6,'Propongo ejercicios para promover la metacognición en su ambiente de aprendizaje.'),
('autodiagnostico',NULL,7,'Propongo nuevas estrategias para mejorar los resultados obtenidos en el desempeño de los estudiantes.'),
('autodiagnostico',NULL,8,'Me comunico con claridad y precisión.'),
('autodiagnostico',NULL,9,'Escucho activamente a mis estudiantes.'),
('autodiagnostico',NULL,10,'Fomento la participación y el diálogo respetuoso.'),
('autodiagnostico',NULL,11,'Mantengo un trato respetuoso con mis estudiantes.'),
('autodiagnostico',NULL,12,'Atiendo situaciones grupales con sensibilidad y objetividad.'),
('autodiagnostico',NULL,13,'Organizo los objetivos y contenidos de manera coherente con el modelo educativo.'),
('autodiagnostico',NULL,14,'Implemento diversas estrategias para inducir el aprendizaje significativo.'),
('autodiagnostico',NULL,15,'Considero saberes previos, intereses y experiencias de sus estudiantes.'),
('autodiagnostico',NULL,16,'Genero oportunidades de desarrollo del pensamiento crítico y creativo.'),
('autodiagnostico',NULL,17,'Motivo al aprendizaje, la indagación y la búsqueda de conocimiento.'),
('autodiagnostico',NULL,18,'Ofrezco retroalimentación oportuna, pertinente y cálida a los estudiantes.'),
('autodiagnostico',NULL,19,'Promuevo un ambiente de confianza y respeto.'),
('autodiagnostico',NULL,20,'Manejo mis emociones de forma profesional en clase.'),
('autodiagnostico',NULL,21,'Utilizo herramientas tecnológicas para enriquecer mi enseñanza.'),
('autodiagnostico',NULL,22,'Integro recursos digitales de forma adecuada a los contenidos.'),
('autodiagnostico',NULL,23,'Conozco y aplico la normatividad institucional.'),
('autodiagnostico',NULL,24,'Respeto el reglamento y lineamientos académicos.')
ON CONFLICT (instrumento, orden) DO NOTHING;
