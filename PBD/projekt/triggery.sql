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


insert into workshopparticipants values(45,500)
select * from workshopparticipants
delete from workshopparticipants where workshopparticipantid = 57608

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