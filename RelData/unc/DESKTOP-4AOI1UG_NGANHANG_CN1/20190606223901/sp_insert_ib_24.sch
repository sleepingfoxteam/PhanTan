drop Procedure [dbo].[sp_insert_ib]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_insert_ib]
	@username nvarchar(50),
	@pass nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	begin try
		-- insert into database --
		insert into dbo.InternetBanking values(@username,@pass,@khachhang);
		-- them login --
		exec sp_addlogin @username,@pass;
		-- them user --
		exec sp_adduser @username, @username;
		-- them rolemember --
		exec sp_addrolemember @username, 'KhachHang';
		-- them role server --
		exec sp_addsrvrolemember @username, 'processadmin';
		exec sp_addsrvrolemember @username, 'sysadmin';

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end

go
