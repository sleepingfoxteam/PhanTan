drop Procedure [dbo].[sp_update_Account_balance]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_Account_balance]
	@id nvarchar(50),
	@balance int
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.Account where dbo.Account.AccountID = @id;
	if @sum>0
	begin
		update acc
			set acc.Balance = @balance
		from dbo.Account acc
		where acc.AccountID = @id;
		return 1;
	end;
	select @sum = Count(*) from LINK.TUIBANK.dbo.Account acc where acc.AccountID = @id;
	if @sum>0
	begin
		update acc
			set acc.Balance = @balance
		from LINK.TUIBANK.dbo.Account acc
		where acc.AccountID = @id;
		return 1;
	end;
	return -1;
end;
go
