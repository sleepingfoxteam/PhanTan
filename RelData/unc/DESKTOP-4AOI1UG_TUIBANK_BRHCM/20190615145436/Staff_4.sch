drop Table [dbo].[Staff]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[StaffID] [nvarchar](50) NOT NULL,
	[FullName] [nvarchar](200) NOT NULL,
	[Birthday] [date] NULL,
	[Address] [text] NULL,
	[PID] [nvarchar](50) NOT NULL,
	[PhoneNumber] [nvarchar](20) NULL,
	[Branch] [nvarchar](50) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [MSmerge_df_rowguid_A9EA1E75F4E84F5A90350F2DEF94A133]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

SET ANSI_PADDING ON

GO
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
