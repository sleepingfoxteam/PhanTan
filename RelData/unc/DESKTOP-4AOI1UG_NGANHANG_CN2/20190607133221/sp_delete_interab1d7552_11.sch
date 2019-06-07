drop Procedure [dbo].[sp_delete_internet_banking]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_delete_internet_banking]
	@username nvarchar(50)
as
begin
	declare @check int;
	-- check tai server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check> 0
	begin
		begin try
			-- xoa khoi csdl --
			delete from dbo.InternetBanking where dbo.InternetBanking.Username = @username;
			-- drop login --
			exec sp_droplogin @username;
			-- drop user --
			exec sp_dropuser @username;
			return 1;
		end try
		begin catch
			return -1;
		end catch;
	end;
	return -1;
end;
go
