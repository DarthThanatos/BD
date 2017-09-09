create procedure fill_Result2 @roomId int, @start date, @end date
as
	declare @name varchar(20),@daysAmount int, @price real, @value real, @stake_price real
	declare @res table([Id pokoju] int, [Nazwa pokoju] varchar(20),[Pobyt od] date, [Pobyt do] date, [liczba dni] int, cena real, wartosc real)
	declare @starting_date date, @ending_date date, @from_date date,@to_date date
	set @name = (select nazwa from pokoje where id = @roomId)
	while @start <= @end
	begin
		set @starting_date = @start
		set @from_date = 
			(select top 1 data_od
			from okresy
			where data_od <= @starting_date
			order by 1 desc ) 
		set @to_date =
			(select data_do
			from okresy
			where data_od = @from_date)
		set @ending_date = dbo.minimum_date(@end,@to_date)
		set @start = 
			(select  top 1 data_od
			from okresy
			where data_od > @ending_date 
			order by 1 asc)
		set @stake_price = 
			(select cena
			from ceny as c join pokoje as p
			on p.id = c.pokoje_id
			join okresy as o
			on c.okresy_id = o.id
			where data_od = @from_date and p.id = @roomId)
		set @daysAmount = datediff(d,@starting_date,@ending_date) + 1
		set @value = @daysAmount * @stake_price
		insert into @res values(@roomId, @name, @starting_date, @ending_date,@daysAmount,@stake_price, @value)
	end
	select * from @res
go

