drop Procedure [dbo].[sp_update_pass_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_pass_the]
	@id nvarchar(50),
	@pass_new nvarchar(256)
as
begin
	begin try
		update dbo.The
			set dbo.The.Password = @pass_new
			where dbo.The.ID = @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
