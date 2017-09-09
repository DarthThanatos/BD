--zestawia dayid, ilosc dostepnych miejsc i ilosc zapelnionych miejsc
select cd.dayid,places_available,sum(places_reserved) 
from conferencereservation cr join confrenceday cd
on cr.dayid = cd.dayid
group by cd.dayid,places_available

--wyswietla klientow, rezerwacje konferencji i odpowiadajace im rezerwacje warsztatow
select c.clientid,cr.reservationid conf_res,wr.workresid work_res
from clients as c join conferencereservation as cr
on cr.clientid = c.clientid
join conference_participants as cp 
on cp.reservationid = cr.reservationid
join workshopparticipants as wp
on wp.conferenceparticipantid = cp.conferenceparticipantid
join workshopreservation as wr 
on wr.workresid = wp.workresid
group by c.clientid,cr.reservationid,wr.workresid
order by 1,2

--jw, wariant II
select c.clientid,cr.reservationid conf_res,wr.workresid work_res
from clients as c join conferencereservation as cr
on cr.clientid = c.clientid
join workshopreservation as wr
on wr.reservationid = cr.reservationid

--dla warsztatu podaje miejsca dostepne i miejsca zarezerwowane
select w.workshopid,places_available,sum(places_reserved)
from workshop as w join workshopreservation as wr
on w.workshopid = wr.workshopid
group by w.workshopid,places_available

-- najczesciej korzystajacy z uslug - skladajacy najwieksza ilosc rezerwacji konferencji
select top 1 cr.clientid, count(reservationid) 
from clients as c
join conferencereservation as cr
on c.clientid = cr.clientid
group by cr.clientid
order by 2 desc
 
--funkcja zwracajaca sume miejsc dostepnych we wszystkich dniach konferencji o 
--danym id
IF OBJECT_ID ('conf_places_av') IS NOT NULL
   DROP function conf_places_av;
GO
create function conf_places_av(@conferenceid int)
returns int
begin
	return 
		(select sum(places_available)
		from confrenceday
		where conferenceid = @conferenceid)
end
go

-- funkcja zwrcajaca sume miejsc zarezerwowanych w obrebie wszystkich 
-- dni danej konferencji
IF OBJECT_ID ('conf_places_res') IS NOT NULL
   DROP function conf_places_res;
GO
create function conf_places_res(@conferenceid int)
returns int
begin
	return 
		(select sum(places_reserved)
		from confrenceday cd join conferencereservation cr
		on cr.dayid = cd.dayid
		where conferenceid = @conferenceid)
end
go


-- polecenie, ktore sortuje konferencje  po procentowym udziale miejsc 
-- zarezerwowanych we wszystkich dniach konferencji do sumy miejsc dostepnych
-- w tych dniach 
select conferenceid, topic, convert(real,dbo.conf_places_res(conferenceid))/dbo.conf_places_av(conferenceid) * 100--places_reserved, places_available--sum(convert(real,places_reserved)/places_available) * 100 popularity
from conferencies 
order by 3 desc


-- polecenie sortujace warsztaty po procentowym stosunku ilosci zarezerwowanych 
-- miejsc do ilosci dostepnych na nim miejsc
select w.workshopid, topic, sum(places_reserved)/convert(real,places_available) * 100 popularity
from workshop w join workshopreservation wr 
on w.workshopid = wr.workshopid
group by w.workshopid, places_available,topic
order by 3 desc

--polecenie pokazujace tych klientow, ktorzy sa firmami
select clientid, dbo.getIndividualOrCompany(clientid),email,password, country
from clients
where isindividual = 0

--polecenie pokaujace klientow, ktore sa osobami prywatnymi
select clientid, dbo.getIndividualOrCompany(clientid),email,password, country
from clients
where isindividual = 1

--polecenie pokazujace anulowane rezerwacje konferencji
select c.clientid,dbo.getIndividualOrCompany(c.clientid) name,reservationid,places_reserved,sum_to_pay,reservationdate, dayid,email,country
from conferencereservation cr join clients c
on c.clientid = cr.clientid
where iscanceled = 1

--pokaz anulowane rezerwacje konferencji i warsztatow, zestawione razem
select distinct  cr.reservationid,wr.workresid,is_canceled
from conferencereservation as cr join conference_participants as cp 
on cp.reservationid = cr.reservationid
join workshopparticipants as wp
on wp.conferenceparticipantid = cp.conferenceparticipantid
join workshopreservation as wr 
on wr.workresid = wp.workresid 
where cr.iscanceled = 1
order by 1

--dla kazdego klienta zestawia odpowiednio laczna ilosc dokonanych rez. konferencji oraz laczna ilosc rez. warsztatow 
select distinct c.clientid,count(distinct cr.reservationid),count(distinct wr.workresid)
from clients as c join conferencereservation as cr
on cr.clientid = c.clientid
join conference_participants as cp 
on cp.reservationid = cr.reservationid
join workshopparticipants as wp
on wp.conferenceparticipantid = cp.conferenceparticipantid
join workshopreservation as wr 
on wr.workresid = wp.workresid
--where cr.clientid = 0
group by c.clientid
order by 1

--jw, wariant II
select distinct c.clientid,count(distinct cr.reservationid),count( distinct wr.workresid)
from clients as c join conferencereservation as cr
on cr.clientid = c.clientid
join workshopreservation as wr
on wr.reservationid = cr.reservationid
group by c.clientid
go


--WIDOK => najwieksze uslugi - najwiecej zaplacil
CREATE VIEW VIPs
as
	select cr.clientid, sum(sum_to_pay) [genral cost]
	from clients as c
	join conferencereservation as cr
	on c.clientid = cr.clientid
	group by cr.clientid
go

select * from VIPs  order by 2 desc
go

-- funkcja zwracaj¹ca iloœæ rezerwacji warsztatów, ³¹cznie z odpowiadaj¹c¹ im rezerwacj¹ konferencji 
IF OBJECT_ID ('get_res_amount') IS NOT NULL
   DROP function get_res_amount;
