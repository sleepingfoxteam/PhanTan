USE [master]
GO
/****** Object:  Database [NganHang]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE DATABASE [NganHang]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NganHang', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\DATA\NganHang.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'NganHang_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\DATA\NganHang_log.ldf' , SIZE = 270336KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [NganHang] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NganHang].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [NganHang] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [NganHang] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [NganHang] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [NganHang] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [NganHang] SET ARITHABORT OFF 
GO
ALTER DATABASE [NganHang] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [NganHang] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [NganHang] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [NganHang] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [NganHang] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [NganHang] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [NganHang] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [NganHang] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [NganHang] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [NganHang] SET  DISABLE_BROKER 
GO
ALTER DATABASE [NganHang] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [NganHang] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [NganHang] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [NganHang] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [NganHang] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [NganHang] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [NganHang] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [NganHang] SET RECOVERY FULL 
GO
ALTER DATABASE [NganHang] SET  MULTI_USER 
GO
ALTER DATABASE [NganHang] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [NganHang] SET DB_CHAINING OFF 
GO
ALTER DATABASE [NganHang] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [NganHang] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [NganHang] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'NganHang', N'ON'
GO
ALTER DATABASE [NganHang] SET QUERY_STORE = OFF
GO
USE [NganHang]
GO
/****** Object:  User [HTKN]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE USER [HTKN] FOR LOGIN [HTKN] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [QLCN]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [QLCN]
GO
/****** Object:  DatabaseRole [NhanVien]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [NhanVien]
GO
/****** Object:  DatabaseRole [MSmerge_PAL_role]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [MSmerge_PAL_role]
GO
/****** Object:  DatabaseRole [MSmerge_E6DB178D8974477E9E4F4045F6F9CA48]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [MSmerge_E6DB178D8974477E9E4F4045F6F9CA48]
GO
/****** Object:  DatabaseRole [MSmerge_A90174F050504370BE4EEA4ED383EA24]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [MSmerge_A90174F050504370BE4EEA4ED383EA24]
GO
/****** Object:  DatabaseRole [KhachHang]    Script Date: 6/7/2019 2:52:30 PM ******/
CREATE ROLE [KhachHang]
GO
ALTER ROLE [db_owner] ADD MEMBER [HTKN]
GO
ALTER ROLE [MSmerge_PAL_role] ADD MEMBER [MSmerge_E6DB178D8974477E9E4F4045F6F9CA48]
GO
ALTER ROLE [MSmerge_PAL_role] ADD MEMBER [MSmerge_A90174F050504370BE4EEA4ED383EA24]
GO
/****** Object:  Schema [MSmerge_PAL_role]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE SCHEMA [MSmerge_PAL_role]
GO
/****** Object:  Table [dbo].[ChiNhanh]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiNhanh](
	[ID] [nvarchar](50) NOT NULL,
	[TenCN] [nvarchar](100) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_ChiNhanh] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IB_TaiKhoan]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IB_TaiKhoan](
	[Username] [nvarchar](50) NOT NULL,
	[TaiKhoan] [nvarchar](50) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_IB_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[Username] ASC,
	[TaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InternetBanking]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternetBanking](
	[Username] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](256) NULL,
	[KhachHang] [nvarchar](50) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_InternetBanking] PRIMARY KEY CLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[ID] [nvarchar](50) NOT NULL,
	[Hoten] [nvarchar](200) NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[NgaySinh] [date] NULL,
	[DiaChi] [text] NULL,
	[Sdt] [nvarchar](20) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_KhachHang] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 6/7/2019 2:52:31 PM ******/
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
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_NhanVien] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[The]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[The](
	[ID] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](256) NULL,
	[KhachHang] [nvarchar](50) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_The] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[The_TaiKhoan]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[The_TaiKhoan](
	[The] [nvarchar](50) NOT NULL,
	[TaiKhoan] [nvarchar](50) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_The_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[The] ASC,
	[TaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TKTK]    Script Date: 6/7/2019 2:52:31 PM ******/
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
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_TKTK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TKTT]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TKTT](
	[ID] [nvarchar](50) NOT NULL,
	[KhachHang] [nvarchar](50) NULL,
	[ChiNhanh] [nvarchar](50) NULL,
	[SoDu] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_933578364]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_933578364] ON [dbo].[ChiNhanh]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1413580074]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1413580074] ON [dbo].[IB_TaiKhoan]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1253579504]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1253579504] ON [dbo].[InternetBanking]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1013578649]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1013578649] ON [dbo].[KhachHang]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_965578478]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_965578478] ON [dbo].[NhanVien]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1301579675]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1301579675] ON [dbo].[The]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1349579846]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1349579846] ON [dbo].[The_TaiKhoan]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1141579105]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1141579105] ON [dbo].[TKTK]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSmerge_index_1077578877]    Script Date: 6/7/2019 2:52:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1077578877] ON [dbo].[TKTT]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChiNhanh] ADD  CONSTRAINT [MSmerge_df_rowguid_B6584694E4094A099AE62BB8040D68C1]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[IB_TaiKhoan] ADD  CONSTRAINT [MSmerge_df_rowguid_FB0AEBDE8E924B658683B5C1DE058465]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[InternetBanking] ADD  CONSTRAINT [MSmerge_df_rowguid_0B0C1D5005294ACB8961DBADDFA2A2D3]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[KhachHang] ADD  CONSTRAINT [MSmerge_df_rowguid_BFF8065F494A4D7AA878FE9FD5B46DB4]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[NhanVien] ADD  CONSTRAINT [MSmerge_df_rowguid_53EC60A31E7741BBB7922D6D843725ED]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[The] ADD  CONSTRAINT [MSmerge_df_rowguid_B644466F5A96463C8878D4C578DEE2E9]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[The_TaiKhoan] ADD  CONSTRAINT [MSmerge_df_rowguid_A775C900BFE442A08712D1A87E2885E4]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[TKTK] ADD  CONSTRAINT [MSmerge_df_rowguid_B44840F04115419AB0794E3E1F26376D]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[TKTT] ADD  CONSTRAINT [MSmerge_df_rowguid_6CF3784D09384826BC2005B03D8DE589]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[IB_TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_IB_TaiKhoan_InternetBanking] FOREIGN KEY([Username])
