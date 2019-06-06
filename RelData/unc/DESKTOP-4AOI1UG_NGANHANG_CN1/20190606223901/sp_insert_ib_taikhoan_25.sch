drop Procedure [dbo].[sp_insert_ib_taikhoan]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_ib_taikhoan]
	@username nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	-- them vao csdl --
	begin try
		insert into dbo.IB_TaiKhoan values (@username,@taikhoan_id);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
