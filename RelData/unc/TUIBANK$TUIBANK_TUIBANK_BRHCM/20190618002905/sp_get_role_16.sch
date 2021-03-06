drop Procedure [dbo].[sp_get_role]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_get_role]
as
begin
	SELECT p.NAME as rolename

	FROM sys.database_role_members rm

	JOIN sys.database_principals p

	ON rm.role_principal_id = p.principal_id

	JOIN sys.database_principals m

	ON rm.member_principal_id = m.principal_id

end;
go
