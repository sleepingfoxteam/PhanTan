drop Procedure [dbo].[sp_delete_nhanvien]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_delete_nhanvien]
	@id nvarchar(50)
as
begin
	begin try
		-- xoa trong csdl --
		delete from dbo.NhanVien where dbo.NhanVien.ID = @id;
		-- xoa login --
		exec sp_droplogin @id;
		-- xoa user trond database --
		exec sp_dropuser @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;

go
