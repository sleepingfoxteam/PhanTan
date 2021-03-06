drop View [dbo].[View_Customer_Account]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE VIEW [dbo].[View_Customer_Account]
AS
SELECT        dbo.Customer.FullName AS customername, dbo.Account.AccountID AS accountnumber, dbo.Account.Balance AS accountbalance, dbo.Branch.BranchName AS branchname
FROM            dbo.Account INNER JOIN
                         dbo.Branch ON dbo.Account.Branch = dbo.Branch.BranchID INNER JOIN
                         dbo.Customer ON dbo.Account.Customer = dbo.Customer.CustomerID AND dbo.Branch.BranchID = dbo.Customer.Branch

go
