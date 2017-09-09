-- next move
create procedure debtsDetails @special int
as
	select  n.id as nal_id, n.kwota as nal_kwota,w.id as wplatyID,w.kwota as kwota_wplaty,termin,data_wplaty
	into #ControlTable 
	from naleznosci as n join wplaty as w
	on w.naleznosci_id = n.id
	where n.id = @special    

	declare @nal_id int, @nal_kwota real, @wplatyId int, @kwota_wplaty real, @termin date, @data_wplaty date
	while exists (select * from #ControlTable)
	begin

		select top 1 @nal_id = nal_id, @nal_kwota = nal_kwota, @wplatyId = wplatyid, @kwota_wplaty = kwota_wplaty,@termin = termin, @data_wplaty = data_wplaty
		from #ControlTable
		print @kwota_wplaty

		delete #ControlTable
		where wplatyId = @wplatyId

	end
	drop table #ControlTable
	print ' '
go