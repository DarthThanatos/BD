CREATE TABLE stawki (   dzien DATE NOT NULL,   stawka DECIMAL NULL,   PRIMARY KEY(dzien) );  
CREATE TABLE naleznosci (   id INTEGER NOT NULL,   kwota DECIMAL NULL,   termin DATE NULL,   PRIMARY KEY(id) )  
CREATE TABLE wplaty (   id INTEGER NOT NULL,   naleznosci_id INTEGER NOT NULL,   kwota DECIMAL NULL,   data_wplaty DATE NULL,   PRIMARY KEY(id),   FOREIGN KEY(naleznosci_id)     REFERENCES naleznosci(id)        )

select n.id,n.kwota,w.kwota w_kwota
from naleznosci as n join wplaty as w
on n.id = w.naleznosci_id
go
--having sum(w.kwota) != max(n.kwota)

create function maximum(@val1 int, @val2 int)
returns int
as
begin
  if @val1 > @val2
    return @val1
  return isnull(@val2,@val1)
end
go


create function minimum_date(@val1 date, @val2 date)
returns date
as
begin
  if @val1 < @val2
    return @val1
  return isnull(@val2,@val1)
end
go

select dbo.minimum_date('2000-01-01','2001-12-12')

drop function dbo.minimum 
go

--selecting special
create procedure getSpecial @special int output
as
set @special = 
	(select n.id
	from naleznosci as n join wplaty as w
	on w.naleznosci_id = n.id
	group by n.id,termin
	having  year(max(data_wplaty)) - year(max(termin)) > 1)
go

declare @special int
execute getSpecial @special output
select 'special id: ', @special
go

create procedure getDateRange @id int, @start date output, @end date output
as
	set @start = (select dateadd(d,1,termin) --debt starts one day after deadline  
	from naleznosci 
	where id = @id)

	set @end = (select max(data_wplaty)
	from wplaty as w join naleznosci as n
	on w.naleznosci_id = n.id
	where n.id = @id
	group by termin)
go

create procedure detectRatesDates @start date, @end date
as
	declare @payRateDate date, @stake real, @starting_date date, @ending_date date
	declare @res table (payRateDay date, starting_date date,end_date date, stake real)
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

		insert into @res values( @payRateDate, @starting_date, @ending_date,@stake)
	end
	select * from @res
go

drop procedure detectRatesDates

declare @special int, @start date, @end date
execute getSpecial @special output
execute getDateRange @special, @start output, @end output
execute fill_Result @start, @end,@special

execute detectRatesDates @start,@end

select * 
from naleznosci as n join wplaty as w
on w.naleznosci_id = n.id
where n.id = @special

--wszyscy dluznicy
select *
from naleznosci as n join wplaty as w
on w.naleznosci_id = n.id
where n.id in 
	(select n.id
	from naleznosci as n join wplaty as w
	on w.naleznosci_id = n.id
	group by n.id,termin
	having max(termin)  < max(data_wplaty) ) 

--wszyscy dluznicy wariant II
select n.id
from naleznosci as n join wplaty as w
on w.naleznosci_id = n.id
group by n.id,termin
having max(termin)  < max(data_wplaty)

select * from stawki order by dzien


select  n.id as nal_id, n.kwota as nal_kwota,w.id as wplatyID,w.kwota as kwota_wplaty,termin,data_wplaty
into #ControlTable 
from naleznosci as n join wplaty as w
on w.naleznosci_id = n.id
where n.id = @special    

--declare @TableID table(nal_id int, nal_kwota real, wplatyId int, kwota_wplaty real, termin date,data_wplaty date)
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

select n.id,data_wplaty
from naleznosci as n join wplaty as w
on n.id = w.naleznosci_id

select n.id,termin, max(data_wplaty)
from naleznosci as n join wplaty as w
on w.naleznosci_id = n.id
group by n.id,termin
having max(termin)  < max(data_wplaty)
