drop Procedure [dbo].[sp_delete_ib_taikhoan]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_ib_taikhoan]
	@username nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		delete from dbo.IB_TaiKhoan 
		where dbo.IB_TaiKhoan.Username = @username
			and dbo.IB_TaiKhoan.TaiKhoan = @taikhoan_id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
