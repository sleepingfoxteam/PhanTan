drop Procedure [dbo].[sp_delete_staff]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_staff]
	@id nvarchar(50)
as
begin
	begin try
		-- delete from database
		delete from dbo.Staff where dbo.Staff.StaffID = @id;
		-- delete login --
		exec sp_droplogin @id;
		-- delete user --
		exec sp_dropuser @id;

		return 1; -- success--
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
