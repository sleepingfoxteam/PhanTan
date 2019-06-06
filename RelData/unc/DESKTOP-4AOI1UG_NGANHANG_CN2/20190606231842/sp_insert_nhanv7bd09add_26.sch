drop Procedure [dbo].[sp_insert_nhanvien_quanly]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_insert_nhanvien_quanly]
	@hoten nvarchar(200),
	@ngaysinh date,
	@luongcb int,
	@heso float,
	@chinhanh nvarchar(50),
	@diachi text,
	@sdt nvarchar(20)
as
begin
	declare @sumnhanvienchinhanh int, @id nvarchar(50);
	select @sumnhanvienchinhanh = Count(*) from dbo.NhanVien where dbo.NhanVien.ChiNhanh = @chinhanh;
	set @sumnhanvienchinhanh = @sumnhanvienchinhanh + 1;
	set @id = CONCAT('NV',@chinhanh,CAST(@sumnhanvienchinhanh as nvarchar(10)));
	begin try
		insert into dbo.NhanVien values(@id,@hoten,@ngaysinh,@luongcb,@heso,@chinhanh,@diachi,@sdt);
		-- them login --
		exec sp_addlogin @id,@id;
		-- them user --
		exec sp_adduser @id,@id;
		-- them rolemember --
		exec sp_addrolemember 'NhanVien', @id;
		-- gan server role --
		exec sp_addsrvrolemember @id, 'processadmin';
		exec sp_addsrvrolemember @id, 'sysadmin';
		exec sp_addsrvrolemember @id, 'securityadmin';
	end try
	begin catch
		print 'bi loi nang';
	end catch;
end;

go
