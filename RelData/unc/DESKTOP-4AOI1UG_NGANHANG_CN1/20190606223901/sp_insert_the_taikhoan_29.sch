drop Procedure [dbo].[sp_insert_the_taikhoan]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_insert_the_taikhoan]
	@the_id nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		-- them vao csdl --
		insert into dbo.The_TaiKhoan values(@the_id,@taikhoan_id);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
