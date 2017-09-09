select count(*) from ORDERS
select count(*) from LINEITEM

select l_orderkey, l_quantity, l_shipdate, l_linestatus 
from lineitem
limit 10

select distinct l_linestatus from lineitem

CREATE TABLE ADMIN.LINEITEM_ORDERKEY
(
	L_ORDERKEY INTEGER NOT NULL,
	L_PARTKEY INTEGER NOT NULL,
	L_SUPPKEY INTEGER NOT NULL,
	L_LINENUMBER INTEGER NOT NULL,
	L_QUANTITY NUMERIC(15,2) NOT NULL,
	L_EXTENDEDPRICE NUMERIC(15,2) NOT NULL,
	L_DISCOUNT NUMERIC(15,2) NOT NULL,
	L_TAX NUMERIC(15,2) NOT NULL,
	L_RETURNFLAG CHARACTER(1) NOT NULL,
	L_LINESTATUS CHARACTER(1) NOT NULL,
	L_SHIPDATE DATE NOT NULL,
	L_COMMITDATE DATE NOT NULL,
	L_RECEIPTDATE DATE NOT NULL,
	L_SHIPINSTRUCT CHARACTER(25) NOT NULL,
	L_SHIPMODE CHARACTER(10) NOT NULL,
	L_COMMENT CHARACTER VARYING(44) NOT NULL
)
DISTRIBUTE ON (L_ORDERKEY);

create table lineitem lineitem_random as 
select * from labdb.admin.LINEITEM
distribute on random

select datasliceid, count(*) from lineitem_random group by datasliceid 

select datasliceid, count(*) from lineitem group by datasliceid

select count(distinct l_shipdate) from lineitem

create table LINEITEM_SHIPDATE as 
select * from ladb.admin.lineitem
distribute on (l_shipdate)

select datasliceid, count(*) 
from LINEITEM_SHIPDATE
group by DATASLICEID

/*8*/
select l_linestatus, sum(l_extendedprice)
from labdb.LABADMIN.lineitem
group by l_linestatus /*1,242 sec*/

select l_linestatus, sum(l_extendedprice)
from LINEITEM_RANDOM
group by l_linestatus /*0,264 sec*/

select l_linestatus, sum(l_extendedprice)
from lineitem_shipdate
group by l_linestatus /*0,268 sec*/


/*9, 1,346 sec*/
select sum(l_extendedprice)
from lineitem
where l_shipdate = '1996-03-29'

/*0,299 sec*/
select sum(l_extendedprice)
from lineitem_random
where l_shipdate = '1996-03-29'

/*0,180 sec*/
select sum(l_extendedprice)
from lineitem_shipdate
where l_shipdate = '1996-03-29'

/*10*/
explain verbose select avg(o.o_totalprice) as price,
avg(l.l_quantity) as quantity, o_orderpriority
from orders as o, lineitem as l 
where l.l_orderkey = o.o_orderkey
group by o_orderpriority

create table lineitem_orderkey as 
select * from labdb.admin.lineitem 
distribute on (l_orderkey)

create table orders_orderkey as
select * from labdb.admin.orders 
distribute on (o_orderkey)

explain verbose select avg(o.o_totalprice) as price,
avg(l.l_quantity) as quantity, o_orderpriority
from orders_orderkey as o, lineitem_orderkey as l 
where l.l_orderkey = o.o_orderkey
group by o_orderpriority


/*czesc druga*/

select count(*) from paymentreport
select count(*) from paymentreportdetail
select count(*) from company
select count(*) from COMPANYHEADQUARTER
select count(*) from PAYMENTREPORT_AGE
select count(*) from PAYMENTREPORT_GENDER
select count(*) from PAYMENTREPORTDETAIL_ALL
select count(*) from PAYMENTREPORTDETAIL_ALL_BONUSCODE
select count(*) from PAYMENTREPORTDETAIL_ALL2
select count(*) from PAYMENTREPORTDETAIL_ALL2_BONUSCODE

