INSERT INTO `jobs` (`name`, `label`) VALUES
('electricista', 'Electricista');
('farmer', 'Granjero');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('electricista', 0, 'employee', 'Empleado', 200, '{}', '{}');
('farmer', 0, 'employee', 'Empleado', 200, '{}', '{}');

INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
('cheque', 'Cheque', 15, 0, 1);
