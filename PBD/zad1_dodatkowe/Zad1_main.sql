create procedure main
as
	create table Zad1(
		IdNaleznosci int,
		payRateDay date, 
		starting_date date,
		end_date date, 
		daysAmount int, 
		stake real,
		debt real,
		payRate real
	)

	select  n.id 
	into #DelayedIds 
	from naleznosci as n join wplaty as w
	on w.naleznosci_id = n.id
	group by n.id,termin
	having max(termin)  < max(data_wplaty)   
	declare @nal_id int,@start date, @end date
	while exists (select * from #DelayedIds)
	begin
		select top 1 @nal_id = id
		from #DelayedIds
		set @start = (select termin  from naleznosci where id = @nal_id) 
		set @end = (select max(data_wplaty) from naleznosci as n join wplaty as w on n.id = w.naleznosci_id where n.id = @nal_id group by n.id)
		execute fill_Result @start, @end, @nal_id
		delete #DelayedIds
		where id = @nal_id
	end
	drop table #DelayedIds
	select * from Zad1
	drop table Zad1
go

execute fill_Result 1