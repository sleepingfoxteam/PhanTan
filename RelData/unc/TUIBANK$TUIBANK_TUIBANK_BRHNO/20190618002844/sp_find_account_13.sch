drop Procedure [dbo].[sp_find_account]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_find_account]
	@accountnumber nvarchar(50)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.Account where dbo.Account.AccountID = @accountnumber;
	if @sum>0
	begin
		select acc.AccountID as accountnumber, acc.Balance as accountbalance,
				acc.Period as accountperiod, acc.Interest as accountinterest,
				acc.StartDate as accountstartdate
		from dbo.Account acc
		where acc.AccountID = @accountnumber;
	end;
	select @sum = COUNT(*) from LINK.TUIBANK.dbo.Account acc where acc.AccountID = @accountnumber;
	if @sum>0
	begin
		select acc.AccountID as accountnumber,
			acc.Balance as accountbalance,
			acc.Period as accountperiod,
			acc.Interest as accountinterest,
			acc.StartDate as accountstartdate
		from LINK.TUIBANK.dbo.Account acc
		where acc.AccountID = @accountnumber;
	end;
	return -1;
end;
go
