drop Procedure [dbo].[sp_send_money]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_send_money]
	@sourceaccount nvarchar(50),
	@destinationaccount nvarchar(50),
	@money int
as
begin
	declare @source_balance int, @destination_balance int;
	exec @source_balance = sp_get_balance @sourceaccount;
	exec @destination_balance = sp_get_balance @destinationaccount;
	set @source_balance = @source_balance - @money;
	set @destination_balance = @destination_balance + @money;
	if @source_balance<0
	begin
		return -1;
	end;
	exec sp_update_Account_balance @sourceaccount, @source_balance;
	exec sp_update_Account_balance @destinationaccount, @destination_balance;
	return 1;
end;
go