GO
create function get_res_amount(@resid int)
returns int 
begin
	return 
		(select count(workresid) + 1 -- 1 oznacza rezerwacje konferencji
		from workshopreservation
		where reservationid = @resid)
end
go

-- widok => pokazujacy dla kazdego klienta laczna ilosc rezerwacji konferencji + warsztatow
create view VIPS_reservations
as
	select c.clientid, dbo.getIndividualOrCompany(c.clientid) name, sum(dbo.get_res_amount(reservationid)) 'amount of reservations'
	from clients c join conferencereservation cr
	on cr.clientid = c.clientid
	group by c.clientid
go

select * from VIPS_reservations order by 3 desc
go 

--procedura pokazujaca dla danego dayid progi cenowe
create procedure show_fees @dayid int
as
	select *
	from fees
	where dayid = @dayid
go


-- widok => zestawia klienta, jego calkowita kwote do zaplaty za dni konferencji i warsztaty 
-- dodatkowo sume zaplacona do tej pory oraz date rezerwacji zestawiona z data ostatnio zaplaconej raty

IF OBJECT_ID('costs', 'V') IS NOT NULL
    DROP VIEW costs;
go
create view costs
as
	select c.clientid, sum_to_pay [sum to pay],  sum(amount_paid) sum_paid,iscanceled,reservationdate, max(date_of_paying) last_payment
	from clients as c join conferencereservation as cr
	on c.clientid = cr.clientid
	join paidRate as pr
	on pr.reservationid = cr.reservationid 
	group by c.clientid, sum_to_pay, iscanceled, reservationdate
go

--testy
select * from costs where iscanceled = 0 and abs([sum to pay] - sum_paid) > 0.5
go

select * from workshop_costs order by 1 go

-- procedura => oblicz calosc naleznosci za rezerwacje dnia konferencji i zwiazanych z dniem warsztatow i zestaw to z polem sum_to_pay w conf.res.
IF OBJECT_ID('total_cost') IS NOT NULL
   DROP procedure total_cost
GO
create procedure total_cost @resId int
as
	declare @fee_id int, @price real, @unitprice real, @places int, @wr_places int, @student_places int, @w_price real, @sum real,@select_sum real
	set @unitprice = 
		(select top 1 conferencePrice
		from conferencereservation as cr join confrenceday as cd
		on cd.dayid = cr.dayid
		join fees as f
		on f.dayid = cd.dayid
		where reservationdate >= when_is_in_force and cr.reservationid = @resId
		order by when_is_in_force desc)
	set @student_places = 
		(select  count(conferenceparticipantid) students
		from conferencereservation as cr left join conference_participants as cp
		on id_number is not null and cp.reservationid = cr.reservationid
		where  cr.reservationid = @resId
		group by cr.reservationid)
	set @places =
		(select places_reserved
		from conferencereservation 
		where reservationid = @resId) - @student_places
	set @price = @unitprice * @places + 0.5 * @unitprice * @student_places
	set @w_price =
		(select sum(quote * dbo.check_if_student(wp.conferenceparticipantid) ) 
		from workshopreservation as wr left join workshopparticipants as wp
		on wr.workresid = wp.workresid
		join conference_participants as cp
		on cp.conferenceparticipantid = wp.conferenceparticipantid 
		join workshop as w
		on w.workshopid = wr.workshopid
		join conferencereservation as cr 
		on cr.reservationid = wr.reservationid
		where cr.reservationid = @resId
		group by cr.reservationid)
	set @sum = @price + @w_price
	set @select_sum =
		(select sum_to_pay
		from conferencereservation
		where reservationid = @resId)
	select @resId [reservation id],@select_sum [select sum], @sum [procedure]
go

execute total_cost 0
go



-- funkcja ktora osadza, czy uzytkownik o id participanta jest studentem czy nie - gdy jest, zwraca 0.5, czyli polowe stawki do zaplacenia, gdy nie jest, zwraca 1, czyli cala stawke
IF OBJECT_ID('check_if_student') IS NOT NULL
   DROP FUNCTION check_if_student
GO
create function check_if_student(@conf_part_id int) 
returns real
as 
begin  
	if 
	(select id_number
	from conference_participants
	where @conf_part_id = conferenceparticipantid) is null
		return 1
	return 0.5
end 
go

select * from conference_participants
select dbo.check_if_student(1)

--kwota za zarezerwowane warsztaty zestawiona z rezerwacja konferencji
select cr.reservationid,sum(quote * dbo.check_if_student(wp.conferenceparticipantid) )
from workshopreservation as wr left join workshopparticipants as wp
on wr.workresid = wp.workresid
join conference_participants as cp
on cp.conferenceparticipantid = wp.conferenceparticipantid 
join workshop as w
on w.workshopid = wr.workshopid
join conferencereservation as cr 
on cr.reservationid = wr.reservationid
group by cr.reservationid 
order by 1,2


-- ilosc studentow bioracych udzial w warsztacie
select wr.workresid,count(id_number)
from workshopreservation as wr join workshopparticipants as wp
on wr.workresid = wp.workresid
join conference_participants as cp
on cp.conferenceparticipantid = wp.conferenceparticipantid
group by wr.workresid
--pomocniczy select do testu powyzszego
select *
from workshopreservation as wr join workshopparticipants as wp
on wr.workresid = wp.workresid
join conference_participants as cp
on cp.conferenceparticipantid = wp.conferenceparticipantid
order by 1

-- select zwracajacy cene za konferencje, wziawszy pod uwage date najblizszego progu cenowego (usunac topa dla testu)
select top 1 conferencePrice,reservationdate, when_is_in_force
from conferencereservation as cr join confrenceday as cd
on cd.dayid = cr.dayid
join fees as f
on f.dayid = cd.dayid
where  cd.dayid = 5 and reservationdate >= when_is_in_force
order by when_is_in_force desc

select * from conferencereservation

-- zwraca dla reservationid ilosc zarezerwowanych miejsc i ilosc studentow
select  places_reserved, count(id_number) students
from conferencereservation as cr left join conference_participants as cp
on cp.reservationid = cr.reservationid 
where  cr.reservationid = 2
group by cr.reservationid,places_reserved
go

