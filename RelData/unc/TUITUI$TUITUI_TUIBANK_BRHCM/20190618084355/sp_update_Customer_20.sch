drop Procedure [dbo].[sp_update_Customer]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_Customer]
	@id nvarchar(50),
	@fullname nvarchar(200),
	@birthday date,
	@address text,
	@phone nvarchar(20)
as
begin
	begin try
		update	c
			set c.FullName = @fullname,
				c.Birthday = @birthday,
				c.Address = @address,
				c.PhoneNumber = @phone
		from dbo.Customer c
		where c.CustomerID = @id;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
