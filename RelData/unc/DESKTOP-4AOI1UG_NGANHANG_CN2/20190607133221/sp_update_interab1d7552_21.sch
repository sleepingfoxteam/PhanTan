drop Procedure [dbo].[sp_update_internet_banking]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_internet_banking]
	@username nvarchar(50),
	@password nvarchar(256)
as
begin
	declare @check int;
	-- check tai server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check> 0
	begin
		update dbo.InternetBanking
			set dbo.InternetBanking.Password = @password
			where dbo.InternetBanking.Username = @username;
		return 1;
	end;
	else
	begin
		-- kiem tra tai server khac --
		select @check = Count(*) from LINK.NganHang.dbo.InternetBanking as ib
			where ib.Username = @username;
		if @check > 0
		begin
			update ib
			set ib.Password = @password
			from LINK.NganHang.dbo.InternetBanking ib
			where ib.Username = @username;
		end;
		return -1;
	end;
end;
go
