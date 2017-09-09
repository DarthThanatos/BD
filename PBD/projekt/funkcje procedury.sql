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

	--testy
	select * from conference_participants
	select dbo.check_if_student(1)
	go

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
go

--funkcja zwrcajaca id warsztatu trwajacego w tym samym czasie co warsztat o id podanym na wejsciu
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

----------------------------------------------------------------------------------------------------------
--procedury

--procedura pokazujaca dla danego dayid progi cenowe
create procedure show_fees @dayid int
as
	select *
	from fees
	where dayid = @dayid
go


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

	-- test
	execute total_cost 0
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
	
	--test
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

--jw
select  distinct cr.reservationid,wr.workresid, wr.places_reserved, wp.conferenceparticipantId,workshopparticipantid
from conferencereservation as cr join conference_participants as cp
on cr.reservationid = cp.reservationid
join workshopreservation wr
on wr.reservationid = cr.reservationid
join workshopparticipants as wp
on wp.workresid = wr.workresid
where cr.reservationid = 12
order by 1,2,3,4

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
go

--Addclients
create  PROCEDURE [dbo].[Addclients]
 	@companyname varchar(80),
	@password varchar(50),
	@surname varchar(50),
	@name varchar(50),
	@email varchar(50),
	@isindividual bit,
	@country varchar (50)


AS

BEGIN
SET NOCOUNT ON
INSERT INTO clients(
companyname ,
password ,
surname,
name ,
email ,
isindividual ,
country 
 )
VALUES(
@companyname ,
@password ,
@surname,
@name ,
@email ,
@isindividual ,
@country 

)
END




--Addconferencies
go
create  PROCEDURE [dbo].[Addconferencies]

	@fromdate date,
	@todate date,
	@topic varchar(50),
	@street varchar(50),
	@city varchar(50)

	

AS

BEGIN
SET NOCOUNT ON
INSERT INTO conferencies(
	fromdate,
	todate  ,
	topic   ,
	street  ,
	city    
)

VALUES(
	@fromdate,
	@todate ,
	@topic ,
	@street ,
	@city 

)
END


--Addconfrenceday
go
create procedure [dbo].[Addconfrenceday]
	@places_available int, 
	@conferenceid int,
	@date_of_day date
	
AS
BEGIN
SET NOCOUNT ON

INSERT INTO confrenceday(
	places_available ,
	conferenceid,
	date_of_day)

VALUES(

	@places_available ,
	@conferenceid,
	@date_of_day 

)


END


go
--Addfees
create  PROCEDURE [dbo].[Addfees]
 		@when_is_in_force date,
		@dayid int,
		@conferencePrice real
	

AS

BEGIN
SET NOCOUNT ON
INSERT INTO fees(when_is_in_force,dayid,conferencePrice)
VALUES(
	@when_is_in_force ,
	@dayid ,
	@conferencePrice 
)
END


--AddpaidRate
go
create  PROCEDURE [dbo].[AddpaidRate]
 		@reservationid int,
		@date_of_paying date,
		@amount_paid real
	

AS

BEGIN
SET NOCOUNT ON
INSERT INTO paidRate(reservationid,date_of_paying,amount_paid)
VALUES(
@reservationid,
@date_of_paying,
@amount_paid
)
END

go
--AddPeople

create PROCEDURE [dbo].[AddPeople]
 @surname varchar(15),
 @name varchar(15),
 @phone char(14),
 @country varchar(50),
 @city varchar(50),
 @street varchar(50)
	

AS
BEGIN
SET NOCOUNT ON
INSERT INTO People(surname,name,phone,country,city,street)
VALUES(
	@surname ,
	@name ,
	@phone ,
	@country,
	@city ,
	@street 
)
END

--Addworkshop
go
create  PROCEDURE [dbo].[Addworkshop]
	@quote real ,
	@street varchar(50),
	@end_hour time,
	@starting_hour time,
	@topic varchar(50),
	@dayid int,
	@places_available int 

AS

BEGIN
SET NOCOUNT ON

INSERT INTO workshop(

quote,
street,
end_hour,
starting_hour,
topic,
dayid,
places_available

 )
VALUES(
	@quote,
	@street,
	@end_hour,
	@starting_hour,
	@topic,
	@dayid,
	@places_available

)
END