REFERENCES [dbo].[InternetBanking] ([Username])
ON UPDATE CASCADE
ON DELETE CASCADE
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
ON UPDATE CASCADE
ON DELETE CASCADE
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
ON UPDATE CASCADE
ON DELETE CASCADE
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
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TKTT] CHECK CONSTRAINT [FK_TaiKhoan_KhachHang]
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_internet_banking]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_internet_banking]
	@username nvarchar(50)
as
begin
	declare @check int;
	-- check tai server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check> 0
	begin
		begin try
			-- xoa khoi csdl --
			delete from dbo.InternetBanking where dbo.InternetBanking.Username = @username;
			-- drop login --
			exec sp_droplogin @username;
			-- drop user --
			exec sp_dropuser @username;
			return 1;
		end try
		begin catch
			return -1;
		end catch;
	end;
	return -1;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_khachhang]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_delete_khachhang]
	@id nvarchar(50)
as
begin
	declare @username nvarchar(50), @sum int;
	select @sum = Count(*) from dbo.KhachHang where dbo.KhachHang.ID = @id;
	if @sum > 0
	begin
		-- lay Username cua Khach Hang (neu co) --
		select @username = ib.Username
		from dbo.InternetBanking ib
		where ib.KhachHang = @id;
		-- xoa trong csdl -- --> tu xoa trong InternetBanking do FK
		delete from dbo.KhachHang where dbo.KhachHang.ID = @id;
		if @username is not NULL
		begin
			return exec sp_delete_internet_banking @username;
		end;
	end;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_nhanvien]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_nhanvien]
	@id nvarchar(50)
as
begin
	begin try
		-- xoa khoi csdl --
		delete from dbo.NhanVien where dbo.NhanVien.ID = @id;
		-- xoa login --
		exec sp_droplogin @id;
		-- xoa user --
		exec sp_dropuser @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_the]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_delete_the]
	@id nvarchar(50)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.The where dbo.The.ID = @id;
	if @sum > 0
	begin
		delete from dbo.The where dbo.The.ID = @id;
	end;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_internet_banking]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_internet_banking]
	@username nvarchar(50),
	@password nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	declare @check int;
	-- kiem tra trong server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check = 0
	begin
		-- kiem tra trong server khac --
		select @check = Count(*) from dbo.InternetBanking
			where dbo.InternetBanking.Username = @username;
		if @check = 0
		begin
			-- them vao csdl --
			insert into dbo.InternetBanking values (@username,@password,@khachhang,NEWID());
			-- tao login --
			exec sp_addlogin @username, @password;
			-- tao user --
			exec sp_adduser @username,@username;
			-- them member role --
			exec sp_addrolemember 'KhachHang',@username;
			-- them server member role --
			exec sp_addsrvrolemember @username, 'processadmin';
			exec sp_addsrvrolemember @username, 'sysadmin';
			return 1;
		end;
	end;
	return -1;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_khachhang]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_khachhang]
	@hoten nvarchar(200),
	@chinhanh nvarchar(50),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as
