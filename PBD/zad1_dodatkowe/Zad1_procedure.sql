-- proper procedure
create procedure fill_Result @IdNaleznosci int
as
	declare @payRateDate date, @stake real, @starting_date date, @ending_date date, @debt real, @payRate real, @daysAmount int, @recent_debt real
	declare @res table (IdNaleznosci int, payRateDay date, starting_date date, end_date date, daysAmount int, stake real,debt real,	payRate real)
	declare @start date, @end date
	set @recent_debt = 
		(select sum(w.kwota)
		from naleznosci as n join wplaty as w 
		on w.naleznosci_id = n.id and termin < data_wplaty
		where n.id = @IdNaleznosci 
		group by n.id)
	set @start = (select termin  from naleznosci where id = @IdNaleznosci) 
	set @end = (select max(data_wplaty) from naleznosci as n join wplaty as w on n.id = w.naleznosci_id where n.id = @IdNaleznosci group by n.id)
	while @start < @end
	begin
		set @payRateDate = 
			(select top 1 dzien
			from stawki
			where dzien <= @start
			order by 1 desc)
		set @starting_date = @start
		set @ending_date = 
			(select top 1 dzien
			from stawki
			where dzien > @start
			order by 1)
		set @start = @ending_date
		set @ending_date = dbo.minimum_date(@end,dateadd(d,-1,@ending_date))
		set @stake = 
			(select stawka 
			from stawki
			where @payRateDate = dzien)
		set @debt = 
			(select isnull( sum(w.kwota),0)
			from wplaty as w right join naleznosci as n
			on w.naleznosci_id = n.id and (w.data_wplaty between @starting_date and @ending_date)
			where @IdNaleznosci = n.id 
			group by n.id
			)
		if @debt = 0 begin set @debt = @recent_debt end
		else set @recent_debt = @debt
		set @daysAmount = (select datediff(d,@starting_date,@ending_date))
		set @payRate = @stake / 100 * @daysAmount / 365 * @debt
		insert into @res values(@IdNaleznosci, @payRateDate, @starting_date, @ending_date,@daysAmount,@stake,@debt,@payRate)
	end
	select * from @res 
go
