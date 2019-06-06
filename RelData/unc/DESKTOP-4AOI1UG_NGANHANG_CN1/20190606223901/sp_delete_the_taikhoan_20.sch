drop Procedure [dbo].[sp_delete_the_taikhoan]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_delete_the_taikhoan]
	@the_id nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		-- them vao csdl --
		delete from dbo.The_TaiKhoan
			where dbo.The_TaiKhoan.The = @the_id
				and dbo.The_TaiKhoan.TaiKhoan = @taikhoan_id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
