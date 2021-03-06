drop Procedure [dbo].[sp_update_Staff]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_Staff]
	@id nvarchar(50),
	@fullname nvarchar(200),
	@birthday date,
	@address text,
	@pid nvarchar(50),
	@phone nvarchar(20)
as
begin
	begin try
		update t
		set t.FullName = @fullname,
			t.Birthday = @birthday,
			t.Address = @address,
			t.PID = @pid,
			t.PhoneNumber = @phone
		from dbo.Staff t
		where t.StaffID = @id;

		return 1 ; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
