drop Procedure [dbo].[sp_update_nhanvien_nhanvien]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_nhanvien_nhanvien]
	@id nvarchar(50),
	@hoten nvarchar(200),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as 
begin
	begin try
		update dbo.NhanVien
			set dbo.NhanVien.HoTen = @hoten,
				dbo.NhanVien.NgaySinh = @ngaysinh,
				dbo.NhanVien.DiaChi = @diachi,
				dbo.NhanVien.Sdt = @sdt
			where dbo.NhanVien.ID = @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
