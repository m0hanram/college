USE 19PW;

CREATE TABLE EMPLOYEES 
(
	EMPLOYEE_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(30),
    LAST_NAME VARCHAR(20),
    EMAIL VARCHAR(30),
    PHONE_NUMBER NUMERIC(10),
    HIRE_DATE DATE,
    JOB_ID INT,
    SALARY NUMERIC(8,2),
    COMMISSION_PCT NUMERIC(3,2),
    MANAGER_ID INT,
    DEPARTMENT_ID INT,
    FOREIGN KEY E1 (MANAGER_ID) REFERENCES EMPLOYEES (EMPLOYEE_ID)
);

CREATE TABLE REGIONS
(
	REGION_ID INT PRIMARY KEY,
    REGION_NAME VARCHAR(20)
);

CREATE TABLE COUNTRIES
(
	COUNTRY_ID INT PRIMARY KEY,
    COUNTRY_NAME VARCHAR(20),
    REGION_ID INT,
    FOREIGN KEY (REGION_ID) REFERENCES REGIONS (REGION_ID)
);

CREATE TABLE LOCATIONS 
(
	LOCATION_ID INT PRIMARY KEY,
    STREET_ADDRESS VARCHAR(20),
    POSTAL_CODE VARCHAR(20),
    CITY VARCHAR(20),
    STATE_PROVINCE VARCHAR(20),
    COUNTRY_ID INT,
    FOREIGN KEY (COUNTRY_ID) REFERENCES COUNTRIES (COUNTRY_ID)
);

CREATE TABLE DEPARTMENTS
(
	DEPARTMENT_ID INT PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR(20),
    MANAGER_ID INT,
    LOCATION_ID INT,
    FOREIGN KEY (MANAGER_ID) REFERENCES EMPLOYEES (EMPLOYEE_ID),
    FOREIGN KEY (LOCATION_ID) REFERENCES LOCATIONS (LOCATION_ID)
);

CREATE TABLE JOBS
(
	JOB_ID INT PRIMARY KEY,
    JOB_TITLE VARCHAR(20),
    MIN_SALARY NUMERIC(8,2),
    MAX_SALARY NUMERIC(8,2)
);

CREATE TABLE JOB_HISTORY
(
	EMPLOYEE_ID INT,
    START_DATE DATE,
    END_DATE DATE,
    JOB_ID INT,
    DEPARTMENT_ID INT,
    PRIMARY KEY(EMPLOYEE_ID,START_DATE),
    FOREIGN KEY (JOB_ID) REFERENCES JOBS (JOB_ID),
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS (DEPARTMENT_ID)
);

ALTER TABLE EMPLOYEES ADD CONSTRAINT E2 FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS (DEPARTMENT_ID);  
ALTER TABLE EMPLOYEES ADD CONSTRAINT E3 FOREIGN KEY (JOB_ID) REFERENCES JOBS (JOB_ID);


DELIMITER //
CREATE PROCEDURE P1()
BEGIN
	DECLARE EXP INT DEFAULT 0;
    SET EXP = (SELECT TIMESTAMPDIFF(YEAR,HIRE_DATE,CURRENT_TIMESTAMP) FROM EMPLOYEES WHERE EMPLOYEE_ID=115);
    IF EXP>10 THEN
		UPDATE EMPLOYEES SET SALARY=SALARY*1.02 WHERE EMPLOYEE_ID=115;
	ELSEIF EXP>5 THEN
		UPDATE EMPLOYEES SET SALARY=SALARY*1.01 WHERE EMPLOYEE_ID=115;
	ELSE 
		UPDATE EMPLOYEES SET SALARY=SALARY*1.05 WHERE EMPLOYEE_ID=115;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE W9P2()
BEGIN
	DECLARE SALARY DECIMAL(8,2) DEFAULT 0;
    DECLARE EXP INT DEFAULT 0;
    SET EXP = (SELECT TIMESTAMPDIFF(YEAR,HIRE_DATE,CURRENT_TIMESTAMP));
    SET SALARY = (SELECT SALARY FROM EMPLOYEES WHERE EMPLOYEE_ID=150);
    IF SALARY>10000 THEN
		UPDATE EMPLOYEES SET COMMISSION=0.4 WHERE EMPLOYEE_ID=150;
	ELSEIF SALARY<10000 AND EXP>10 THEN
		UPDATE EMPLOYEES SET COMMISSION=0.35 WHERE EMPLOYEE_ID=150;
	ELSEIF SALARY<3000 THEN
		UPDATE EMPLOYEES SET COMMISSION=0.25 WHERE EMPLOYEE_ID=150;
	ELSE
		UPDATE EMPLOYEES SET COMMISSION=0.15 WHERE EMPLOYEE_ID=150;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE W9P3()
BEGIN 
	DECLARE ID INT DEFAULT 0;
    DECLARE DEPTNAME VARCHAR(20);
    SET ID = (SELECT MANAGER_ID FROM EMPLOYEES WHERE EMPLOYEE_ID=103);
    SET DEPTNAME= (SELECT DEPARTMENT_NAME FROM departments WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM employees WHERE EMPLOYEE_ID=ID));
    SELECT CONCAT(FIRST_NAME,LAST_NAME) AS 'NAME',DEPTNAME FROM EMPLOYEES WHERE EMPLOYEE_ID=ID;
END //
DELIMITER ;
CALL W9P3;

DELIMITER //
CREATE FUNCTION W9F1(ID INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE JOBNO INT DEFAULT 0;
    SET JOBNO = (SELECT COUNT(JOB_ID) FROM job_history WHERE EMPLOYEE_ID=ID GROUP BY EMPLOYEE_ID);
    RETURN JOBNO;
END //
DELIMITER ;
SELECT W9F1(100);

DELIMITER //
CREATE TRIGGER W9T1
BEFORE UPDATE
ON EMPLOYEES FOR EACH ROW
BEGIN
	DECLARE ERMSG VARCHAR(100);
    SET ERMSG='CHANGES CANT BE MADE BEFORE 6 AM AND AFTER 10PM';
    IF (SELECT 1 WHERE CURRENT_TIME BETWEEN '22:00:00' AND '06:00:00') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERMSG;
	END IF;
END //
DELIMITER ;

create table customer(customerid varchar(5) primary key,customername varchar(30) unique,dateofbirth date,gender char,city varchar(30),constraint c1 check(customerid like 'C%'),constraint c2 check(customername Regexp '[A-Z]'),constraint c3 check(year(dateofbirth)>1970),constraint c4 check(gender in ('M','F')),constraint c5 check(city regexp '^[A-Z][:word]*'));

DELIMITER //
CREATE FUNCTION W9F2(ID INT)
RETURNS CHAR
DETERMINISTIC
BEGIN
	DECLARE SALARY DECIMAL(8,2) DEFAULT 0;
		SET SALARY = (SELECT SALARY FROM EMPLOYEES WHERE EMPLOYEE_ID=ID);
        IF (SELECT EXISTS(SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID=ID)) THEN
        IF SALARY=30000 OR SALARY<30000 THEN
			RETURN 'A';
		ELSEIF SALARY>30000 AND (SALARY<60000 OR SALARY=60000) THEN
			RETURN 'B';
		ELSEIF SALARY>60000 THEN
			RETURN 'C';
		ELSEIF SALARY=0 THEN
			RETURN NULL;
		END IF;
        ELSE
			RETURN NULL;
        END IF;
END //
DELIMITER ;
SELECT W9F2(100);

