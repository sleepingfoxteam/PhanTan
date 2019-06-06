drop Procedure [dbo].[sp_insert_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_insert_the]
	@pass nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	begin try
		declare @id nvarchar(50), @sumthekhachhang int;
		select @sumthekhachhang = count(*) from dbo.The where dbo.The.KhachHang = @khachhang;
		set @sumthekhachhang = @sumthekhachhang + 1;
		set @id = CONCAT('THE',@khachhang,CAST(@sumthekhachhang as nvarchar(10)));
		-- them the --
		insert into dbo.The values (@id,@pass,@khachhang);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
