drop Procedure [dbo].[sp_add_Account]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_add_Account]
	@customer nvarchar(50),
	@startdate date,
	@enddate date,
	@interest float,
	@period int,
	@balance int,
	@branch nvarchar(50)
as
begin
	begin try
		declare @id nvarchar(50), @sum_this int, @sum_that int, @sum_all int, @today nvarchar(10);
		-- total account of this user in this server --
		select @sum_this = Count(*) from dbo.Account a where a.StartDate = CAST(GETDATE() as date);
		select @sum_that = Count(*) from LINK.TUIBANK.dbo.Account a where a.StartDate = CAST(GETDATE() as date);
		set @sum_all = @sum_that + @sum_this;
		set @sum_all = @sum_all + 1;
		set @today = REPLACE(CONVERT(nvarchar(10),GETDATE(),110),'-','');
		if @interest > 0
		begin
			set @id = CONCAT('60350',@today,CAST(@sum_all as nvarchar(10)));
			insert into dbo.Account values (@id,@customer,@startdate,@enddate,@interest,@period,@balance,@branch,NEWID());
		end;
		else
		begin
			set @id = CONCAT('60990',@today,CAST(@sum_all as nvarchar(10)));
			insert into dbo.Account values (@id,@customer,@startdate,@enddate,@interest,@period,@balance,@branch,NEWID());
		end;
		return 1; -- success --
	end try
	begin catch
		return -1; -- fail --
	end catch;
end;
go
