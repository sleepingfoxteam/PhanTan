drop Procedure [dbo].[sp_insert_tktt]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_tktt]
	@khachhang nvarchar(50),
	@chinhanh nvarchar(50),
	@sodu int
as
begin
	declare @id nvarchar(50), @sumtktt_this int, @sumtktt_server int;
	select @sumtktt_this = Count(*) from dbo.TKTT where dbo.TKTT.KhachHang = @khachhang;
	select @sumtktt_server = Count(*) from LINK.NganHang.dbo.TKTT tktt where tktt.KhachHang = @khachhang;
	set @sumtktt_this = @sumtktt_this + @sumtktt_server + 1;
	set @id = CONCAT('9800',@khachhang,CAST(@sumtktt_this as nvarchar(10)));
	-- them vao csdl --
	insert into dbo.TKTT values (@id,@khachhang,@chinhanh,@sodu,NEWID());
end;
go
