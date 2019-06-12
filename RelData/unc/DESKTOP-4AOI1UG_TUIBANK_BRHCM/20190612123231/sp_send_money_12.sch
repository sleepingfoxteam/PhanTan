drop Procedure [dbo].[sp_send_money]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_send_money]
	@sourceaccount nvarchar(50),
	@destinationaccount nvarchar(50),
	@money int
as
begin
	declare @sourcemoney int, @destinationmoney int;
	select @sourcemoney = a.Balance
		from dbo.Account a
		where a.AccountID = @sourceaccount;
	select @destinationmoney = a.Balance
		from dbo.Account a
		where a.AccountID = @destinationaccount;
	-- update source account --
	begin try
		set @sourcemoney = @sourcemoney - @money;
		exec sp_update_Account_balance @sourceaccount, @sourcemoney;
		-- update destination account --
		set @destinationmoney = @destinationmoney + @money
		exec sp_update_Account_balance @destinationaccount, @destinationmoney;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
