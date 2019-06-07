drop Procedure [dbo].[sp_insert_nhanvien]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_nhanvien]
	@hoten nvarchar(200),
	@ngaysinh date,
	@luongcb int,
	@heso float,
	@diachi text,
	@sdt nvarchar(20),
	@chinhanh nvarchar(50)
as
begin
	declare @id nvarchar(50), @sumnhanvienchinhanh int;
	select @sumnhanvienchinhanh = Count(*) from dbo.NhanVien where dbo.NhanVien.ChiNhanh = @chinhanh;
	set @sumnhanvienchinhanh = @sumnhanvienchinhanh + 1;
	begin try
		set @id = CONCAT('NV',@chinhanh,CAST(@sumnhanvienchinhanh as nvarchar(10)));
		-- them vao csdl --
		insert into dbo.NhanVien values (@id,@hoten,@ngaysinh,@luongcb,@heso,@chinhanh,@diachi,@sdt,NEWID());
		-- tao login --
		exec sp_addlogin @id,@id;
		-- them vao role --
		exec sp_adduser @id,@id;
		exec sp_addrolemember 'NhanVien',@id;
		-- them server role member --
		exec sp_addsrvrolemember @id, 'processadmin';
		exec sp_addsrvrolemember @id, 'sysadmin';

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
go
