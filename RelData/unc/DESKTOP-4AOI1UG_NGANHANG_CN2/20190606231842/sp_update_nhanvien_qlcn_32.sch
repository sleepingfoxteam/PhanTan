drop Procedure [dbo].[sp_update_nhanvien_qlcn]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_nhanvien_qlcn]
	@id nvarchar(50),
	@heso float,
	@luongcb int
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
