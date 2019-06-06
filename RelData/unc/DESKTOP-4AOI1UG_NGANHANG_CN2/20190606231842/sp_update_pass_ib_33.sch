drop Procedure [dbo].[sp_update_pass_ib]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_pass_ib]
	@username nvarchar(50),
	@pass_new nvarchar(256)
as
begin
	begin try
		update dbo.InternetBanking
			set dbo.InternetBanking.Password = @pass_new
			where dbo.InternetBanking.Username = @username;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
