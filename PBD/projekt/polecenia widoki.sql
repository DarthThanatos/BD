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

go

-- zwraca dla reservationid ilosc zarezerwowanych miejsc i ilosc studentow
select  places_reserved, count(id_number) students
from conferencereservation as cr left join conference_participants as cp
on cp.reservationid = cr.reservationid 
where  cr.reservationid = 2
group by cr.reservationid,places_reserved
go


-- dla kazdej rezerwacji pokaz id uczestnikow zarejestrowanych
select cr.reservationid, places_reserved,cp.conferenceparticipantid,cp.personid
from conferencereservation as cr join conference_participants as cp
on cr.reservationid = cp.reservationid
where cr.reservationid = 0
order by 1,2

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

--pokazuje sume zarezerwowanych miejsc w danym dniu
select cd.dayid,date_of_day,places_available,sum(distinct places_reserved) [suma miejsc kazdej rezerwacji dot. okreslonego dnia]
from confrenceday as cd join conferencereservation as cr 
on cr.dayid= cd.dayid
group by cd.dayid,places_available,date_of_day
go


-- pokazuje ilosc zarezerwowanych miejsc w danym warsztacie i zestawia z dostepnymi miejscami
select w.workshopid,places_available,sum(places_reserved) [suma miejsc kazdej rezerwacji dot. okreslonego warsztatu]
from workshopreservation as wr join workshop as w
on w.workshopid = wr.workshopid
where w.workshopid = 183
group by w.workshopid,places_available

go


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
--------------------------------------------------------------------------------------------------------------------------
--widoki
create view VIPS_reservations
as
	select c.clientid, dbo.getIndividualOrCompany(c.clientid) name, sum(dbo.get_res_amount(reservationid)) 'amount of reservations'
	from clients c join conferencereservation cr
	on cr.clientid = c.clientid
	group by c.clientid
go

select * from VIPS_reservations order by 3 desc
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

	--test
	select * from costs where iscanceled = 0 and abs([sum to pay] - sum_paid) > 0.5
	go

	select * from workshop_costs order by 1 go

