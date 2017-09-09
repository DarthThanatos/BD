-- cw.1.1 Charles Dickens 
/*
select isbn,
(select title from title where title.title_no = item.title_no ) as title
from item
*/

-- cw.1.2
/*
select title
from title 
where title_no = 10
 */

 --cw.1.3
 /*
select member_no,fine_assessed 
from loanhist 
where fine_assessed between 8 and 9
*/

--cw.1.4
/*
select isbn, 
	(select author 
	from title
	where   title.title_no = item.title_no) as author
from item
where 
	(select author
	from title
	where title.title_no = item.title_no
	) = 'Charles Dickens' or
	(select author
	from title
	where title.title_no = item.title_no
	)  = 'Jane Austen'
*/
/*
select author,
	(select title_no
	from item
	where title.title_no = item.title_no) as isbn
from title
where author = 'Charles Dickens' or author = 'Jane Austen'
*/
--cw.1.5
/*
select title_no, title
from title
where title like '%adventures%'
*/
--cw.1.6
/*
select member_no,fine_assessed, fine_paid
from loanhist
where fine_assessed is not null and fine_paid is not null and fine_paid != fine_assessed
*/
--cw.1.7
/*
use library 

select distinct city,state
from adult
*/
--cw.2.1
/*
select title 
from title
order by 1
*/
--cw.2.2
/*
select member_no,isbn,fine_assessed,(2*fine_assessed) as 'double fine'
from loanhist
where fine_assessed is not null and fine_assessed != 0.0
*/
--cw.2.3
/*
select lower(firstname + middleinitial + substring(lastname,0,2))  as email_name
from member
where lastname = 'Anderson'
*/
--cw.2.4
/*
select 'The title is: ' + title + ', title number ' + convert (varchar,title_no)
from title
*/
--cw.dodatkowe
/*
select orderid, orderdate,shippeddate,isnull(convert(varchar,datediff(d,orderdate,shippeddate)),'not shipped') as difference, datediff(m,orderdate,getdate())  as 'difference with today'
from orders
*/
--agregujace - w ramach kolumny
/*select 
top 5  with ties -- pierwsze 5 rowne ostatniemu
orderid, productid,quantity --wybiera 5 elementow
from [order details]
order by quantity desc*/
/*
select count ('cokolwiek')
from employees 

select count (reportsto)
from employees

select count (*)
from products
where  unitprice between 10 and 20
*/
--wybieranie maks
/*
use northwind
select max (unitprice)
from products 
where unitprice < 20
*/
--drugi wariant wybierania maks
/*
select top 1 unitprice
from products 
where unitprice < 20
order by 1 desc
*/
--piate
/*
select sum(unitprice * quantity * (1-discount))
from [order details]
where orderid = 10250
*/
/*
select * 
from orderhist
*/
--czwarte
/*
select *
from products
where (select avg(unitprice) from products) < unitprice
*/
--trzecie
/*
select max(unitprice),min(unitprice),avg(unitprice)
from products
where quantityperunit like '%bottles'
*/
/*
select  productid,sum(quantity)
from [order details]
group by productid
*/
--pierwsze_dwa
/*
select productid,max(unitprice)
from [order details]
group by productid
order by 2
*/
--drugie_dwa
/*
select productid, max(unitprice),min(unitprice)
from [order details]
group by productid
*/

/*
select shipname,count(*)
from orders
where shipname = 'Vins et alcools Chevalier'
group by shipname
*/

--trzecie_dwa
/*
select shipname,count(*)
from orders
group by shipname
order by 2 desc
*/
--najaktywniejszy sped w '97
/*
select top 1 shipname,count(*)
from orders
where year(shippeddate) = 1997
group by shipname
order by 2 desc
*/
/*
SELECT productid, SUM(quantity) AS total_quantity
FROM [order details]
GROUP BY productid
HAVING SUM(quantity)>1200
*/
--jeden_trzy
/*
select orderid,count(*) 
from [order details]
group by orderid
having count(*) > 5
*/
--dwa_trzy
/*
select customerid,count(*)
from [orders]
where year(shippeddate) = 1998
group by customerid
having count(*) > 8
order by Sum(freight) desc
*/
/*
SELECT orderid,productid, SUM(quantity) AS total_quantity
FROM [order details]
WHERE orderid < 10250
GROUP BY orderid,productid
ORDER BY orderid,productid
*/
/*
SELECT orderid, productid, SUM(quantity) AS total_quantity
FROM [order details]
WHERE orderid < 10250
GROUP BY orderid, productid
with rollup
ORDER BY orderid, productid
*/
/*
SELECT orderid, GROUPING (orderid)
,productid, GROUPING (productid)
,SUM(quantity) AS total_quantity
FROM [order details]
WHERE orderid < 10250
GROUP BY orderid, productid
WITH CUBE 
ORDER BY orderid, productid
*/
/*
select productid, orderid,sum(quantity) as total_q
from orderhist
group by productid,orderid
with rollup
order by productid,orderid
*/
/*
SELECT productid, orderid,quantity 
FROM orderhist
ORDER BY productid, orderid
COMPUTE SUM(quantity)
--nie wykona sie po wersji 2008
*/
--cw.kon.2.1.1
/*
select orderid,sum(unitprice * quantity * (1-discount))
from [order details]
group by orderid
order by sum(unitprice * quantity * (1-discount)) desc
*/
--cw.kon.2.1.2 i 3
/*
select top 10 with ties orderid,sum(unitprice * quantity * (1-discount)) as suma 
from [order details]
group by orderid
order by suma desc
*/
--cw.kon.2.2.1
/*
select productid, sum(quantity) as suma
from [order details]
where productid < 3
group by productid
*/
--cw.kon.2.2.2
/*
select top 1 sum(quantity) as suma
from [order details]
group by productid
with rollup
order by productid
*/
--cw.kon.2.2.3
/*
select orderid, sum(unitprice * quantity * (1-discount)) as value,sum(quantity) as [products amount]
from [order details]
group by orderid
having sum(quantity) > 250
*/
--cw.kon.2.3.1 i 2
/*
select  orderid, productid, sum(quantity)
from [order details]
where productid = 50
group by orderid,productid
with rollup
*/
--cw.kon.2.3.4
/*
select grouping(orderid), grouping(productid), sum(quantity)
from [order details]
group by orderid,productid
with cube
*/
/*
USE joindb
SELECT buyer_name, s.buyer_id, qty
FROM buyers as b, sales as s
WHERE b.buyer_id = s.buyer_id
*/
--inner join - krotki niedopasowane nie s¹ do³¹czane do zbioru wynikowego (s¹ wyrzucane)
-- samo join to to samo co inner join - kwestia konwencji
/*
USE joindb 
SELECT b.buyer_name AS [b.buyer_name], b.buyer_id AS [b.buyer_id], s.buyer_id AS [s.buyer_id], qty AS [s.qty]
 FROM buyers AS b, sales AS s
 where b.buyer_name = 'Adam Barr'*/
 use library
  select *
  from loanhist
  where fine_waived is not null