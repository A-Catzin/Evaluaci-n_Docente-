-- Seed: Observación Virtual (20 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('observacion_virtual','A',1,'Organización y vinculación de contenidos con recursos digitales.'),
('observacion_virtual','A',2,'Uso de ejemplos y casos contextualizados al entorno en línea.'),
('observacion_virtual','A',3,'Adaptación ante limitaciones tecnológicas del grupo.'),
('observacion_virtual','A',4,'Uso de apoyos visuales (gráficas, pizarras virtuales) para clarificar conceptos.'),
('observacion_virtual','A',5,'Clarificación de términos técnicos con herramientas digitales.'),
('observacion_virtual','A',6,'Promoción del razonamiento crítico (breakout rooms, debates).'),
('observacion_virtual','B',1,'Generación de reflexión mediante foros o chats.'),
('observacion_virtual','B',2,'Orientación sobre fortalezas y áreas de oportunidad.'),
('observacion_virtual','B',3,'Fomento del aprendizaje autónomo y gestión propia en línea.'),
('observacion_virtual','B',4,'Actividades de recapitulación o autoevaluaciones digitales.'),
('observacion_virtual','C',1,'Claridad en voz, dicción, ritmo y volumen.'),
('observacion_virtual','C',2,'Manejo respetuoso de chats y turnos de voz.'),
('observacion_virtual','C',3,'Explicación de dinámicas con lenguaje accesible.'),
('observacion_virtual','C',4,'Comunicación de propósitos y resultados esperados.'),
('observacion_virtual','C',5,'Verificación de comprensión (encuestas, reacciones).'),
('observacion_virtual','D',1,'Clima de respeto, participación equitativa y manejo de imprevistos técnicos.'),
('observacion_virtual','D',2,'Ambiente de confianza y manejo cálido de la baja participación.'),
('observacion_virtual','E',1,'Alineación con la planeación y uso de estrategias activas (Kahoot, Jamboard).'),
('observacion_virtual','E',2,'Dominio de la plataforma virtual y promoción del uso ético de la tecnología.'),
('observacion_virtual','F',1,'Inicio puntual, desarrollo conforme al calendario y respeto a la duración.')
ON CONFLICT (instrumento, orden) DO NOTHING;

-- Seed: Observación Ejecutiva (17 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('observacion_ejecutivo','A',1,'Claridad, síntesis y precisión en la explicación de contenidos clave.'),
('observacion_ejecutivo','A',2,'Vinculación de aprendizajes previos con temas actuales.'),
('observacion_ejecutivo','A',3,'Integración efectiva de contenidos de Moodle con la sesión presencial.'),
('observacion_ejecutivo','A',4,'Aclaración de conceptos esenciales para el trabajo autónomo semanal.'),
('observacion_ejecutivo','B',1,'Reflexión sobre los avances logrados durante la semana previa.'),
('observacion_ejecutivo','B',2,'Orientación sobre estrategias de organización para el trabajo independiente.'),
('observacion_ejecutivo','B',3,'Retroalimentación sobre errores comunes detectados en plataforma.'),
('observacion_ejecutivo','B',4,'Propuesta de momentos de autoevaluación del progreso.'),
('observacion_ejecutivo','C',1,'Comunicación clara, ordenada y con secuencia lógica.'),
('observacion_ejecutivo','C',2,'Claridad en las instrucciones de tareas y actividades en Moodle.'),
('observacion_ejecutivo','C',3,'Apertura del ambiente para la expresión de dudas.'),
('observacion_ejecutivo','C',4,'Verificación de comprensión antes de finalizar bloques temáticos.'),
('observacion_ejecutivo','D',1,'Reconocimiento de la carga laboral del estudiante ejecutivo y participación inclusiva.'),
('observacion_ejecutivo','D',2,'Clima de empatía, motivación al proceso independiente y reconocimiento de avances.'),
('observacion_ejecutivo','E',1,'Administración óptima del tiempo en bloques compactos y alineación con Moodle.'),
('observacion_ejecutivo','E',2,'Manejo de Moodle como herramienta central y retroalimentación mediante plataforma.'),
('observacion_ejecutivo','E',3,'Puntualidad sabatina, desarrollo según programa ejecutivo y registro de evidencias.')
ON CONFLICT (instrumento, orden) DO NOTHING;
