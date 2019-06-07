drop Procedure [dbo].[sp_delete_khachhang]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_khachhang]
	@id nvarchar(50)
as
begin
	declare @username nvarchar(50), @sum int;
	select @sum = Count(*) from dbo.KhachHang where dbo.KhachHang.ID = @id;
	if @sum > 0
	begin
		-- lay Username cua Khach Hang (neu co) --
		select @username = ib.Username
		from dbo.InternetBanking ib
		where ib.KhachHang = @id;
		-- xoa trong csdl -- --> tu xoa trong InternetBanking do FK
		delete from dbo.KhachHang where dbo.KhachHang.ID = @id;
		if @username is not NULL
		begin
			return exec sp_delete_internet_banking @username;
		end;
	end;
end;
go