begin
	declare @id nvarchar(50), @sumkhachhang int;
	select @sumkhachhang = Count(*) from dbo.KhachHang where dbo.KhachHang.ChiNhanh = @chinhanh;
	set @sumkhachhang = @sumkhachhang + 1;
	set @id = CONCAT('KH',@chinhanh,CAST(@sumkhachhang as nvarchar(10)));
	-- them vao csdl --
	begin try
		insert into dbo.KhachHang values (@id,@hoten,@chinhanh,@ngaysinh,@diachi,@sdt,NEWID());
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_nhanvien]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_nhanvien]
	@hoten nvarchar(200),
	@ngaysinh date,
	@luongcb int,
	@heso float,
	@diachi text,
	@sdt nvarchar(20),
	@chinhanh nvarchar(50)
as
begin
	declare @id nvarchar(50), @sumnhanvienchinhanh int;
	select @sumnhanvienchinhanh = Count(*) from dbo.NhanVien where dbo.NhanVien.ChiNhanh = @chinhanh;
	set @sumnhanvienchinhanh = @sumnhanvienchinhanh + 1;
	begin try
		set @id = CONCAT('NV',@chinhanh,CAST(@sumnhanvienchinhanh as nvarchar(10)));
		-- them vao csdl --
		insert into dbo.NhanVien values (@id,@hoten,@ngaysinh,@luongcb,@heso,@chinhanh,@diachi,@sdt,NEWID());
		-- tao login --
		exec sp_addlogin @id,@id;
		-- them vao role --
		exec sp_adduser @id,@id;
		exec sp_addrolemember 'NhanVien',@id;
		-- them server role member --
		exec sp_addsrvrolemember @id, 'processadmin';
		exec sp_addsrvrolemember @id, 'sysadmin';

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_the]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_the]
	@khachhang nvarchar(50)
as
begin
	declare @id nvarchar(50), @sumthe int;
	select @sumthe = Count(*) from dbo.The where dbo.The.KhachHang = @khachhang;
	set @sumthe = @sumthe + 1;
	set @id = CONCAT('THE',@khachhang,CAST(@sumthe as nvarchar(10)));
	-- them vao csdl --
	begin try
		insert into dbo.The values (@id,@khachhang,@khachhang,NEWID());
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_tktk]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_tktk]
	@khachhang nvarchar(50),
	@sodu int,
	@kyhan int,
	@laisuat float,
	@ngaybatdau date,
	@ngayhethan date,
	@taikhoanlienket nvarchar(50),
	@chinhanh nvarchar(50)
as
begin
	declare @id nvarchar(50), @sum int;
	select @sum = Count(*) from dbo.TKTK where dbo.TKTK.KhachHang = @khachhang;
	begin try
		set @sum = @sum + 1;
		set @id = CONCAT('9980',@khachhang,CAST(@sum as nvarchar(10)));
		insert dbo.TKTK values (@id,@khachhang,@sodu,@kyhan,@laisuat,@ngaybatdau,@ngayhethan,@taikhoanlienket,@chinhanh,NEWID());
		return 1;
	end try
	begin catch
		return -1;
	end catch;

end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_tktt]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_tktt]
	@khachhang nvarchar(50),
	@chinhanh nvarchar(50),
	@sodu int
as
begin
	declare @id nvarchar(50), @sumtktt_this int, @sumtktt_server int;
	select @sumtktt_this = Count(*) from dbo.TKTT where dbo.TKTT.KhachHang = @khachhang;
	select @sumtktt_server = Count(*) from LINK.NganHang.dbo.TKTT tktt where tktt.KhachHang = @khachhang;
	set @sumtktt_this = @sumtktt_this + @sumtktt_server + 1;
	set @id = CONCAT('9800',@khachhang,CAST(@sumtktt_this as nvarchar(10)));
	-- them vao csdl --
	insert into dbo.TKTT values (@id,@khachhang,@chinhanh,@sodu,NEWID());
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_select_nhanvien]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_select_nhanvien]
	@hoten nvarchar(200),
	@sdt nvarchar(20),
	@luongcb int,
	@heso float
