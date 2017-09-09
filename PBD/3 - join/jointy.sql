use joindb
/*
select buyer_name, sales.buyer_id,qty
from buyers,sales
where buyers.buyer_id = sales.buyer_id
*/
/*
select * from sales
select * from buyers
*/
/*
select buyer_name, S.buyer_id,qty
from buyers as b, sales as s
where b.buyer_id = s.buyer_id
-- to samo co
select buyer_name,s.buyer_id,qty
from buyers as b inner join sales as s
on b.buyer_id = s.buyer_id
*/
/*
select b.buyer_name as [b.buyer_name],
	   b.buyer_id as [b.buyer_id],
	   s.buyer_id as [s.buyer_id],
	   qty as [s.qty]
from buyers as b , sales as s
where s.buyer_id = b.buyer_id
	  and
	  b.buyer_name = 'Adam Barr'
	-- ten warunek robi sens  z iloczynu kartezjanskiego
*/

use Northwind
/*
select productname, s.companyname
from products as p, suppliers as s
where p.supplierid = s.SupplierID
*/
/*
select orderdate
from orders
where orderdate > '1998-03-01'
--wazne!!! data
*/
/*
select distinct c.companyname
from customers as c, orders as o
where c.customerid = o.customerid
	  and
	  o.orderdate > '1998-03-01'
*/
/*
select distinct companyname
from orders inner join customers
on orders.customerid = customers.CustomerID
where orderdate > '3/1/98'
*/

use joindb
/*
select * from buyers
select * from sales

select buyer_name, sales.buyer_id,qty
from buyers left outer join sales
on buyers.buyer_id = sales.buyer_id
*/
/*
select customers.companyname,orders.orderdate
from customers left outer join orders
on orders.customerid = customers.customerid
*/

use northwind
/*
select productid, productname, companyname
from products
inner join suppliers
on products.supplierid = suppliers.supplierid
*/
/*
USE joindb
SELECT buyer_name, sales.buyer_id, qty
FROM buyers  LEFT OUTER JOIN sales
ON buyers.buyer_id = sales.buyer_id
*/
--cw.1.1
use library
/*
select m.firstname, m.lastname, j.birth_date
from member as m join juvenile  as j
on m.member_no = j.member_no
*/
--cw.1.2
/*
select distinct t.title
from copy as c join title as t
on c.title_no = t.title_no
where c.on_loan = 'Y'
*/
/*
--cw.1.3
select out_date, t.title,l.out_date,l.due_date,datediff(day,l.out_date,l.due_date) as [date diff], l.fine_assessed
from loanhist as l join title as t
on l.title_no = t.title_no and title = 'Tao Teh King'
where l.fine_assessed is not null and l.fine_assessed != 0
*/
 --cw.1.4
 /*
 select r.isbn, m.lastname,m.firstname,m.middleinitial
 from member as m join reservation as r
 on m.member_no = r.member_no
 where m.lastname = 'Graff' and  m.firstname = 'Stephen'and m.middleinitial = 'A'
 */
 --cw.2.1
 /*
 use northwind
 select p.unitprice, p.productname,s.address
 from products as p join suppliers as s
 on p.supplierid = s.supplierid
 where p.unitprice between 20 and 30
 */
 --cw 2.2
 /*
 use northwind
 select p.productname, p.unitsinstock, s.companyname
 from products as p join suppliers as s
 on p.supplierid = s.supplierid
 where s.companyname = 'Tokyo Traders'
 */
 /*
 --cw.2.3
 use northwind
 select *
 --select companyname, orderdate
 from customers as c left outer join orders as o
 on o.customerid = c.customerid and YEAR(o.orderdate) = 1997
where o.orderid is null 
 use northwind
 */
/*
 select c.customerid,o.orderid
 from customers as c left join orders as o
 on o.customerid = c.customerid and YEAR(o.orderdate) = 1997
 order by 1
 */
