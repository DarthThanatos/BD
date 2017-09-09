
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