-- procedura pokazujaca warsztaty trwajace w tym samym czasie w danym dniu co warsztat o id podanym na wejsciu

IF OBJECT_ID('getSameWorkshops') IS NOT NULL
   DROP procedure getSameWorkshops
GO
create procedure getSameWorkshops @dayid int, @workshopId int 
as
	declare @startime time, @endtime time 
	set @startime = 
		(select starting_hour
		from workshop 
		where workshopid = @workshopId)
	set @endtime = 
		(select end_hour
		from workshop 
		where workshopid = @workshopId)
	print @endtime
	print @startime
	select * 
	from workshop 
	where @workshopId != workshopid 
	and end_hour = @endtime 
	and starting_hour = @startime 
	and @dayid = dayid
go

-- test getSameWorkshops
select * from workshop where dayid = 159
execute getSameWorkshops 159, 477
go

--procedura pokazujaca typ kolumny w tabeli
IF OBJECT_ID('getDataType') IS NOT NULL
   DROP procedure getDataType
GO
create procedure getDataType @table varchar(50), @column varchar(50)
as 
	SELECT DATA_TYPE 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE 
		 TABLE_NAME = @table AND 
		 COLUMN_NAME = @column
go
	--test getDataType
	execute getDataType 'workshop','end_hour'

-- dla kazdej rezerwacji pokaz id uczestnikow zarejestrowanych
select cr.reservationid, places_reserved,cp.conferenceparticipantid,cp.personid
from conferencereservation as cr join conference_participants as cp
on cr.reservationid = cp.reservationid
where cr.reservationid = 0
order by 1,2

select * 
from conferencereservation

-- dla warsztatu pokaz id uczestnikow zarejestrowanych
select wr.workresid, wp.conferenceparticipantid
from workshopreservation as wr join workshopparticipants as wp
on wp.workresid = wr.workresid
join conference_participants as cp 
on cp.conferenceparticipantid = wp.conferenceparticipantid
join conferencereservation as cr
on cp.reservationid = cr.reservationid
where cr.reservationid = 512
order by 1,2


--procedura => lista osobowa uczestnikow na kazdy dzien konferencji
IF OBJECT_ID('daylist') IS NOT NULL
   DROP procedure daylist
GO
create procedure daylist @dayid int
as
select  @dayid,surname,name, phone, country,city,p.street
from confrenceday as cd join conferencereservation cr
on cd.dayid = cr.dayid
join conference_participants as cp
on cp.reservationid = cr.reservationid
join People as p 
on cp.personid = p.personid
where cd.dayid = @dayid
order by 1,2
go

execute daylist 200

-- procedura zalatwiajaca 'informacje o kliencie' w poleceniu projektu
IF OBJECT_ID('generate_business_card') IS NOT NULL
   DROP procedure generate_business_card
GO

create procedure generate_business_card @dayid int
as
	select  @dayid,p.surname,p.name, dbo.getIndividualOrCompany(c.clientid) info_about_client
	from confrenceday as cd join conferencereservation cr
	on cd.dayid = cr.dayid
	join conference_participants as cp
	on cp.reservationid = cr.reservationid
	join People as p 
	on cp.personid = p.personid
	join clients c 
	on c.clientid = cr.clientid
	where cd.dayid = @dayid and iscanceled = 0 
	order by 1,2
go

execute generate_business_card 200


--pokazuje sume zarezerwowanych miejsc w danym dniu
select cd.dayid,date_of_day,places_available,sum(distinct places_reserved) [suma miejsc kazdej rezerwacji dot. okreslonego dnia]
from confrenceday as cd join conferencereservation as cr 
on cr.dayid= cd.dayid
--where cd.dayid = 200
group by cd.dayid,places_available,date_of_day
go

--procedura pokazujaca liste osobowa uczestnikow warsztatu o danym id
IF OBJECT_ID('workshop_list') IS NOT NULL
   DROP procedure workshop_list
GO
create procedure workshop_list @workshopid int
as 
	select @workshopid,surname,name, phone, country,city,p.street
	from workshop as w join workshopreservation as wr
	on w.workshopid = wr.workshopid
	join workshopparticipants as wp
	on wp.workresid = wr.workresid
	join conference_participants as cp
	on wp.conferenceparticipantid = cp.conferenceparticipantid
	join People as p 
	on p.personid = cp.personid
	where w.workshopid = @workshopid
go

execute workshop_list 183

-- przykladowy testowy select do powyzszej procedury
select personid
from people
where name = 'Lavinia' and surname = 'Santos'

-- procedura, ktora dla danego id rezerwacji pokazuje liste osobowa uczestnikow zgloszonych + informacja o zglaszajacym
IF OBJECT_ID('reservation_list') IS NOT NULL
   DROP procedure reservation_list
GO
create procedure reservation_list @reservationid int
as
	select p.surname participant_surname, p.name participant_name,places_reserved, dbo.getIndividualOrCompany(c.clientid) client_name, isindividual 'registered by individual person?'
	from conference_participants cp join people p
	on p.personid = cp.personid
	join conferencereservation cr
	on cr.reservationid = cp.reservationid
	join clients c
	on c.clientid = cr.clientid
	where cr.reservationid = @reservationid
go

execute reservation_list 0

--procedura, ktora dla danego id rezerwacji warsztatu pokazuje liste osobowa uczestnikow warsztatu + informacje i zglaszajacym
IF OBJECT_ID('workres_list') IS NOT NULL
   DROP procedure workres_list
GO
create procedure workres_list @workresid int
as
	select p.surname 'participant surname', p.name 'participant name', wr.places_reserved, dbo.getIndividualOrCompany(c.clientid) client_name, isindividual 'Registered by an individual person?'
	from workshopparticipants wp join conference_participants cp
	on wp.conferenceparticipantid = cp.conferenceparticipantid
	join people p 
	on p.personid = cp.personid
	join conferencereservation cr
	on cr.reservationid = cp.reservationid
	join clients c 
	on c.clientid= cr.clientid
	join workshopreservation wr
	on wr.workresid = wp.workresid
	where wr.workresid = @workresid