--Czy s¹ jacyœ klienci którzy nie z³o¿yli ¿adnego zamówienia w 1997 roku, jeœli tak to poka¿ ich dane adresowe
/*use northwind
select companyname, orderdate
from customers left join 
(select * from orders where year(orderdate) = 1997) as o
on customers.customerid  = o.customerid
where orderid is null
*/
--cw.2.4
/*
select * 
from suppliers as s join products as p
on s.supplierid = p.supplierid 
where unitsinstock = 0
*/
/*
USE joindb
select buyer_name, prod_name,qty
from buyers
inner join sales
on buyers.buyer_id = sales.buyer_id
inner join produce
on sales.prod_id = produce.prod_id
*/
/*
use northwind
select distinct orderdate,productname
from products as p inner join [order details] as od
on p.productid = od.productid
inner join orders as o
on od.orderid = o.orderid
where orderdate = '7/8/96'
*/

--cw.3.1
/*
use northwind
select distinct productname, p.unitprice,categoryname, companyname,address
from products as p inner join suppliers as s
on p.supplierid = s.supplierid
inner join categories as c
on p.categoryid = c.categoryid 
where categoryname = 'Meat/Poultry' and (p.unitprice between 20 and 30)
*/
use northwind
--cw.3.2
/*
select productname, unitprice, companyname
from products as p inner join suppliers as s
on p.supplierid = s.supplierid
inner join categories as c
on c.categoryid = p.productid 
where categoryname = 'Confections'
*/
--cw.3.3
/*
select c.companyname, c.phone
from customers as c join orders as o 
on c.customerid = o.customerid
inner join shippers as s
on o.shipvia = s.shipperid
where year(orderdate) = 1997 and s.companyname = 'United Package'
*/
--cw.3.4
/*
select distinct c.phone,c.companyname
from customers as c inner join orders as o
on c.customerid = o.customerid
inner join [order details] as od
on od.orderid = o.orderid
inner join products as p
on p.productid = od.productid
inner join categories as ca
on ca.categoryid = p.categoryid
where categoryname = 'Confections'
*/
--cw.4.1
/*
use library
select m.firstname, m.lastname,j.birth_date, a.street
from member as m inner join juvenile as j
on m.member_no = j.member_no
inner join adult as a
on j.adult_member_no = a.member_no
*/
--cw.4.2
/*
use library
select  m.firstname, 
		m.lastname,
		j.birth_date, 
		a.street, 
		(select lastname 
		from member 
		where j.adult_member_no = member_no) as parent_lastname,
		(select firstname
		from member 
		where j.adult_member_no = member_no) as parent_firstname
from member as m inner join juvenile as j
on m.member_no = j.member_no
inner join adult as a
on j.adult_member_no = a.member_no
*/
/*
USE joindb

SELECT b1.buyer_name AS buyer1, 
	   p.prod_name, 
	   b2.buyer_name AS buyer2
FROM sales AS a
JOIN sales AS b
ON a.prod_id = b.prod_id
join buyers as b1
on b1.buyer_id = a.buyer_id
join buyers as b2
on b2.buyer_id = b.buyer_id
join produce as p
on p.prod_id = a.prod_id
WHERE  a.buyer_id < b.buyer_id
*/
/*
use northwind
select a.employeeid,b.employeeid
from employees as a join employees as b
on a.title = b.title
where a.employeeid > b.employeeid

SELECT a.employeeid, LEFT(a.lastname,10) AS name
,LEFT(a.title,10) AS title
,b.employeeid, LEFT(b.lastname,10) AS name
,LEFT(b.title,10) AS title
FROM employees AS a
INNER JOIN employees AS b
ON a.title = b.title
WHERE a.employeeid < b.employeeid
*/
--cw.5.1
/*
use northwind
select a.lastname, count(*) 
 from employees as a left join employees as b
 on a.employeeid = b.reportsto
 join orders as o1 
 on o1.employeeid = a.employeeid
 where b.employeeid is null
 group by a.lastname, a.employeeid
 */
 /*
--cw.5.2
use northwind
select a.employeeid 
 from employees as a left join employees as b
 on a.employeeid = b.reportsto
 where b.employeeid is null
 */
 --cw.5.3
 /*
 use library
 select *
 from adult as a join juvenile as j
 on j.adult_member_no = a.member_no and j.birth_date < '1/1/96'
 */
 --cw.5.4

