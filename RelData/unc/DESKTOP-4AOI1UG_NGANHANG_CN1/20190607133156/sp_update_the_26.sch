drop Procedure [dbo].[sp_update_the]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_update_the]
	@id nvarchar(50),
	@pass nvarchar(256)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.The where dbo.The.ID = @id;
	if @sum > 0
	begin
		update dbo.The set dbo.The.Password = @pass where dbo.The.ID = @id;
		return 1;
	end;
	else
	begin
		select @sum = Count(*) from LINK.NganHang.dbo.The t where t.ID = @id;
		if @sum > 0
		begin
			update t
			set t.Password = @pass
			from LINK.NganHang.dbo.The t
			where t.ID = @id;
		end;
		return -1;
	end;
end;
go
