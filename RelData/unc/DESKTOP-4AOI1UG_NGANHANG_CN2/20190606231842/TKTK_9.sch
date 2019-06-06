drop Table [dbo].[TKTK]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TKTK](
	[ID] [nvarchar](50) NOT NULL,
	[KhachHang] [nvarchar](50) NULL,
	[SoDu] [int] NULL,
	[KyHan] [int] NULL,
	[LaiSuat] [float] NULL,
	[NgayBatDau] [date] NULL,
	[NgayHetHan] [date] NULL,
	[TaiKhoanLienKet] [nvarchar](50) NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[TKTK] ADD  CONSTRAINT [MSmerge_df_rowguid_E57705C428684E6BB0C9BFAAB4F7706E]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

SET ANSI_PADDING ON

GO
ALTER TABLE [dbo].[TKTK] ADD  CONSTRAINT [PK_TKTK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
