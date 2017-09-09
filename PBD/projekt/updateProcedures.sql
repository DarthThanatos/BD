---updatePeople
----People
---()Zmien_dane

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

