drop Procedure [dbo].[sp_update_khachhang]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_khachhang]
	@id nvarchar(50),
	@hoten nvarchar(200),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as 
begin
	begin try
		update dbo.KhachHang
		set dbo.KhachHang.DiaChi = @diachi,
			dbo.KhachHang.Hoten = @hoten,
			dbo.KhachHang.Sdt = @sdt,
			dbo.KhachHang.NgaySinh = @ngaysinh
		where dbo.KhachHang.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
