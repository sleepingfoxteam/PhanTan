drop Procedure [dbo].[sp_delete_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_delete_the]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.The where dbo.The.ID = @id;
		return -1;
	end try
	begin catch
		return 1;
	end catch;
end

go
