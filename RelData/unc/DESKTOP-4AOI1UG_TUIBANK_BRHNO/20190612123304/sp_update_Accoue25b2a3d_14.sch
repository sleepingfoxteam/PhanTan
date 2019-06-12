drop Procedure [dbo].[sp_update_Account_balance]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_Account_balance]
	@id nvarchar(50),
	@balance int
as
begin
	update a
		set a.Balance = @balance
	from dbo.Account a
	where a.AccountID = @id;
end;
go
