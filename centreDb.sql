/*TERMINAL CODE:
mysql -u shilvan -p
mypassword
source ~/Documents/Computing/trainingCentre/centreDb.sql
*/

/*CREATE DATABASE*/
DROP DATABASE IF EXISTS trainingCentre;
CREATE DATABASE trainingCentre;
USE trainingCentre;

/*CREATE TABLES*/
DROP TABLE IF EXISTS course, module, delegate, take, session;

/*Course table*/
CREATE TABLE course(	
	code char(3) NOT NULL,
	name varchar(30) NOT NULL,
	credits tinyint NOT NULL,
	UNIQUE(code, name),
	CHECK(credits=50 OR credits=75 OR credits=100),
	CONSTRAINT pkCourse PRIMARY KEY(code)
);

/*Modules of the course table*/
CREATE TABLE module(	
	code char(2) NOT NULL,
	name varchar(30) NOT NULL,
	cost decimal(8,2) NOT NULL,
	credits tinyint NOT NULL,
	courseCode char(3) NOT NULL REFERENCES course(code),
	UNIQUE(code, name),
	CHECK(credits=25 OR credits=50),
	CONSTRAINT pkModule PRIMARY KEY(code)
);

/*Students of each modules table*/
CREATE TABLE delegate(	
	no int NOT NULL,
	name varchar(30) NOT NULL,
	phone varchar(30) NULL,
	UNIQUE(no, name),
	CONSTRAINT pkDelegate PRIMARY KEY(no)
);

/*Link many student to many modules table*/
CREATE TABLE take(	
	delegateNo int NOT NULL,
	moduleCode char(2) NOT NULL,
	grade tinyint NULL,
	CONSTRAINT fkDelegateTake FOREIGN KEY(delegateNo) REFERENCES delegate(no),
	CONSTRAINT fkModuleTake FOREIGN KEY(moduleCode) REFERENCES module(code)
);

/*Sessions of module table*/
CREATE TABLE session(	
	moduleCode char(2) NOT NULL,
	`date` date NOT NULL,
	room varchar(30) NULL,
	CONSTRAINT pkSession PRIMARY KEY(`date`),
	CONSTRAINT fkModuleSession FOREIGN KEY(moduleCode) REFERENCES module(code)
);


/*POPULATE TABLES*/
/*Populate course table*/
INSERT INTO course(code, name, credits) VALUES('WSD', 'Web Systems Development', 75);
INSERT INTO course(code, name, credits) VALUES('DDM', 'Database Design & Management', 100);
INSERT INTO course(code, name, credits) VALUES('NSF', 'Network Security & Forensics', 75);

/*Populate module table*/
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('A2', 'ASP.NET', 250, 25, 'WSD');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('A3', 'PHP', 250, 25, 'WSD');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('A4', 'JavaFX', 350, 25, 'WSD');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('B2', 'Oracle', 750, 50, 'DDM');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('B3', 'SQLS', 750, 50, 'DDM');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('C2', 'Law', 250, 25, 'NSF');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('C3', 'Forensics', 350, 25, 'NSF');
INSERT INTO module(code, name, cost, credits, courseCode) VALUES('C4', 'Networks', 250, 25, 'NSF');

/*Populate delegate table*/
INSERT INTO delegate(no, name, phone) VALUES(2001, 'Mike', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2002, 'Andy', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2003, 'Sarah', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2004, 'Karen', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2005, 'Lucy', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2006, 'Steve', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2007, 'Jenny', NULL);
INSERT INTO delegate(no, name, phone) VALUES(2008, 'Tom', NULL);

/*Populate take link table*/
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2003, 'A2', 68);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2003, 'A3', 72);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2003, 'A4', 53);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2005, 'A2', 48);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2005, 'A3', 52);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2002, 'A2', 20);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2002, 'A3', 30);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2002, 'A4', 50);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2008, 'B2', 90);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2007, 'B2', 73);
INSERT INTO take(delegateNo, moduleCode, grade) VALUES(2007, 'B3', 63);

