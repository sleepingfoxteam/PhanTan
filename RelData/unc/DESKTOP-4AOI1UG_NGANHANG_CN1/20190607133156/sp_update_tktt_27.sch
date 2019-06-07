drop Procedure [dbo].[sp_update_tktt]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_update_tktt]
	@id nvarchar(50),
	@sodu int
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.TKTT where dbo.TKTT.ID = @id;
	if @sum > 0
	begin
		begin try
			update dbo.TKTT
			set dbo.TKTT.SoDu = @sodu
			where dbo.TKTT.ID = @id;
			return 1;
		end try
		begin catch
			return -1;
		end catch;
	end;
	else
	begin
		select @sum = Count(*) from LINK.NganHang.dbo.TKTT tt where tt.ID = @id;
		if @sum > 0
		begin
			begin try
				update tt
				set tt.SoDu = @sodu
				from LINK.NganHang.dbo.TKTT tt
				where tt.ID = @id;
				return 1;
			end try
			begin catch
				return -1;
			end catch;
		end;
		else
		begin
			return -1;
		end;
	end;
end;
go
