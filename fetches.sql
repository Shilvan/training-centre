/*FETCHES*/

/*1. Fetch every module’s code, name & credits*/
SELECT code, name, credits FROM module;

/*2. Fetch every delegate’s no & name in descending order by name.*/
SELECT no, name FROM delegate ORDER BY name DESC;

/*3. Fetch the course’s code, name & credits where the name contains the string “Network”.*/
SELECT code, name, credits FROM course WHERE name LIKE '%Network%';

/*4. Calculate the highest grade in any module.*/
SELECT MAX(grade) FROM take;

/*5. Modify the query from Q4 to now fetch only the delegate no.*/
SELECT delegateNo FROM take WHERE grade = (SELECT MAX(grade) FROM take);

/*6.    Modify the query from Q5 to also fetch the delegate name.*/
SELECT no, name FROM delegate WHERE no = (SELECT delegateNo FROM take WHERE grade = (SELECT MAX(grade) FROM take));

/*7. Fetch the session’s code & date for sessions which are running in the next year and forwhich no room has been allocated.oTips . . BETWEEN, IS NULL*/
SELECT moduleCode, `date` FROM session WHERE YEAR(session.date) = (YEAR(CURDATE()) + 1) AND session.room IS NULL;

/*8. Fetch the delegate’s no & name along with the module’s code & name for delegates who have taken a module but have a failing grade.oTips . . INNER JOIN*/
SELECT delegate.no, delegate.name, module.code, module.name FROM delegate INNER JOIN take ON delegate.no = take.delegateNo INNER JOIN module ON take.moduleCode = module.code;

/*9.    Solve the problem from Q6 using JOINS where possible.oTips . . INNER JOIN, Sub-Query*/
SELECT delegate.no, delegate.name FROM delegate INNER JOIN take ON delegate.no = take.delegateNo ORDER BY take.grade DESC LIMIT 1; 

/*10.  Calculate and display every delegate’s no & name along with their attained credits versus the course’s code, name & credits.oTips . . SUM(), INNER JOIN, GROUP BY*/
SELECT delegate.no, delegate.name, SUM(module.credits), course.code, course.name, course.credits
	FROM delegate INNER JOIN take ON delegate.no = take.delegateNo
	INNER JOIN module ON take.moduleCode = module.code
	INNER JOIN course ON module.courseCode = course.code
	GROUP BY delegate.no, delegate.name, course.code, course.name, course.credits;

/*11.  Modify the query from Q10 to only show a delegate when they have attained the course’s credits.*/
SELECT delegate.no, delegate.name, SUM(module.credits), course.code, course.name, course.credits
	FROM delegate INNER JOIN take ON delegate.no = take.delegateNo
	INNER JOIN module ON take.moduleCode = module.code
	INNER JOIN course ON module.courseCode = course.code
	GROUP BY delegate.no, delegate.name, course.code, course.name, course.credits
	HAVING SUM(module.credits) >= course.credits;