/*Populate session table*/
INSERT INTO session(moduleCode, `date`, room) VALUES('A2', '2021-06-05', 305);
INSERT INTO session(moduleCode, `date`, room) VALUES('A3', '2021-06-06', 307);
INSERT INTO session(moduleCode, `date`, room) VALUES('A4', '2021-06-07', 305);
INSERT INTO session(moduleCode, `date`, room) VALUES('B2', '2021-08-22', 208);
INSERT INTO session(moduleCode, `date`, room) VALUES('B3', '2021-08-23', 208);
INSERT INTO session(moduleCode, `date`, room) VALUES('A2', '2022-05-01', 303);
INSERT INTO session(moduleCode, `date`, room) VALUES('A3', '2022-05-02', 305);
INSERT INTO session(moduleCode, `date`, room) VALUES('A4', '2022-05-03', 303);
INSERT INTO session(moduleCode, `date`, room) VALUES('B2', '2022-07-10', NULL);
INSERT INTO session(moduleCode, `date`, room) VALUES('B3', '2022-07-11', NULL);


/*CREATE VIEW WITH ONLY FUTURE INSTANCES*/
DROP VIEW IF EXISTS futureSession;

CREATE VIEW futureSession AS
SELECT moduleCode, `date`, room
FROM session
WHERE `date` > CURDATE()
WITH CHECK OPTION;


/*CREATE FUNCTIONS*/
DROP PROCEDURE IF EXISTS scheduleModules;
DROP TABLE IF EXISTS gradeAudit;
DROP TRIGGER IF EXISTS gradeUpdated;

/*Audit table*/
CREATE TABLE gradeAudit(	
	id int NOT NULL AUTO_INCREMENT,
	`date` timestamp NOT NULL,
	user varchar(100) NOT NULL,
	delegateNo int NOT NULL, /*I'd add an id to take table and use that instead to get delegate and module*/
	oldGrade tinyint NOT NULL,
	newGrade tinyint NOT NULL,
	CONSTRAINT fkDelegateGradeAudit FOREIGN KEY(delegateNo) REFERENCES delegate(no),
	CONSTRAINT pkGradeAudit PRIMARY KEY(id)
);

DELIMITER $$

/*Procedure to schedule modules*/
CREATE PROCEDURE scheduleModules(IN codeInput char(3), IN dateInput date)
	BEGIN		
		DECLARE modCode char(2);
		DECLARE dayOfWeek int;
		DECLARE done BOOLEAN DEFAULT False;
		DECLARE moduleCur CURSOR FOR SELECT code FROM module WHERE courseCode = codeInput;
		DECLARE CONTINUE HANDLER FOR NOT FOUND set done = True;

		IF (dateInput <= DATE_SUB(NOW(), INTERVAL 1 MONTH)) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The start date must be at least a month in the future';
		END IF;

		IF (NOT EXISTS(SELECT code FROM course WHERE code = codeInput)) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Course code does not exist';
		END IF;

		OPEN moduleCur;

		readModule: LOOP
			FETCH moduleCur INTO modCode;

			IF done THEN
				LEAVE readModule;
			END IF;


			SET dayOfWeek = DAYOFWEEK(dateInput);
			IF (dayOfWeek = 1) THEN /*Skip sunday*/
				SET dateInput = DATE_ADD(dateInput, INTERVAL 1 DAY);
			ELSEIF (dayOfWeek = 7) THEN /*Skip saturdays*/
				SET dateInput = DATE_ADD(dateInput, INTERVAL 2 DAY);
			END IF;

			INSERT INTO session(moduleCode, `date`) VALUES(modCode, dateInput);
			SET dateInput = DATE_ADD(dateInput, INTERVAL 1 DAY);
		END LOOP readModule;

		CLOSE moduleCur;
	END $$

/*Log in as root, no password and: SET GLOBAL log_bin_trust_function_creators = 1; to be able to create triggers*/
/*Create audit trigger*/
CREATE TRIGGER gradeUpdated 
	AFTER UPDATE ON take FOR EACH ROW
		BEGIN
			IF (NEW.grade <> OLD.grade) THEN
				INSERT INTO gradeAudit(`date`, user, delegateNo, oldGrade, newGrade) VALUES(NOW(), USER(), NEW.delegateNo, OLD.grade, NEW.grade);
			END IF;
			
		END$$


DELIMITER ;


/**/
SELECT * FROM course;
SELECT * FROM delegate;
SELECT * FROM module;
SELECT * FROM take;
SELECT * FROM session;
SELECT * FROM futureSession;