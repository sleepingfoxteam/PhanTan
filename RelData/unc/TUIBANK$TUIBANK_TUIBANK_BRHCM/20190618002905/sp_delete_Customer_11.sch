drop Procedure [dbo].[sp_delete_Customer]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_Customer]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.Customer where dbo.Customer.CustomerID = @id;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
