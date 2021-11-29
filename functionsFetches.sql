/*Check SPROC*/
SELECT * FROM session;
CALL scheduleModules('DDM', '3000-01-05');
SELECT * FROM session;

/*Check trigger*/
SELECT * FROM gradeAudit;
UPDATE take SET grade = 99 WHERE grade = 63;
SELECT * FROM gradeAudit;



SELECT module.code, module.name, session.date
	FROM session INNER JOIN module ON session.moduleCode = module.code 
	WHERE YEAR(session.date) = (YEAR(CURDATE()) + 1) AND session.room IS NULL 
	ORDER BY session.date ASC;