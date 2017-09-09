use bielas_a
IF OBJECT_ID('dbo.paidRate', 'U') IS NOT NULL
	drop table paidRate
IF OBJECT_ID('dbo.workshopparticipants', 'U') IS NOT NULL
	drop table workshopparticipants
IF OBJECT_ID('dbo.conference_participants', 'U') IS NOT NULL
	drop table conference_participants
IF OBJECT_ID('dbo.workshopreservation', 'U') IS NOT NULL
	drop table workshopreservation
IF OBJECT_ID('dbo.workshop', 'U') IS NOT NULL
	drop table workshop
IF OBJECT_ID('dbo.fees', 'U') IS NOT NULL
	drop table fees
IF OBJECT_ID('dbo.conferencereservation', 'U') IS NOT NULL
	drop table conferencereservation
IF OBJECT_ID('dbo.confrenceday', 'U') IS NOT NULL
	drop table confrenceday
IF OBJECT_ID('dbo.conferencies', 'U') IS NOT NULL
	drop table conferencies
IF OBJECT_ID('dbo.People', 'U') IS NOT NULL
	drop table People
IF OBJECT_ID('dbo.clients', 'U') IS NOT NULL
	drop table clients

create table fees(
	feeid int primary key identity(0,1),
	when_is_in_force date,
	dayid int,
	conferencePrice real,
	INDEX fees_FKIndex1(dayid)
)

create table conferencies(
	conferenceid int primary key identity(0,1),
	fromdate date,
	todate date,
	topic varchar(50),
	street varchar(50),
	city varchar(50)
)

create table workshop(
	workshopid int primary key identity(0,1),
	quote real check(quote >=0),
	street varchar(50),
	end_hour time,
	starting_hour time,
	topic varchar(50),
	dayid int,
	places_available int check(places_available >= 0),
	INDEX workshop_FKIndex1(dayid)
)

create table conferencereservation(
	reservationid int primary key identity(0,1),
	places_reserved int ,
	iscanceled bit,
	sum_to_pay real check(sum_to_pay >= 0),
	reservationdate date,
	clientid int,
	dayid int,
	INDEX conferencereservation_FKIndex1(clientid),
	INDEX conferencereservation_FKIndex2(dayid)
)

create table confrenceday(
	dayid int primary key identity(0,1),
	places_available int check(places_available >= 0),
	conferenceid int,
	date_of_day date
	INDEX confrenceday_FKIndex1(conferenceid)
)


create table workshopreservation(
	workresid int primary key identity(0,1),
	places_reserved int check (places_reserved >= 0),
	workshopid int,
	reservationid int,
	is_canceled bit,
	INDEX workshopreservation_FKIndex1(workshopid),
	INDEX workshopreservation_FKIndex2(reservationid)
)


create table People(
	personid int primary key identity(0,1),
	surname varchar(15),
	name varchar(15),
	phone char(14) check(phone like '[0-9][0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9] [0-9][0-9]'),
	country varchar(50),
	city varchar(50),
	street varchar(50)
)

create table paidRate(
		reservationid int,
		date_of_paying date,
		amount_paid real,
		paidRateId int primary key identity(0,1),
		INDEX conferencereservation_FKIndex1(reservationid)
)

create table conference_participants(
	personid int,
	id_number char(6) check(id_number like '[0-9][0-9][0-9][0-9][0-9][0-9]'),
	reservationid int,
	conferenceparticipantId int primary key identity(0,1),
	INDEX conference_participants_FKIndex1(reservationid),
	INDEX conference_participants_FKIndex2(personid)
)

create table workshopparticipants(
	workresid int,
	conferenceparticipantid int,
	workshopparticipantid int primary key identity(0,1),
	INDEX workshopparticipants_FKIndex1(workresid),
	INDEX workshopparticipants_FKIndex2(conferenceparticipantid)
)

create table clients(
	clientid int primary key identity(0,1),
	companyname varchar(80),
	password varchar(50) not null,
	surname varchar(50),
	name varchar(50),
	email varchar(50) not null,
	isindividual bit not null,
	country varchar (50) not null
)

alter table conferencereservation
add foreign key (clientid)
references clients(clientid)

alter table conferencereservation
add foreign key (dayid)
references confrenceday(dayid)

alter table fees
add foreign key (dayid)
references confrenceday(dayid)

alter table workshop
add foreign key (dayid)
references confrenceday(dayid)

alter table workshopreservation
add foreign key (workshopid)
references workshop(workshopid)

alter table workshopreservation
add foreign key (reservationid)
references conferencereservation(reservationid)

alter table workshopparticipants
add foreign key (workresid)
references workshopreservation(workresid)

alter table workshopparticipants
add foreign key (conferenceparticipantid)
references conference_participants(conferenceparticipantid)

alter table conference_participants
add foreign key (personid)
references People(personid)

alter table conference_participants
add foreign key (reservationid)
references conferencereservation(reservationid)

alter table paidRate
add foreign key (reservationid)
references conferencereservation(reservationid)

alter table confrenceday
add foreign key (conferenceid)
references conferencies(conferenceid)

