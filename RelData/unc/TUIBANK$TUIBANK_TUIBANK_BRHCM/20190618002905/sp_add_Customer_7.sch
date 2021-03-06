drop Procedure [dbo].[sp_add_Customer]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_add_Customer]
	@fullnane nvarchar(200),
	@birthday date,
	@address text,
	@phone nvarchar(20),
	@branch nvarchar(50),
	@pid nvarchar(50)
as
begin
	begin try
		declare @id nvarchar(50), @sum int;
		select @sum = Count(*) from dbo.Customer where dbo.Customer.Branch = @branch;
		set @sum = @sum + 1;
		set @id = CONCAT('CU',@branch,CAST(@sum as nvarchar(10)));
		-- insert into database --
		insert into dbo.Customer values (@id,@fullnane,@birthday,@address,@phone,@branch,@pid,NEWID());
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;

go