go

execute workres_list 0

-- pokazuje ilosc zarezerwowanych miejsc w danym warsztacie i zestawia z dostepnymi miejscami
select w.workshopid,places_available,sum(places_reserved) [suma miejsc kazdej rezerwacji dot. okreslonego warsztatu]
from workshopreservation as wr join workshop as w
on w.workshopid = wr.workshopid
where w.workshopid = 183
group by w.workshopid,places_available

go
-- informacje o platnosciach klientow

-- pokaz klientow, ktorzy maja zaleglosci w platnosciach, na wejsciu ilosc dni od daty rezerwacji i aktualna data(punkt odniesienia),
-- dzieki ktorej zostanie odszukana najblizsza konferencja
IF OBJECT_ID('delayed') IS NOT NULL
   DROP procedure delayed
GO 
create procedure delayed @days_amount int, @recent_date date
as
	declare @recent_conferencyid int

	set @recent_conferencyid =
		(select top 1 conferenceid
		from conferencies
		where fromdate >= @recent_date
		order by fromdate asc)

	select c.conferenceid,dbo.getIndividualOrCompany(clientid), 
		   reservationdate,max(sum_to_pay) 'to pay', 
		   isnull(sum(amount_paid),0) 'already paid',
		   iscanceled,dateadd(d, @days_amount, reservationdate) 
	from conferencies as c join confrenceday as cd
	on c.conferenceid = cd.conferenceid
	join conferencereservation as cr 
	on cr.dayid = cd.dayid 
	left join paidRate as pr
	on pr.reservationid = cr.reservationid and date_of_paying <= dateadd(d, @days_amount, reservationdate)
	where c.conferenceid = @recent_conferencyid and  dateadd(d, @days_amount, reservationdate) = @recent_date
	group by c.conferenceid,clientid,reservationdate,iscanceled
	having abs(isnull(sum(amount_paid),0) - max(sum_to_pay) ) >0.5
		   
go 

execute delayed 2,'2000-06-15'

-- procedura pokazujaca dane klientow, ktorzy siedem dni od daty rezerwacji nie uregulowali
-- naleznosci sum_to_pay, na wejsciu data, ktora bedzie punktem odniesienia pokazujaca identyfikujaca najblizsza konferencje
IF OBJECT_ID('really_delayed') IS NOT NULL
   DROP procedure really_delayed
GO 
create procedure really_delayed @recent_date date
as
	declare @recent_conferencyid int
	set @recent_conferencyid =
		(select top 1 conferenceid
		from conferencies
		where fromdate >= @recent_date
		order by fromdate asc)
	select c.conferenceid,dbo.getIndividualOrCompany(clientid), 
		   reservationdate,max(sum_to_pay) 'to pay', 
		   isnull(sum(amount_paid),0) 'already paid',
		   iscanceled 
	from conferencies as c join confrenceday as cd
	on c.conferenceid = cd.conferenceid
	join conferencereservation as cr 
	on cr.dayid = cd.dayid 
	left join paidRate as pr
	on pr.reservationid = cr.reservationid and date_of_paying <= dateadd(d, 7, reservationdate) -- 7 dni od rezerwacji jest ostatecznym progiem, pozniejsze oplaty nie sa brane pod uwage
	where c.conferenceid = @recent_conferencyid and  dateadd(d, 7, reservationdate) <= @recent_date
	group by c.conferenceid,clientid,reservationdate,iscanceled
	having abs(isnull(sum(amount_paid),0) - max(sum_to_pay) ) >0.5
		   
go

execute  really_delayed '2002-09-23'

-- wykorzystujac date pokaz najblizsza nadciagajaca konferencje
-- (UWAGA!! Data ma by mniejsza od daty rozpoczecia konferencji!!)
select top 1 conferenceid
from conferencies
where fromdate >= '2000-06-16'
order by fromdate asc

-- select pomocniczy do powy¿szej procedury
select *
from conferencies as c join confrenceday as cd
on c.conferenceid = cd.conferenceid
join conferencereservation as cr 
on cr.dayid = cd.dayid 
join paidRate as pr
on pr.reservationid = cr.reservationid
where c.conferenceid = 12
order by 1,clientid,date_of_paying

go

--procedura pokazujaca id warsztatow na ktory uczestnik byl kiedykolwiek zapisany + informacje o nim i zestawia to z id dnia konferencji, na wejsciu id uczestnika
IF OBJECT_ID('my_events') IS NOT NULL
   DROP procedure my_events
GO 
create procedure my_events @personid int
as 
	select w.workshopid, topic, street, starting_hour,end_hour, quote, w.dayid,places_available
	from conference_participants cp join conferencereservation cr
	on cp.reservationid = cr.reservationid
	join workshopparticipants wp
	on wp.conferenceparticipantid = cp.conferenceparticipantid
	join workshopreservation wr 
	on wr.workresid = wp.workresid
	join workshop w 
	on w.workshopid = wr.workshopid
	where @personid = personid
	order by 1
go

	execute my_events 0

-- funkcja zwracajaca dane klienta, ktore nie sa nullem
IF OBJECT_ID('getIndividualOrCompany') IS NOT NULL
   DROP function getIndividualOrCompany
GO 
create function getIndividualOrCompany(@clientid int)
returns varchar(100)
as
begin
	declare @isindividual bit,  @companyname varchar(50), @name_surname varchar(50)
	set @companyname = 
		(select companyname
		from clients
		where @clientid = clientid)
	set @name_surname = 
		(select name + ' ' + surname
 		from clients
		where @clientid = clientid)
	set @isindividual =
		(select isindividual
 		from clients
		where @clientid = clientid)
	if @isindividual = 1 return @name_surname
	return @companyname
end 
go

	select * from clients
	select dbo.getIndividualOrCompany(1)
	select dbo.getIndividualOrCompany(22)