use library
 /*
 select *
 from adult as a join juvenile as j
 on j.adult_member_no = a.member_no 
 and j.birth_date < '1/1/96'
 join loan as l
 on l.member_no = a.member_no 
 and a.member_no in (select m.member_no
	from member as m left join loan as l
	on m.member_no = l.member_no
	where copy_no is null)

select m.member_no
from member as m left join loan as l
on m.member_no = l.member_no
where copy_no is null 
 */
 /*
 USE northwind
SELECT (firstname + ' ' + lastname) AS name ,city, postalcode
FROM employees
union
SELECT companyname, city, postalcode
FROM customers
*/
--cw.6.1
use library
/*
select m.lastname + ' ' + m.firstname as name
from member as m join juvenile as j
on m.member_no = j.member_no
union
select a.street
from adult as a join member as m
on m.member_no = a.member_no
*/
--cw.6.2
/*
select firstname, lastname 
from member 
where member_no in (250,342,1675)
union
select convert (varchar(19),isbn), convert(VARCHAR(19),log_date) as data
from reservation
*/
--cw.6.3
/*
use library
select m.firstname,m.lastname,count(j.member_no) as children_amount
from adult as a left join juvenile as j 
on a.member_no = j.adult_member_no
join member as m
on m.member_no = a.member_no
where a.state = 'AZ'
group by m.firstname,m.lastname
having count(j.member_no)>2
 */

--drugi wariant
/*
select m.lastname, m.firstname,count(*)
from member as m join adult a 
on m.member_no = a.member_no
join juvenile as j
on j.adult_member_no = m.member_no
where state = 'AZ'
group by m.member_no, m.lastname, m.firstname
having count(*) > 2
*/
 --cw.6.4 - z union
/*
 select a.member_no,count(j.member_no) 
from adult as a left join juvenile as j 
on a.member_no = j.adult_member_no
where a.state = 'AZ'
group by a.member_no
having count(j.member_no)>2
union
select a.member_no,count(j.member_no) 
from adult as a left join juvenile as j 
on a.member_no = j.adult_member_no
where a.state = 'CA'
group by a.member_no
having count(j.member_no)>3
*/

use northwind
--cw.7.1
/*
select categoryname,sum(quantity) as units, cu.companyname
from customers as cu join orders as o
on cu.customerid = o.customerid
join [order details] as od
on od.orderid = o.orderid
join products as p
on p.productid = od.productid
join categories as ca
on ca.categoryid  = p.categoryid
group by categoryname, companyname
*/

--cw.7.2 i 7.3
/*
select od.orderid, sum(od.quantity) as 'sum of quantity',cu.companyname
from customers as cu join orders as o
on cu.customerid = o.customerid
join [order details] as od
on od.orderid = o.orderid
group by od.orderid,cu.companyname
having sum(od.quantity) > 250
*/


--cw.7.4
/*
select cu.companyname, p.productname
from customers as cu join orders as o
on cu.customerid = o.customerid
join [order details] as od
on od.orderid = o.orderid
join products as p
on p.productid = od.productid
group by cu.companyname,p.productname
*/
--cw.7.5
/*
select cu.CompanyName,isnull(convert(varchar,sum(od.unitprice * od.quantity * (1-od.discount))),'nie ma')
from customers as cu left join orders as o
on cu.customerid = o.customerid
left join [order details] as od
on od.orderid = o.orderid 
group by cu.companyname
*/
--cw.7.6 wersja dla "nigdy przedtem' - teraŸniejszoœæ nas nie interesuje
/*
use library
select firstname,count(lastname)
from member
where
	member_no in (select m.member_no
	from member as m left join loanhist as lh
	on m.member_no = lh.member_no
	group by m.member_no
	having count(isbn) = 0) 
group by firstname

*/

