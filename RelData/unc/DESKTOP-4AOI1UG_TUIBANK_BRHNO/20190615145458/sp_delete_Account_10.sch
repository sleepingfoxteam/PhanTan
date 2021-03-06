drop Procedure [dbo].[sp_delete_Account]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_Account]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.Account where dbo.Account.AccountID = @id;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