----------------------------------------------------------------------------------
--procedura pokazujaca dane klientow, ktorzy na dwa tygodnie przed data najblizszej 
--konferencji (wyznaczonej przez date na wejsciu) nie uzupelnili wszystkich sanych osobowych uczestnikow
IF OBJECT_ID('show_delaying_data') IS NOT NULL
   DROP procedure show_delaying_data
GO 
create procedure show_delaying_data @recent_date date
as 
SELECT cr.reservationid, dbo.getIndividualOrCompany(c.clientid) 'Name', c.email, co.topic AS 'Conferency Subject', 
        cr.places_reserved AS 'Places reserved',  cr.places_reserved - (SELECT COUNT(*)                                
	       																FROM conference_participants AS cp 
																		WHERE cp.reservationid = cr.reservationid) AS 'How many lacking' 
FROM conferencereservation cr LEFT JOIN clients c 
ON cr.clientid = c.clientid 
LEFT JOIN confrenceday cd
ON cd.dayid = cr.dayid
LEFT JOIN conferencies co 
ON co.conferenceid = cd.conferenceid 
WHERE   cr.iscanceled = 0 
		AND (cr.places_reserved - (SELECT COUNT(*)   
				                   FROM conference_participants cp
			                       WHERE cp.reservationid = cr.reservationid)) > 0 
		AND (cd.date_of_day >= DATEADD(d,14,@recent_date) )
go

	execute show_delaying_data '2000-01-01'

--zestawia id rezerwacji konferencji, ilosc zarezerwowanych miejsc i id uczestnikow
select  cr.reservationid, places_reserved, conferenceparticipantId
from conferencereservation as cr join conference_participants as cp
on cr.reservationid = cp.reservationid
where cr.reservationid = 0

select  distinct cr.reservationid,wr.workresid, wr.places_reserved, wp.conferenceparticipantId,workshopparticipantid
from conferencereservation as cr join conference_participants as cp
on cr.reservationid = cp.reservationid
join workshopreservation wr
on wr.reservationid = cr.reservationid
join workshopparticipants as wp
on wp.workresid = wr.workresid
where cr.reservationid = 12
order by 1,2,3,4

--trigger ktory uniewaznia transakcje dodania rezerwacji, jesli zamowienie 
--przekroczylo maksymalna ilosc miejsc na dniu konferencji

IF OBJECT_ID ('stop_if_too_many_conf', 'TR') IS NOT NULL
   DROP TRIGGER stop_if_too_many_conf;
GO
CREATE TRIGGER stop_if_too_many_conf on conferencereservation 
after INSERT,UPDATE  AS 
	if exists
		(select places_available
		from conferencereservation as cr
		join confrenceday as cd
		on cd.dayid = cr.dayid
		group by cd.dayid, places_available
		having places_available < sum(cr.places_reserved) )
	BEGIN    
		RAISERROR('More places reserved on conference day than available', 16, 1)
	ROLLBACK TRANSACTION END 
go

--test triggera
declare @sum real,@date date, @places int
set @places = 20
set @date = '2000-01-06'
set @sum = 
	(select top 1 conferencePrice
	from fees as f join confrenceday as cd
	on f.dayid = cd.dayid
	where cd.dayid = 5 and when_is_in_force <= @date
	order by when_is_in_force desc)
insert into conferencereservation values(@places,0,@sum,@date,0,5)
go

select * from conferencereservation
delete from conferencereservation where reservationid = 602

--trigger, ktory dba o to, aby po ewentualnej zmianie ilosci dostepnych miejsc
--na konferencji suma zarezerwowanych miejsc na dany dzien nie przekroczyla 
-- uaktualnionej liczby miejsc 

IF OBJECT_ID ('watch_res_more_than_available', 'TR') IS NOT NULL
   DROP TRIGGER watch_res_more_than_available;
GO
create trigger watch_res_more_than_available 
on confrenceday
for update
as 
	if exists
		(select cd.places_available
		from confrenceday as cd join conferencereservation as cr
		on cd.dayid = cr.dayid
		group by cd.dayid,cd.places_available
		having cd.places_available < sum(places_reserved))
	BEGIN    
		RAISERROR('Less available places than reserved ones', 16, 1)
	ROLLBACK TRANSACTION END 
go

update confrenceday
set places_available = 70
where dayid = 0


IF OBJECT_ID ('stop_if_too_many_workres', 'TR') IS NOT NULL
   DROP TRIGGER stop_if_too_many_workres;
GO
create trigger stop_if_too_many_workres
on  workshopreservation
for insert,update 
as
	if exists
		(select w.places_available
		from workshop as w join workshopreservation as wr
		on w.workshopid = wr.workshopid
		group by w.workshopid, places_available
		having places_available < sum(wr.places_reserved))
	BEGIN    
		RAISERROR('Less available places than reserved ones', 16, 1)
	ROLLBACK TRANSACTION END 
go

insert into workshopreservation values(200,0,82,0)
delete from workshopreservation where workresid = 1794
select * 
from conferencereservation cr join workshopreservation wr
on wr.reservationid = cr.reservationid
where workshopid = 0


--trigger, ktory dba o to, aby po ewentualnej zmianie ilosci dostepnych miejsc
--na warsztacie suma zarezerwowanych miejsc na dany warsztat nie przekroczyla 
-- uaktualnionej liczby miejsc 
IF OBJECT_ID ('stop_if_too_little_workres', 'TR') IS NOT NULL
   DROP TRIGGER stop_if_too_little_workres;
GO
create trigger stop_if_too_little_workres
on  workshop
after update 
as
	if exists
		(select w.places_available
		from workshop as w join workshopreservation as wr
		on w.workshopid = wr.workshopid
		group by w.workshopid, places_available
		having places_available < sum(wr.places_reserved))
	BEGIN    
		RAISERROR('Less available places than reserved ones', 16, 1)
	ROLLBACK TRANSACTION END 
go

update workshop
set places_available = 70
where workshopid = 0


--trigger dbajacy o to, aby osoba nie zapisala sie na ten sam warsztat dwukrotnie
IF OBJECT_ID ('check_same_workshop_tr ', 'TR') IS NOT NULL
   DROP TRIGGER check_same_workshop_tr ;
