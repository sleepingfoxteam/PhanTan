drop Procedure [dbo].[sp_get_balance]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_get_balance]
	@accountnumber nvarchar(50)
as
begin
	declare @sum int, @balance int;
	select @sum = Count(*) from dbo.Account where dbo.Account.AccountID = @accountnumber;
	if @sum>0
	begin
		select @balance = acc.Balance from dbo.Account acc where acc.AccountID = @accountnumber;
		return @balance;
	end;
	select @sum = Count(*) from LINK.TUIBANK.dbo.Account acc where acc.AccountID = @accountnumber;
	if @sum>0
	begin
		select @balance = acc.balance from LINK.TUIBANK.dbo.Account acc where acc.AccountID = @accountnumber;
		return @balance;
	end;
	return -1;
end;
go
