drop Procedure [dbo].[sp_find_account_info]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
create procedure [dbo].[sp_find_account_info]
	@accountnumber nvarchar(50)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.Account where dbo.Account.AccountID = @accountnumber;
	if @sum > 0
	begin
		select cus.FullName as customername, acc.AccountID as accountnumber, acc.Balance accountbalance, bra.BranchName as branchname
		from dbo.Account acc, dbo.Customer cus, dbo.Branch bra
		where acc.AccountID = @accountnumber
			and acc.Customer = cus.CustomerID
			and acc.Branch = bra.BranchID
			and acc.AccountID = @accountnumber;
	end;
	else
	begin
		select @sum = Count(*) from LINK.TUIBANK.dbo.Account acc where acc.AccountID = @accountnumber;
		if @sum > 0
		begin
			select cus.FullName as customername, acc.AccountID as accountnumber, acc.Balance accountbalance, bra.BranchName as branchname
			from LINK.TUIBANK.dbo.Account acc,
				LINK.TUIBANK.dbo.Customer cus,
				LINK.TUIBANK.dbo.Branch bra
			where acc.Customer = cus.CustomerID
				and acc.Branch = bra.BranchID
				and acc.AccountID = @accountnumber;
		end;
		return -1;
	end;
end;
go
