select * from products where categoryid = (
	select categoryid from categories where categoryname = 'beverages') and  quantityperunit like '%bottles'
/*
select companyname,fax
from suppliers 
--where fax is Null or fax = ''
where isnull(fax, '') = ''

select distinct country from suppliers
order by country 

select firstname lastname 
from employees

select companyname,
phone,fax,
'tel: ' + phone + ' fax: ' + isnull(fax,'nieznany')
from suppliers

-- data i czas  ró¿nica; funkcje napisowe, kapitalizacja, slice; case
*/