select datasliceid, count(datasliceid) as "rows"
from paymentreport
group by datasliceid
order by 1

select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORT_GENDER
group by datasliceid
order by 1


select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORT_AGE
group by datasliceid
order by 1

create table PAYMENTREPORT_AGE
as select * from db.admin.PAYMENTREPORT
distribute on(age)

create table PAYMENTREPORT_GENDER
as select * from db.admin.PAYMENTREPORT
distribute on(gender)

select gender, avg(salary)
from PAYMENTREPORT
group by gender

select age, avg(salary)
from PAYMENTREPORT 
group by age
order by 1


select age, avg(salary)
from PAYMENTREPORT_age
group by age
order by 1

select age, avg(salary)
from PAYMENTREPORT_gender
group by age
order by 1

select gender, avg(salary)
from PAYMENTREPORT_age
group by gender

select gender, avg(salary)
from PAYMENTREPORT_gender
group by gender


select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDETAIL_ALL
group by DATASLICEID
order by 1

select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDETAIL_ALL_BONUSCODE
group by DATASLICEID
order by 1

select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDETAIL_ALL2
group by DATASLICEID
order by 1


select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDETAIL_ALL2_BONUSCODE
group by DATASLICEID
order by 1

select date, sum(bonus)
from PAYMENTREPORTDETAIL_ALL
group by date

select bonuscode, sum(bonus)
from PAYMENTREPORTDETAIL_REPORTID
group by bonuscode

select bonuscode, sum(bonus)
from PAYMENTREPORTDETAIL_ALL_BONUSCODE
group by bonuscode

create table paymentreportdetail_reportid2
as select * from db.admin.paymentreportdetail
order by date 
distribute on (payment_report)

select bonuscode, sum(bonus)
from paymentreportdetail_reportid2 
where date = '2015-10-20'
group by bonuscode

select count(distinct payment_report) from PAYMENTREPORTDETAIL
select count(distinct date) from PAYMENTREPORTDETAIL

select datasliceid, count(datasliceid) as "rows"
from U_BIELAS_A.U_Bielas.PAYMENTREPORTDETAIL_REPORTID2
group by datasliceid
order by 1
select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDETAIL_REPORTID
group by datasliceid
order by 1
select datasliceid, count(datasliceid) as "rows"
from PAYMENTREPORTDetail_date
group by datasliceid
order by 1

select bonuscode, sum(bonus)
from paymentreportdetail_reportid
where date = '2015-10-20'
group by bonuscode

select bonuscode, sum(bonus)
from paymentreportdetail_date
where date = '2015-10-20'
group by bonuscode

select bonuscode, sum(bonus)
from paymentreportdetail_all
where date = '2015-10-20'
group by bonuscode

select bonuscode, sum(bonus)
from paymentreportdetail_all2
where date = '2015-10-20'
group by bonuscode

explain verbose select company_headquarter, sum(bonus)
from paymentreportdetail as pd join PAYMENTREPORT as p
on pd.payment_report = p.id
group by company_headquarter 

explain verbose select company_headquarter, sum(bonus)
from paymentreportdetail_reportid as pd join PAYMENTREPORT as p
on pd.payment_report = p.id
group by company_headquarter

explain verbose select c.company_name, sum(bonus)
from paymentreportdetail_reportid as pd join paymentreport as p
on pd.payment_report = p.id join companyheadquarter as ch 
on ch.id = p.company_headquarter  join company as c 
on c.id = ch.company 
group by c.company_name

explain verbose select c.company_name, sum(bonus)
from paymentreportdetail as pd join paymentreport as p
on pd.payment_report = p.id join companyheadquarter as ch 
on ch.id = p.company_headquarter  join company as c 
on c.id = ch.company 
group by c.company_name

explain verbose select * from PAYMENTREPORTDETAIL_ALL2
where id = 10

explain verbose select * from PAYMENTREPORTDETAIL_ALL2
where id between  1000000 and 1000050

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


