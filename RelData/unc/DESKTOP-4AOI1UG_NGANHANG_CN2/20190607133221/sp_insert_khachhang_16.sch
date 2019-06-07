drop Procedure [dbo].[sp_insert_khachhang]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_khachhang]
	@hoten nvarchar(200),
	@chinhanh nvarchar(50),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as
begin
	declare @id nvarchar(50), @sumkhachhang int;
	select @sumkhachhang = Count(*) from dbo.KhachHang where dbo.KhachHang.ChiNhanh = @chinhanh;
	set @sumkhachhang = @sumkhachhang + 1;
	set @id = CONCAT('KH',@chinhanh,CAST(@sumkhachhang as nvarchar(10)));
	-- them vao csdl --
	begin try
		insert into dbo.KhachHang values (@id,@hoten,@chinhanh,@ngaysinh,@diachi,@sdt,NEWID());
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
go
