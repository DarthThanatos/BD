/*
use northwind
select t.orderid,t.customerid
from (select orderid,customerid
	  from orders) as t
*/
/*
use northwind 
select productname, unitprice,
	   unitprice - (select avg(unitprice) from products) as difference
from products
*/
/*
use northwind
select productname, unitprice,
		(select avg(unitprice) from products) as average,
		unitprice - (select avg(unitprice) from products) as difference
from products
where unitprice > (select avg(unitprice) from products)
*/
/*
use northwind
select productname, unitprice,
		(select avg(unitprice) 
		from products as p_wew
		where p_zew.categoryid = p_wew.categoryid) as average
from products as p_zew
*/
/*
use northwind
select productname, unitprice,
		(select avg(unitprice) 
		from products as p_wew
		where p_zew.categoryid = p_wew.categoryid) as average
from products as p_zew
where unitprice > (select avg(unitprice) 
				  from products as p_wew
				  where p_zew.categoryid = p_wew.categoryid) 
*/
/*
--to jest Ÿle!
use northwind
select productid, (select max(unitsonorder) 
					  from products as wew	
					  where zew.productid = wew.productid
					  )
from products as zew
*/
/*
use northwind
select distinct productid, quantity
from [order details] as od1
where quantity = (select max(quantity)
				 from [order details] as od2
				 where od1.productid = od2.productid)
order by productid
*/
/*
use northwind 
select productid, max(quantity)
from [order details]
group by productid
order by productid
*/
/*
use northwind 
select lastname, employeeid
from employees as e
where exists (select *
			  from orders as o
			  where e.employeeid = o.employeeid and o.orderdate = '8/5/97')

use northwind 
select distinct lastname, e.employeeid
from orders as o
join employees as e
on e.employeeid = o.employeeid
where orderdate = '8/5/97'
*/
/*
use northwind
select lastname, employeeid
from employees as e
where e.employeeid in (select employeeid
					   from orders as o
					   where e.employeeid = o.employeeid and orderdate = '8/5/97')
*/
---------------------------------------------------------
--cw koncowe

--cw.1.1
/*
select companyname,phone
from customers
where customerid in (select customerid
					from orders 
					where shipvia = (select shipperid
									from shippers
									where companyname = 'United package')
					)
*/
--cw.1.2
--z joinem
/*
select companyname, phone, categoryname
from customers as c
join orders as o
on c.customerid = o.customerid
join [order details] as od
on od.orderid = o.orderid
join products as p
on p.productid = od.productid
join categories as ca
on p.categoryid = ca.categoryid
where categoryname = 'Confections'
*/

--cw.1.3 z join + in
/*
select companyname, phone
from customers 
where customerid not in
	(select c.customerid
	from customers as c
	join orders as o
	on c.customerid = o.customerid
	join [order details] as od
	on od.orderid = o.orderid
	join products as p
	on p.productid = od.productid
	join categories as ca
	on p.categoryid = ca.categoryid
	where categoryname = 'Confections'
	)
*/ 

--cw.2.1 group by
/*
select productid,max(quantity)
from [order details] 
group by productid
order by productid
*/
--z podzapytniem + group by
/*
select distinct productid, quantity
from [order details] as od1
where quantity = (select max(quantity)
				from [order details] as od2
				where od2.productid = od1.productid
				group by productid)
order by productid
*/
--cw.2.2
/*
select productname,unitprice
from products 
where unitprice < (select avg(unitprice)
					from products)
*/
/*
select avg(unitprice)
from products
group by categoryid
*/
/*
select productname,unitprice
from products as p1 
where unitprice < (select avg(unitprice)
					from products as p2
					where p2.categoryid = p1.categoryid
					group by categoryid)
*/
/*
select avg(unitprice)
from products
where categoryid = 1
group by categoryid
*/
/*
use northwind;
with cat_srednia as (select categoryid, avg(unitprice) as sr 
					from products 
					group by categoryid)
--common table expressions, with
select productname, unitprice, sr, unitprice  - sr as roznica 
from cat_srednia join products
on cat_srednia.categoryid =products.categoryid
where unitprice > sr
order by productname
*/

--cw.2.1
/*
select productname, unitprice, (select avg(unitprice) from products) as aver, unitprice - (select avg(unitprice) from products) as difference
from products
*/

--cw.2.2
/*
select productname, 
	   (select categoryname
	    from categories as ca
		where zew.categoryid = ca.categoryid), 
	   (select avg(unitprice) 
	   from products as wew 
	   where zew.categoryid = wew.categoryid 
	   group by categoryid),
	   unitprice - (select avg(unitprice) 
	   from products as wew 
	   where zew.categoryid = wew.categoryid 
	   group by categoryid) as difference,
	   unitprice
from products as zew
*/

--cw.3.1
/*
select sum(unitprice * quantity * (1-discount)) +  
		(select freight from orders where orderid = 10250) 
from [order details]
where orderid = 10250
group by orderid
*/

--cw.3.2
/*
select orderid,sum(unitprice * quantity * (1-discount)) +  
		(select freight from orders as o where od.orderid = o.orderid ) 
from [order details] as od
group by orderid
*/

--cw.3.3
/*
select customerid,address
from customers 
where customerid not in (select customerid from orders where year(orderdate)=1997)
*/

--cw.3.4
/*
select distinct productid
from [order details] as od
where (select count(distinct c1.customerid)
		from customers as c1 
		join orders as o1
		on c1.customerid = o1.customerid
		join [order details] as od1
		on od1.orderid = o1.orderid
		where od.productid = od1.productid
		group by productid) > 1
*/

--cw.4.1

select firstname,lastname,sum(quantity*unitprice*(1-discount)) + (select max( freight) from orders as o1 where o1.employeeid = e.employeeid )
from employees as e
join orders as o
on o.employeeid = e.employeeid
join [order details] as od
on o.orderid = o.orderid
group by firstname,lastname,e.employeeid

--cw.4.2

select top 1 firstname,lastname,sum(quantity*unitprice*(1-discount)) + (select max( freight) from orders as o1 where o1.employeeid = e.employeeid )
from employees as e
join orders as o
on o.employeeid = e.employeeid
join [order details] as od
on o.orderid = o.orderid
where year(orderdate)=1997
group by firstname,lastname,e.employeeid
order by 3 desc

--cw.4.3 dla b) not exists
select firstname,lastname, e.employeeid,sum(quantity*unitprice*(1-discount)) + (select max( freight) from orders as o1 where o1.employeeid = e.employeeid )
from employees as e
join orders as o
on o.employeeid = e.employeeid
join [order details] as od
on o.orderid = o.orderid
where exists (select employeeid
			  from employees as e2
			  where e2.reportsto = e.employeeid)
group by firstname,lastname,e.employeeid
/*
--wybranie pracownikow bez podwladnych
select employeeid
from employees as e1
where not exists (select employeeid
			  from employees as e2
			  where e2.reportsto = e1.employeeid)
*/
--cw.4.4
--znowu: b) not exists
select firstname,
	   lastname, 
	   e.employeeid,
	   sum(quantity*unitprice*(1-discount)) + (select max( freight) from orders as o1 where o1.employeeid = e.employeeid ) value
	   ,(select top 1 orderdate from orders as o1 where o1.employeeid = o.employeeid order by 1 desc ) as 'ostatnie zamowienie'
from employees as e
join orders as o
on o.employeeid = e.employeeid 
join [order details] as od
on o.orderid = od.orderid
where not exists (select employeeid
			  from employees as e2
			  where e2.reportsto = e.employeeid) 
group by firstname,lastname,e.employeeid,o.employeeid
