CREATE TABLE ADMIN.COMPANY
(
	ID INTEGER,
	COMPANY_NAME CHARACTER VARYING(50)
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.COMPANYHEADQUARTER
(
	ID INTEGER,
	CODE CHARACTER VARYING(9),
	COMPANY INTEGER
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.PAYMENTREPORT
(
	ID INTEGER,
	FIRST_NAME CHARACTER VARYING(20),
	LAST_NAME CHARACTER VARYING(20),
	GENDER CHARACTER(1),
	AGE INTEGER,
	SALARY NUMERIC(8,2),
	COMPANY_HEADQUARTER INTEGER
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL2
(
	ID BIGINT,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (ID);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL2_BONUSCODE
(
	ID BIGINT,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (BONUSCODE);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL2_DATE
(
	ID BIGINT,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (DATE);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL2_REPORTID
(
	ID BIGINT,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (PAYMENT_REPORT);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL2_REPORTID2
(
	ID BIGINT,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (PAYMENT_REPORT);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_ALL_BONUSCODE
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (BONUSCODE);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_BONUSCODE
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (BONUSCODE);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_DATE
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (DATE);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_REPORTID
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (PAYMENT_REPORT);


CREATE TABLE ADMIN.PAYMENTREPORTDETAIL_REPORTID2
(
	ID INTEGER,
	BONUS NUMERIC(8,2),
	BONUSCODE INTEGER,
	DATE DATE,
	PAYMENT_REPORT INTEGER
)
DISTRIBUTE ON (PAYMENT_REPORT);


CREATE TABLE ADMIN.PAYMENTREPORT_AGE
(
	ID INTEGER,
	FIRST_NAME CHARACTER VARYING(20),
	LAST_NAME CHARACTER VARYING(20),
	GENDER CHARACTER(1),
	AGE INTEGER,
	SALARY NUMERIC(8,2),
	COMPANY_HEADQUARTER INTEGER
)
DISTRIBUTE ON (AGE);


CREATE TABLE ADMIN.PAYMENTREPORT_GENDER
(
	ID INTEGER,
	FIRST_NAME CHARACTER VARYING(20),
	LAST_NAME CHARACTER VARYING(20),
	GENDER CHARACTER(1),
	AGE INTEGER,
	SALARY NUMERIC(8,2),
	COMPANY_HEADQUARTER INTEGER
)
DISTRIBUTE ON (GENDER);


select distinct payment_report from paymentreportdetail
