drop Procedure [dbo].[sp_update_nhanvien_quanly]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_nhanvien_quanly]
	@id nvarchar(50),
	@luongcb int,
	@heso float
as
begin
	begin try
		update dbo.NhanVien
			set dbo.NhanVien.HeSo = @heso,
				dbo.NhanVien.LuongCB = @luongcb
			where dbo.NhanVien.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
go
