drop Procedure [dbo].[sp_update_Account]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_Account]
	@id nvarchar(50),
	@period int,
	@interest float,
	@balance int,
	@startdate date,
	@enddate date
as
begin
	begin try
		update a
		set a.Balance = @balance,
			a.Period = @period,
			a.Interest = @interest,
			a.StartDate = @startdate,
			a.EndDate = @enddate
		from dbo.Account a
		where a.AccountID = @id;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