GO
create trigger check_same_workshop_tr 
on workshopparticipants
for insert
as 
	if exists
		(select p.personid
		from workshop as w join workshopreservation as wr
		on wr.workshopid = w.workshopid
		join workshopparticipants as wp
		on wp.workresid = wr.workresid
		join conference_participants as cp
		on cp.conferenceparticipantid = wp.conferenceparticipantid
		join people as p
		on p.personid = cp.personid
		group by w.workshopid,p.personid
		having count(cp.conferenceparticipantid) > 1)
	BEGIN    
		RAISERROR('A person already registered for this workshop', 16, 1)
	ROLLBACK TRANSACTION END 
go


insert into workshopparticipants values(45,500)
select * from workshopparticipants
delete from workshopparticipants where workshopparticipantid = 57608

select p.personid
from workshop as w join workshopreservation as wr
on wr.workshopid = w.workshopid
join workshopparticipants as wp
on wp.workresid = wr.workresid
join conference_participants as cp
on cp.conferenceparticipantid = wp.conferenceparticipantid
join people as p
on p.personid = cp.personid
group by w.workshopid,p.personid
having count(cp.conferenceparticipantid) > 1
 
--procedura pokazujaca osobie, w ktorych warsztatach uczestniczy
IF OBJECT_ID ('show_workshop_person') IS NOT NULL
   DROP procedure show_workshop_person;
GO
create procedure show_workshop_person @id int
as
	select @id,w.workshopid
	from workshop as w join workshopreservation wr
	on w.workshopid = wr.workshopid
	join workshopparticipants wp
	on wp.workresid = wr.workresid
	join conference_participants as cp
	on cp.conferenceparticipantid = wp.conferenceparticipantid
	where personid = @id
go

execute show_workshop_person 183
select *
from workshopreservation as wr
where workshopid = 1


select * 
from conference_participants cp join workshopparticipants wp
on cp.conferenceparticipantid = wp.conferenceparticipantid
join workshopreservation as wr
on wr.workresid = wp.workresid 
where personid = 183

--procedura pokazujaca osobie, w ktorych dniach konferencji uczestniczy
IF OBJECT_ID ('show_day_person') IS NOT NULL
   DROP procedure show_day_person;
GO
create procedure show_day_person @id int
as
	select @id,cd.dayid
	from confrenceday as cd join conferencereservation cr
	on cd.dayid= cr.dayid
	join conference_participants cp
	on cp.reservationid = cr.reservationid
	where personid = @id
go

execute show_day_person 183
--trigger dbajacy o to, aby osoba nie zapisala sie na warsztat trwajacy w tym samym czasie 

