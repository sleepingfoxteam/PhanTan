drop Procedure [dbo].[sp_select_nhanvien]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_select_nhanvien]
	@hoten nvarchar(200),
	@sdt nvarchar(20),
	@luongcb int,
	@heso float
as
begin
	declare @select int;
	select @select = Count(*) from dbo.NhanVien
		where dbo.NhanVien.HoTen = @hoten
			or dbo.NhanVien.Sdt = @sdt
			or dbo.NhanVien.LuongCB = @luongcb
			or dbo.NhanVien.HeSo = @heso;
	if @select = 0
	begin
		select * from LINK.NganHang.dbo.NhanVien as nv
				where nv.HoTen = @hoten
					or nv.Sdt = @sdt
					or nv.LuongCB = @luongcb
					or nv.HeSo = @heso;
	end
	else
	begin
		select * from dbo.NhanVien
				where dbo.NhanVien.HoTen = @hoten
					or dbo.NhanVien.Sdt = @sdt
					or dbo.NhanVien.LuongCB = @luongcb
					or dbo.NhanVien.HeSo = @heso;
	end
end;
go
