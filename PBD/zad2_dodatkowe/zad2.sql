CREATE TABLE pokoje (   id INTEGER NOT NULL,   nazwa VARCHAR(20) NULL,   PRIMARY KEY(id) );  
CREATE TABLE okresy (   id INTEGER NOT NULL ,   nazwa VARCHAR(20) NULL,   data_od DATE NULL,   data_do DATE NULL,   PRIMARY KEY(id) );           
CREATE TABLE ceny (   id INTEGER NOT NULL,   okresy_id INTEGER NOT NULL,   pokoje_id INTEGER NOT NULL,   cena DECIMAL NULL,   PRIMARY KEY(id),   INDEX ceny_FKIndex1(pokoje_id),   INDEX ceny_FKIndex2(okresy_id),   FOREIGN KEY(pokoje_id)     REFERENCES pokoje(id),   FOREIGN KEY(okresy_id)     REFERENCES okresy(id) ); 

select p.id, p.nazwa, o.id,o.nazwa, cena,data_od,data_do
from pokoje as p join ceny as c
on c.pokoje_id = p.id
join okresy as o
on o.id = c.okresy_id
order by 1,6

select cena
from ceny as c join pokoje as p
on p.id = c.pokoje_id
join okresy as o
on c.okresy_id = o.id
where data_od = 
	(select top 1 data_od
	from okresy
	where data_od < '2000-03-15'
	order by 1 desc ) and p.id = 0

select  top 1 data_od
from okresy
where data_od > '2000-05-31' 
order by 1 asc

select data_do
from okresy
where data_od = '2001-06-01'