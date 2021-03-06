drop Procedure [dbo].[sp_add_Staff_manager]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_add_Staff_manager]
	@fullname nvarchar(200),
	@birthday date,
	@address text,
	@pid nvarchar(50),
	@phone nvarchar(20),
	@branch nvarchar(50)
as
begin
	declare @id nvarchar(50), @sum int;
	select @sum = Count(*) from dbo.Staff s where s.Branch = @branch;
	set @sum = @sum + 1;
	set @id = CONCAT('ST',@branch,CAST(@sum as nvarchar(10)));
	begin try
		-- insert into database --
		insert into dbo.Staff values(@id,@fullname,@birthday,@address,@pid,@phone,@branch,NEWID());
		-- create login --
		exec sp_addlogin @id,@id;
		-- create user --
		exec sp_adduser @id;
		-- add to role --
		exec sp_addrolemember 'Manager',@id;

		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
