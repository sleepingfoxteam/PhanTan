drop Procedure [dbo].[sp_delete_khachhang]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_delete_khachhang]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.KhachHang where dbo.KhachHang.ID = @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
