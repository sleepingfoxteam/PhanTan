drop Procedure [dbo].[sp_delete_ib]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_ib]
	@username nvarchar(50)
as
begin
	begin try
		delete from dbo.InternetBanking where dbo.InternetBanking.Username = @username;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;
go
