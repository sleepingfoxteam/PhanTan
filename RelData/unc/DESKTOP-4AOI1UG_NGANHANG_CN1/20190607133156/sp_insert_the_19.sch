drop Procedure [dbo].[sp_insert_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_the]
	@khachhang nvarchar(50)
as
begin
	declare @id nvarchar(50), @sumthe int;
	select @sumthe = Count(*) from dbo.The where dbo.The.KhachHang = @khachhang;
	set @sumthe = @sumthe + 1;
	set @id = CONCAT('THE',@khachhang,CAST(@sumthe as nvarchar(10)));
	-- them vao csdl --
	begin try
		insert into dbo.The values (@id,@khachhang,@khachhang,NEWID());
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;
go
