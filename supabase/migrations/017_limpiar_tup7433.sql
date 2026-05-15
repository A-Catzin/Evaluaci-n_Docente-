-- Migración 017: Limpieza manual de docente tup7433
UPDATE docentes SET activo = false WHERE email = 'tup7433@tecplayacar.edu.mx';
UPDATE usuarios SET entidad_id = NULL WHERE email = 'tup7433@tecplayacar.edu.mx';