-----------------------------------------------------------------------------------------------------
--koncowka
--cw.1.1 i 1.2
use northwind
/*
select od.orderid, sum(od.quantity),c.companyname
from orders as o join customers as c
on o.customerid = c.customerid
join [order details] as od
on od.orderid = o.orderid
group by od.orderid,c.companyname
having sum(od.quantity) > 250
*/
--cw.1.3 i 1.4 i 1.5
/*
select od.orderid, c.companyname, sum(unitprice * quantity * (1-discount)) as value, e.lastname,e.firstname
from [order details] as od join orders as o 
on od.orderid = o.orderid
join customers as c
on c.customerid = o.customerid
join employees as e
on e.employeeid = o.EmployeeID 
group by od.orderid,c.companyname,e.lastname,e.firstname
having sum(od.quantity) > 250
*/
--cw.2.1
/*
select ca.CategoryName,  sum(od.quantity) as summary
from categories as ca join products as p
on ca.categoryid = p.categoryid
join [order details] as od
on od.productid = p.productid
group by ca.categoryname
*/
--cw 2.2 i 2.3a i 2.3 b
/*
select ca.categoryname, sum(od.unitprice * od.quantity * (1-od.discount))
from categories as ca join Products as p 
on p.categoryid = ca.categoryid
join [order details] as od 
on od.productid = p.productid
group by ca.categoryname
order by 2 --sum(od.quantity)
*/
--cw.3.1
/*
select sh.CompanyName , count(o.orderid)
from shippers as sh join orders as o
on sh.ShipperID = o.ShipVia
group by sh.companyname
*/
--cw.3.2
/*
select  top 1 sh.CompanyName, count(o.orderid) as 'shipped units in 1997'
from shippers as sh join orders as o
on sh.ShipperID = o.ShipVia
where year (o.shippeddate) =  1997
group by sh.companyname
order by 2 desc 
*/
--cw.3.3
/*
select top 1 e.firstname,e.lastname, count(o.orderid) as 'shipped units in 1997'
from employees as e join orders as o
on e.employeeid = o.employeeid
where year(o.shippeddate) = 1997
group by e.firstname, e.lastname
order by 3 desc
*/
--cw.4.1
/*
select e.firstname, e.lastname, sum(od.quantity * od.unitprice * (1- od.discount)) as 'summary of value'
from employees as e join orders as o
on e.employeeid = o.employeeid
join [order details] as od
on od.orderid = o.orderid
group by e.firstname, e.lastname
*/
--cw.4.2
/*
select top 1 e.firstname, e.lastname, sum(od.quantity * od.unitprice * (1- od.discount)) as 'summary of value'
from employees as e join orders as o
on e.employeeid = o.employeeid
join [order details] as od
on od.orderid = o.orderid
where year(shippeddate) = 1997
group by e.firstname, e.lastname
order by 3 desc
*/
--cw.4.3
/*
select e.firstname, e.lastname, sum(od.quantity * od.unitprice * (1- od.discount)) as 'summary of value'
from employees as e join orders as o
on e.employeeid = o.employeeid
join [order details] as od
on od.orderid = o.orderid
where e.employeeid in (select e1.EmployeeID
					   from employees as e1 left join employees as e2
					   on e2.reportsto = e1.employeeid
					   group by e1.employeeid
					   having count(e2.EmployeeID) > 0)
group by e.firstname, e.lastname
*/
/*
-- jesli wybieramy tych bez podwladnych, w ostatniej linijce zamiast > wpisujemy =
select e1.EmployeeID,count(e2.EmployeeID)
from employees as e1 left join employees as e2
on e2.reportsto = e1.employeeid
group by e1.employeeid
having count(e2.EmployeeID) > 0
*/
--dla ka¿dego zamówienia cenê zamówienia oraz cenê za przesy³kê -wariant pierwszy (bez min), drugi (z min/max/ whatever)
/*
use northwind 
select od.orderid,sum((od.UnitPrice*quantity*(1-discount))) + min(freight) as value, max(c.companyname)
from [order details] as od
join orders as o
on od.orderid = o.orderid
join customers as c
on c.customerid = o.customerid
group by od.orderid
*/

/*
USE northwind
SELECT (firstname + ' ' + lastname) AS name ,city, postalcode,col = 'pracownik'
FROM employees
UNION
SELECT companyname, city, postalcode, col = 'klient'
FROM customers
*/