IF OBJECT_ID ('watch_if_same_time_work ', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_same_time_work ;
GO
create trigger watch_if_same_time_work 
on workshopparticipants
for insert,update
as 
	if (SELECT COUNT(*)
		 FROM  workshopparticipants wp JOIN  workshopreservation wr
		 ON wp.workresid = wr.workresid 
		 INNER JOIN workshop w 
		 ON w.workshopid = wr.workshopid
  		 INNER JOIN confrenceday cd 
		 ON cd.dayid = w.dayid 
		 INNER JOIN conference_participants cp 
		 ON cp.conferenceparticipantid = wp.conferenceparticipantid 
		 INNER JOIN  confrenceday as cd2 
		 ON cd.dayid = cd2.dayid  
		 INNER JOIN  workshop w1 
		 ON w1.dayid = cd2.dayid
		 join inserted 
		 on inserted.workshopparticipantid = wp.workshopparticipantid  
		 WHERE (w.starting_hour <= w1.end_hour AND w.end_hour >= w1.starting_hour) and inserted.conferenceparticipantid = wp.conferenceparticipantid)>1 
	BEGIN    
		RAISERROR('A person already registered for the workshop lasting at the same time', 16, 1)
	ROLLBACK TRANSACTION END 
go

select w.dayid,w.workshopid,wr.workresid,workshopparticipantid,starting_hour,end_hour
from workshopparticipants as wp join workshopreservation wr
on wp.workresid = wr.workresid
join workshop w
on w.workshopid = wr.workshopid
join confrenceday cd
on cd.dayid = w.dayid
where workshopparticipantid = 1884
order by 1,2,3

select w.workshopid, wr.workresid,conferenceparticipantid
from workshopparticipants as wp join workshopreservation wr
on wp.workresid = wr.workresid
join workshop w
on w.workshopid = wr.workshopid
where  w.workshopid = 0 and conferenceparticipantid = 1282

insert into workshopparticipants values(247,1282)
select * from workshopparticipants
delete from workshopparticipants where workshopparticipantid = 57611

IF OBJECT_ID('getSameWorkshopsID') IS NOT NULL
   DROP function getSameWorkshopsID
GO
create function getSameWorkshopsID (@dayid int, @workshopId int)
returns int 
as
begin
	declare @startime time, @endtime time 
	set @startime = 
		(select starting_hour
		from workshop 
		where workshopid = @workshopId)
	set @endtime = 
		(select end_hour
		from workshop 
		where workshopid = @workshopId)
	return 
		(select workshopid 
		from workshop 
		where @workshopId != workshopid 
		and end_hour = @endtime 
		and starting_hour = @startime 
		and @dayid = dayid)
end
go

select * from workshop where dayid = 159
select dbo.getSameWorkshopsID (0, 0)
go

--trigger, ktory pilnuje, zeby zadna osoba nie zapisala sie wiecej niz raz na dzien konferencji
IF OBJECT_ID ('watch_if_same_day', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_same_day ;
GO
create trigger watch_if_same_day
on conference_participants 
for insert,update
as
	if exists 
		(select distinct p.personid
		from confrenceday as cd join conferencereservation as cr
		on cd.dayid = cr.dayid
		join conference_participants as cp
		on cp.reservationid = cr.reservationid
		join people p
		on p.personid = cp.personid
		group by cd.dayid,p.personid
		having count(cp.conferenceparticipantid) > 1) 
	BEGIN    
		RAISERROR('A person already registered for this conference day', 16, 1)
	ROLLBACK TRANSACTION END 
go

select cd.dayid,cr.reservationid,cp.personid
from confrenceday as cd join conferencereservation cr
on cd.dayid = cr.dayid
join conference_participants cp 
on cp.reservationid = cr.reservationid
where cd.dayid = 0 and personid = 18
order by 1,2,3

insert into conference_participants values(2,null,82)
select * from conference_participants
delete from conference_participants where conferenceparticipantid = 38606

--trigger, ktory dba o to, aby nie przekroczyc ilosci zarezerwowannych miesc przy formowaniu listy zarejestrowanych na dzien konferencji 
IF OBJECT_ID ('watch_if_places_res', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_places_res;
GO
create trigger watch_if_places_res
on conference_participants 
for insert,update
as
	if exists 
		(select places_reserved
		from conferencereservation cr join conference_participants cp
		on cp.reservationid = cr.reservationid
		group by cr.reservationid,places_reserved
		having count(personid) > places_reserved ) 
	BEGIN    
		RAISERROR('Limit of places reserved has been reached, you cannot register through this reservation', 16, 1)
	ROLLBACK TRANSACTION END 
go

select cr.reservationid, places_reserved
from conferencereservation cr join conference_participants cp
on cp.reservationid = cr.reservationid
group by cr.reservationid,places_reserved

insert into conference_participants values(200,null,0)


-- trigger sprawdzajacy, czy po zmianie zarezerwowanych miejsc nie dojdzie do 
-- przepelnienia list osobowych
IF OBJECT_ID ('watch_if_places_res_change', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_places_res_change;
GO
create trigger watch_if_places_res_change
on conferencereservation 
for update
as
	if exists 
		(select places_reserved
		from conferencereservation cr join conference_participants cp
		on cp.reservationid = cr.reservationid
		group by cr.reservationid,places_reserved
		having count(personid) > places_reserved ) 
	BEGIN    
		RAISERROR('Cannot change  reserved places amount to maintain consistence', 16, 1)
	ROLLBACK TRANSACTION END 
go

-- test
update conferencereservation
set places_reserved = 5
where reservationid = 0

-- trigger dbajacy o to, by nie przekroczono limitu zarezerwowanych miejsc
-- dla danej rezerwacji warsztatu
IF OBJECT_ID ('watch_if_places_work', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_places_work;
GO
create trigger watch_if_places_work
on workshopparticipants
for insert,update
as
	if exists 
		(select places_reserved
		from workshopreservation wr join workshopparticipants wp
		on wp.workresid = wr.workresid
		group by wr.workresid,places_reserved
		having count(conferenceparticipantid) > places_reserved ) 
	BEGIN    
		RAISERROR('Limit of places reserved has been reached, you cannot register through this reservation', 16, 1)
	ROLLBACK TRANSACTION END 
go

select wr.workresid, places_reserved, workshopparticipantid
from workshopreservation wr join workshopparticipants wp
on wr.workresid = wp.workresid 
--group by wr.workresid,places_reserved

insert into workshopparticipants values(0,200)

-- trigger dbajacy o to, by po zmianie ilosci zarezerwowanych miejsc w rezerwacji warsztatu nie nastapila
-- utrata spojnosci danych
IF OBJECT_ID ('watch_if_places_work_change', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_places_work_change;
GO
create trigger watch_if_places_work_change
on workshopreservation
for update
as
	if exists 
		(select places_reserved
		from workshopreservation wr join workshopparticipants wp
		on wp.workresid = wr.workresid
		group by wr.workresid,places_reserved
		having count(conferenceparticipantid) > places_reserved ) 
	BEGIN    
		RAISERROR('Change canceled in order to maintain data consistency on workshop reservation', 16, 1)
	ROLLBACK TRANSACTION END 
go

update workshopreservation
set places_reserved = 1
where workresid = 0


--trigger pilnujacy, czy osoba pragnaca zarejestrowac sie na warsztat jest zapisana
--tego dnia na konferencje

IF OBJECT_ID ('watch_if_registered_onday_work', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_registered_onday_work;
GO
create trigger watch_if_registered_onday_work
on workshopparticipants
for insert,update
as
	if exists 
		(select personid
		from inserted as i join conference_participants cp
		on i.conferenceparticipantid =  cp.conferenceparticipantid 
		join  workshopreservation wr
		on i.workresid = wr.workresid
		join workshop w
		on w.workshopid = wr.workshopid
		join conferencereservation cr 
		on cr.reservationid = cp.reservationid
		where w.dayid != cr.dayid) 
	BEGIN    
		RAISERROR('This person is not registered on the conference day when this workshop takes place', 16, 1)
	ROLLBACK TRANSACTION END 
go

select * 
from conference_participants cp join conferencereservation cr
on cp.reservationid = cr.reservationid
join workshopreservation wr
on wr.reservationid = cr.reservationid
where dayid = 1

insert into workshopparticipants values(258,217) 
select * from workshopparticipants
delete from workshopparticipants where workshopparticipantid = 57620

select * from conference_participants where personid = 183
--trigger, ktory pilnuje, czy wplacona rata nie bedzie przekraczala naleznej sumy
IF OBJECT_ID ('watch_if_paid_too_much', 'TR') IS NOT NULL
   DROP TRIGGER watch_if_paid_too_much;
GO
create trigger watch_if_paid_too_much
on paidRate
for insert
as
	if exists 
		(select sum_to_pay
		from paidRate pr join conferencereservation cr
		on cr.reservationid = pr.reservationid
		group by cr.reservationid, sum_to_pay
		having sum_to_pay < sum(amount_paid)) 
	BEGIN    
		RAISERROR('Client paid more than it is worth', 16, 1)
	ROLLBACK TRANSACTION END 
go

select *
from conferencereservation cr join paidrate pr
on pr.reservationid = cr.reservationid
where iscanceled = 0

insert into paidrate values(0,'2000-06-29',200)


--procedura, ktora wypelnia tabelke conferencereservation, jesli trigger nie zabroni
IF OBJECT_ID ('fill_conf_res') IS NOT NULL
   DROP procedure fill_conf_res;
GO
create procedure fill_conf_res @placesreserved int,@reservationdate date,@clientid int, @dayid int
as
	declare @sum real,@unitprice real
	
	set @unitprice =
		(select top 1 conferencePrice 
		from fees f join confrenceday cd
		on cd.dayid = f.dayid
		where f.dayid = @dayid and @reservationdate >= when_is_in_force
		order by when_is_in_force desc)
	set @sum = @unitprice * @placesreserved 
	insert into conferencereservation values(@placesreserved,0,@sum,@reservationdate,@clientid,@dayid)
go

select * from conferencereservation
delete from conferencereservation where reservationid = 603
execute fill_conf_res 20,'2000-01-06',0,5

--procedura, ktora wypelnia tabelke workshopreservation, jesli trigger nie zabroni
IF OBJECT_ID ('fill_work_res') IS NOT NULL
   DROP procedure fill_work_res;
GO
create procedure fill_work_res @placesreserved int,@workshopid int,@reservationid int
as
	declare @sum real,@quote real
	set @quote =
		(select quote
		from workshop
		where workshopid = @workshopid)
	set @sum = @quote * @placesreserved 
	insert into workshopreservation values(@placesreserved,@workshopid,@reservationid,0)
	if @@error = 0
		update conferencereservation
		set sum_to_pay += @sum
		where reservationid = @reservationid
go


-- procedura dodajaca uczestnika rezerwacji, do danych nalezy podac date, w ktorej 
-- go zarejestrowano. Jesli data przekracza o tydzien date rezerwacji, a uczestnik 
-- jest studentem, suma nie ulegnie zmianie

IF OBJECT_ID ('fill_conf_partic') IS NOT NULL
   DROP procedure fill_conf_partic;
GO
create procedure fill_conf_partic @personid int, @id_number char(6) = Null, @reservationid int, @date_of_adding date
as
	declare @unitprice real,@res_date date,@dayid int
	insert into conference_participants values(@personid,@id_number,@reservationid)
	set @res_date = 
			(select reservationdate
			from conferencereservation
			where reservationid = @reservationid)
	if @@error = 0 and @id_number is not null and @date_of_adding <= dateadd(d,7,@res_date)
	begin
		set @dayid = 
			(select dayid
			from conferencereservation
			where reservationid = @reservationid)
		set @unitprice = 
			(select top 1 conferencePrice 
			from fees f join confrenceday cd
			on cd.dayid = f.dayid
			where f.dayid = @dayid and @res_date >= when_is_in_force
			order by when_is_in_force desc)
		update conferencereservation
		set sum_to_pay -= @unitprice * 0.5
		where reservationid = @reservationid
	end
go

-- procedura dodajaca uczestnika warsztatu, do danych nalezy podac date, w ktorej 
-- go zarejestrowano. Jesli data przekracza o tydzien date rezerwacji, a uczestnik 
-- jest studentem, suma nie ulegnie zmianie

IF OBJECT_ID ('fill_work_partic') IS NOT NULL
   DROP procedure fill_work_partic;
GO
create procedure fill_work_partic @workresid int, @conferenceparticipantid int,@date_of_adding date
as
	declare @reservationid int,@unitprice real,@res_date date,@dayid int,@id_number char(6)
	insert into workshopparticipants values(@workresid,@conferenceparticipantid)
	set @reservationid =
		(select reservationid 
		from conference_participants
		where conferenceparticipantid = @conferenceparticipantid)
	set @res_date = 
		(select reservationdate
		from conferencereservation
		where reservationid = @reservationid)
	set @id_number =
		(select id_number
		from conference_participants cp
		where conferenceparticipantid = @conferenceparticipantid)
	if @@error = 0 and @id_number is not null and @date_of_adding <= dateadd(d,7,@res_date)
	begin
		set @dayid = 
			(select dayid
			from workshopreservation wr join workshop w
			on w.workshopid = wr.workshopid
			where workresid = @workresid)
		set @unitprice = 
			(select top 1 conferencePrice 
			from fees f join confrenceday cd
			on cd.dayid = f.dayid
			where f.dayid = @dayid and @res_date >= when_is_in_force
			order by when_is_in_force desc)
		update conferencereservation
		set sum_to_pay -= @unitprice * 0.5
		where reservationid = @reservationid
	end
go

-- procedura pokazujaca platnosci klientow, ktorzy zlozyli rezerwacje na ktorys z dni konferencji, ktorej id podajemy na wejsciu;
-- drugim argumentem jest data, ktora wskazuje na moment, w ktorym chcemy poznac stan platnosci klientow
IF OBJECT_ID ('show_payments_for_conf') IS NOT NULL
   DROP procedure show_payments_for_conf;
GO
create procedure show_payments_for_conf @conferenceid int,@recent_date date
as 
	select c.clientid,co.conferenceid, dbo.getIndividualOrCompany(c.clientid) 'client name', reservationdate,
		   sum_to_pay,
		   (select sum(isnull(amount_paid,0))
		   from conferencereservation cr1 left join paidRate pr
		   on pr.reservationid = cr1.reservationid and date_of_paying <= @recent_date
		   where cr1.clientid = c.clientid and cr1.reservationid = cr.reservationid) paid,
		   sum_to_pay - 
			   (select sum(isnull(amount_paid,0))
			   from conferencereservation cr1 left join paidRate pr
			   on pr.reservationid = cr1.reservationid and date_of_paying <= @recent_date
			   where cr1.clientid = c.clientid and cr1.reservationid = cr.reservationid) how_much_left
	from conferencereservation as cr join clients c
	on c.clientid = cr.clientid and reservationdate <= @recent_date
	join confrenceday cd
	on cd.dayid = cr.dayid
	join conferencies co
	on co.conferenceid = cd.conferenceid
	where co.conferenceid = @conferenceid    
go

execute show_payments_for_conf 1,'2000-01-10'