as
begin
	declare @select int;
	select @select = Count(*) from dbo.NhanVien
		where dbo.NhanVien.HoTen = @hoten
			or dbo.NhanVien.Sdt = @sdt
			or dbo.NhanVien.LuongCB = @luongcb
			or dbo.NhanVien.HeSo = @heso;
	if @select = 0
	begin
		select * from LINK.NganHang.dbo.NhanVien as nv
				where nv.HoTen = @hoten
					or nv.Sdt = @sdt
					or nv.LuongCB = @luongcb
					or nv.HeSo = @heso;
	end
	else
	begin
		select * from dbo.NhanVien
				where dbo.NhanVien.HoTen = @hoten
					or dbo.NhanVien.Sdt = @sdt
					or dbo.NhanVien.LuongCB = @luongcb
					or dbo.NhanVien.HeSo = @heso;
	end
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_update_internet_banking]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_update_internet_banking]
	@username nvarchar(50),
	@password nvarchar(256)
as
begin
	declare @check int;
	-- check tai server hien tai --
	select @check = Count(*) from dbo.InternetBanking
		where dbo.InternetBanking.Username = @username;
	if @check> 0
	begin
		update dbo.InternetBanking
			set dbo.InternetBanking.Password = @password
			where dbo.InternetBanking.Username = @username;
		return 1;
	end;
	else
	begin
		-- kiem tra tai server khac --
		select @check = Count(*) from LINK.NganHang.dbo.InternetBanking as ib
			where ib.Username = @username;
		if @check > 0
		begin
			update ib
			set ib.Password = @password
			from LINK.NganHang.dbo.InternetBanking ib
			where ib.Username = @username;
		end;
		return -1;
	end;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_update_khachhang]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_update_khachhang]
	@id nvarchar(50),
	@hoten nvarchar(200),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as
begin
	begin try
		update dbo.KhachHang
			set dbo.KhachHang.Hoten = @hoten,
				dbo.KhachHang.NgaySinh = @ngaysinh,
				dbo.KhachHang.DiaChi = @diachi,
				dbo.KhachHang.Sdt = @sdt
			where dbo.KhachHang.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_nhanvien_nhanvien]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_update_nhanvien_nhanvien]
	@id nvarchar(50),
	@hoten nvarchar(200),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as
begin
	begin try
		update dbo.NhanVien
			set dbo.NhanVien.HoTen = @hoten,
				dbo.NhanVien.NgaySinh = @ngaysinh,
				dbo.NhanVien.DiaChi = @diachi,
				dbo.NhanVien.Sdt = @sdt
			where dbo.NhanVien.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_nhanvien_quanly]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_update_nhanvien_quanly]
	@id nvarchar(50),
	@luongcb int,
	@heso float
as
begin
	begin try
		update dbo.NhanVien
			set dbo.NhanVien.HeSo = @heso,
				dbo.NhanVien.LuongCB = @luongcb
			where dbo.NhanVien.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_the]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_update_the]
	@id nvarchar(50),
	@pass nvarchar(256)
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.The where dbo.The.ID = @id;
	if @sum > 0
	begin
		update dbo.The set dbo.The.Password = @pass where dbo.The.ID = @id;
		return 1;
	end;
	else
	begin
		select @sum = Count(*) from LINK.NganHang.dbo.The t where t.ID = @id;
		if @sum > 0
		begin
			update t
			set t.Password = @pass
			from LINK.NganHang.dbo.The t
			where t.ID = @id;
		end;
		return -1;
	end;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_update_tktt]    Script Date: 6/7/2019 2:52:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_tktt]
	@id nvarchar(50),
	@sodu int
as
begin
	declare @sum int;
	select @sum = Count(*) from dbo.TKTT where dbo.TKTT.ID = @id;
	if @sum > 0
	begin
		begin try
			update dbo.TKTT
			set dbo.TKTT.SoDu = @sodu
			where dbo.TKTT.ID = @id;
			return 1;
		end try
		begin catch
			return -1;
		end catch;
	end;
	else
	begin
		select @sum = Count(*) from LINK.NganHang.dbo.TKTT tt where tt.ID = @id;
		if @sum > 0
		begin
			begin try
				update tt
				set tt.SoDu = @sodu
				from LINK.NganHang.dbo.TKTT tt
				where tt.ID = @id;
				return 1;
			end try
			begin catch
				return -1;
			end catch;
		end;
		else
		begin
			return -1;
		end;
	end;
end;
GO
USE [master]
GO
ALTER DATABASE [NganHang] SET  READ_WRITE 
GO
