drop Table [dbo].[Customer]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[CustomerID] [nvarchar](50) NOT NULL,
	[FullName] [nvarchar](200) NOT NULL,
	[Birthday] [date] NULL,
	[Address] [text] NULL,
	[PhoneNumber] [nvarchar](20) NULL,
	[Branch] [nvarchar](50) NULL,
	[PID] [nvarchar](50) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [MSmerge_df_rowguid_06A8F1A5F10F47ECBBE8999C24B30623]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

SET ANSI_PADDING ON

GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
