drop Procedure [dbo].[sp_insert_internet_banking]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_insert_internet_banking]
	@username nvarchar(50),
	@password nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	declare @check int;
	-- kiem tra trong server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check = 0
	begin
		-- kiem tra trong server khac --
		select @check = Count(*) from dbo.InternetBanking
			where dbo.InternetBanking.Username = @username;
		if @check = 0
		begin
			-- them vao csdl --
			insert into dbo.InternetBanking values (@username,@password,@khachhang,NEWID());
			-- tao login --
			exec sp_addlogin @username, @password;
			-- tao user --
			exec sp_adduser @username,@username;
			-- them member role --
			exec sp_addrolemember 'KhachHang',@username;
			-- them server member role --
			exec sp_addsrvrolemember @username, 'processadmin';
			exec sp_addsrvrolemember @username, 'sysadmin';
			return 1;
		end;
	end;
	return -1;
end;
go