---updatePeople
----People
---()Zmien_dane
go
CREATE PROCEDURE [dbo].[UpdatePeople]


	@personid int  			= NULL,/* po tym aktualizujemy  */
	@surname varchar(15)	= NULL,
	@name varchar(15)		= NULL,
	@phone char(14) 		= NULL,
	@country varchar(50)	= NULL,
	@city varchar(50)		= NULL,
	@street varchar(50)		= NULL

	
AS
BEGIN 
      SET NOCOUNT ON 

	  
      UPDATE dbo.People	
      SET 	
			 surname    =ISNULL(@surname,surname)  ,
			 name 	    =ISNULL(@name,name)        ,
			 phone  	=ISNULL(@phone,phone)      ,
			 country    =ISNULL(@country,country)  ,
			 city       =ISNULL(@city,city)        ,
			 street 	=ISNULL(@street,street)
			 
			 
      FROM   dbo.People
      WHERE  
      personid=@personid               

END
go

--Update_places_reserved_IN_workshopreservation
--()Zmien_ilosc_miejsc_na_warsztaty

create procedure [dbo].[Update_places_reserved_IN_workshopreservation]
	@workresid int ,
	@places_reserved int
AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.workshopreservation
	SET places_reserved=@places_reserved
	FROM dbo.workshopreservation
	where workresid=@workresid
END
go

--Update
--Zmien_ilosc_miejsc_w_rezerwacji(
create procedure [dbo].[Update_palces_reserved_IN_conferencereservation]
	@reservationid int,
	@places_reserved int 

AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.conferencereservation
	SET	places_reserved=@places_reserved 
	FROM dbo.conferencereservation
	where reservationid=@reservationid
END
go

-- Zmien_limit_miejsc_dnia_konf(
--Update_places_available_IN_confrenceday
create PROCEDURE [dbo].[Update_places_available_IN_confrenceday]
	@dayid int ,
	@places_available int
AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.confrenceday
	SET places_available=@places_available
	FROM dbo.confrenceday
	WHERE dayid=@dayid
END
go

--Zmien_limit_miejsc_warsztatu(
--Update_places_available_IN_workshop

create PROCEDURE [dbo].[pdate_places_available_IN_workshop]
	@workshopid int ,
	@places_available int

AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.workshop
	SET
	places_available=@places_available
	FROM dbo.workshop
	WHERE	 workshopid=@workshopid
END	
go



--Cancel_conferencereservation
create PROCEDURE [dbo].[Cancel_conferencereservation] @reservationid int
AS
BEGIN
	SET NOCOUNT ON
	--- anuluj podlegle workshopreservation
	UPDATE  dbo.workshopreservation
	SET is_canceled=1
	FROM  dbo.workshopreservation
	WHERE reservationid=@reservationid 
	--anuluj conferencereservation
	UPDATE  dbo.conferencereservation
	SET iscanceled=1
	FROM  dbo.conferencereservation
	WHERE reservationid=@reservationid 

END

go

--Cancel_workshopreservation
create PROCEDURE [dbo].[Cancel_workshopreservation] @workresid int
AS
BEGIN
	SET NOCOUNT ON
	UPDATE  dbo.workshopreservation
	SET is_canceled=1
	FROM  dbo.workshopreservation
	WHERE workresid=@workresid 
END
go

--Restore_conferencereservation
create PROCEDURE [dbo].[Restore_conferencereservation]
@reservationid int
AS
BEGIN
	SET NOCOUNT ON
	UPDATE  dbo.conferencereservation
	SET iscanceled=0
	FROM  dbo.conferencereservation
	WHERE reservationid=@reservationid 
	--przywroc podlegle rezerwaje warsztatu
	update workshopreservation
	set is_canceled = 0
	where reservationid = @reservationid
END
go

--Restore_workshopreservation
create PROCEDURE [dbo].[Restore_workshopreservation]
@workresid int
AS
BEGIN
	SET NOCOUNT ON
	if 
		(select iscanceled 
		from dbo.conferencereservation 
		where reservationid=(
					select reservationid 
					from dbo.workshopreservation 
					where workresid=@workresid))=0
	
		BEGIN	
				UPDATE  dbo.workshopreservation
				SET is_canceled=0
				FROM  dbo.workshopreservation
				WHERE workresid=@workresid 	
		END
END
go



