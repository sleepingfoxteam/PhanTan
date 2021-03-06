drop Procedure [dbo].[sp_get_role]
go

SET QUOTED_IDENTIFIER ON
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[sp_get_role]
	@username nvarchar(50)
as
begin
	select p.name as rolename
	from sys.database_role_members r,
		sys.database_principals p,
		sys.database_principals pp
	where r.role_principal_id = p.principal_id
		and r.member_principal_id = pp.principal_id
		and pp.name = @username;
end;
go
