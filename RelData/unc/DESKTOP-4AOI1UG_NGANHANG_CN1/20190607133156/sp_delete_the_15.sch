drop Procedure [dbo].[sp_delete_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_delete_the]
	@id nvarchar(50)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.The where dbo.The.ID = @id;
	if @sum > 0
	begin
		delete from dbo.The where dbo.The.ID = @id;
	end;
end;
go
