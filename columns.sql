USE [NganHang]
GO
/****** Object:  Table [dbo].[ChiNhanh]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiNhanh](
	[ID] [nvarchar](50) NOT NULL,
	[TenCN] [nvarchar](100) NULL,
 CONSTRAINT [PK_ChiNhanh] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IB_TaiKhoan]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IB_TaiKhoan](
	[Username] [nvarchar](50) NOT NULL,
	[TaiKhoan] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_IB_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[Username] ASC,
	[TaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InternetBanking]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternetBanking](
	[Username] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](256) NULL,
	[KhachHang] [nvarchar](50) NULL,
 CONSTRAINT [PK_InternetBanking] PRIMARY KEY CLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[ID] [nvarchar](50) NOT NULL,
	[Hoten] [nvarchar](200) NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[DiaChi] [text] NULL,
	[Sdt] [nvarchar](20) NULL,
	[NgaySinh] [date] NULL,
 CONSTRAINT [PK_KhachHang] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[ID] [nvarchar](50) NOT NULL,
	[HoTen] [nvarchar](200) NOT NULL,
	[NgaySinh] [date] NULL,
	[LuongCB] [int] NOT NULL,
	[HeSo] [float] NOT NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[DiaChi] [text] NULL,
	[Sdt] [nvarchar](20) NULL,
 CONSTRAINT [PK_NhanVien] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[The]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[The](
	[ID] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](256) NULL,
	[KhachHang] [nvarchar](50) NULL,
 CONSTRAINT [PK_The] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[The_TaiKhoan]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[The_TaiKhoan](
	[The] [nvarchar](50) NOT NULL,
	[TaiKhoan] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_The_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[The] ASC,
	[TaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TKTK]    Script Date: 6/6/2019 7:51:31 PM ******/
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
 CONSTRAINT [PK_TKTK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TKTT]    Script Date: 6/6/2019 7:51:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TKTT](
	[ID] [nvarchar](50) NOT NULL,
	[KhachHang] [nvarchar](50) NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[SoDu] [int] NULL,
 CONSTRAINT [PK_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IB_TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_IB_TaiKhoan_InternetBanking] FOREIGN KEY([Username])
REFERENCES [dbo].[InternetBanking] ([Username])
GO
ALTER TABLE [dbo].[IB_TaiKhoan] CHECK CONSTRAINT [FK_IB_TaiKhoan_InternetBanking]
GO
ALTER TABLE [dbo].[IB_TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_IB_TaiKhoan_TKTT] FOREIGN KEY([TaiKhoan])
REFERENCES [dbo].[TKTT] ([ID])
GO
ALTER TABLE [dbo].[IB_TaiKhoan] CHECK CONSTRAINT [FK_IB_TaiKhoan_TKTT]
GO
ALTER TABLE [dbo].[InternetBanking]  WITH CHECK ADD  CONSTRAINT [FK_InternetBanking_KhachHang] FOREIGN KEY([KhachHang])
REFERENCES [dbo].[KhachHang] ([ID])
GO
ALTER TABLE [dbo].[InternetBanking] CHECK CONSTRAINT [FK_InternetBanking_KhachHang]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [FK_KhachHang_ChiNhanh] FOREIGN KEY([ChiNhanh])
REFERENCES [dbo].[ChiNhanh] ([ID])
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [FK_KhachHang_ChiNhanh]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_ChiNhanh] FOREIGN KEY([ChiNhanh])
REFERENCES [dbo].[ChiNhanh] ([ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [FK_NhanVien_ChiNhanh]
GO
ALTER TABLE [dbo].[The]  WITH CHECK ADD  CONSTRAINT [FK_The_KhachHang] FOREIGN KEY([KhachHang])
REFERENCES [dbo].[KhachHang] ([ID])
GO
ALTER TABLE [dbo].[The] CHECK CONSTRAINT [FK_The_KhachHang]
GO
ALTER TABLE [dbo].[The_TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_The_TaiKhoan_The] FOREIGN KEY([The])
REFERENCES [dbo].[The] ([ID])
GO
ALTER TABLE [dbo].[The_TaiKhoan] CHECK CONSTRAINT [FK_The_TaiKhoan_The]
GO
ALTER TABLE [dbo].[The_TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_The_TaiKhoan_TKTT] FOREIGN KEY([TaiKhoan])
REFERENCES [dbo].[TKTT] ([ID])
GO
ALTER TABLE [dbo].[The_TaiKhoan] CHECK CONSTRAINT [FK_The_TaiKhoan_TKTT]
GO
ALTER TABLE [dbo].[TKTK]  WITH CHECK ADD  CONSTRAINT [FK_TKTK_ChiNhanh] FOREIGN KEY([ChiNhanh])
REFERENCES [dbo].[ChiNhanh] ([ID])
GO
ALTER TABLE [dbo].[TKTK] CHECK CONSTRAINT [FK_TKTK_ChiNhanh]
GO
ALTER TABLE [dbo].[TKTK]  WITH CHECK ADD  CONSTRAINT [FK_TKTK_KhachHang] FOREIGN KEY([KhachHang])
REFERENCES [dbo].[KhachHang] ([ID])
GO
ALTER TABLE [dbo].[TKTK] CHECK CONSTRAINT [FK_TKTK_KhachHang]
GO
ALTER TABLE [dbo].[TKTK]  WITH CHECK ADD  CONSTRAINT [FK_TKTK_TKTT] FOREIGN KEY([TaiKhoanLienKet])
REFERENCES [dbo].[TKTT] ([ID])
GO
ALTER TABLE [dbo].[TKTK] CHECK CONSTRAINT [FK_TKTK_TKTT]
GO
ALTER TABLE [dbo].[TKTT]  WITH CHECK ADD  CONSTRAINT [FK_TaiKhoan_ChiNhanh] FOREIGN KEY([ChiNhanh])
REFERENCES [dbo].[ChiNhanh] ([ID])
GO
ALTER TABLE [dbo].[TKTT] CHECK CONSTRAINT [FK_TaiKhoan_ChiNhanh]
GO
ALTER TABLE [dbo].[TKTT]  WITH CHECK ADD  CONSTRAINT [FK_TaiKhoan_KhachHang] FOREIGN KEY([KhachHang])
REFERENCES [dbo].[KhachHang] ([ID])
GO
ALTER TABLE [dbo].[TKTT] CHECK CONSTRAINT [FK_TaiKhoan_KhachHang]
GO
