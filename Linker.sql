USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [Linker]    Script Date: 6/12/2019 1:45:55 AM ******/
CREATE LOGIN [Linker] WITH PASSWORD=N'i8Rj+RiHGhCXclh5tMb5mE11e4d4xGFP6cV1si/aKZs=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

ALTER LOGIN [Linker] DISABLE
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [Linker]
GO

ALTER SERVER ROLE [securityadmin] ADD MEMBER [Linker]
GO

ALTER SERVER ROLE [processadmin] ADD MEMBER [Linker]
GO

