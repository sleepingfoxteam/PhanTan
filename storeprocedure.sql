USE [NganHang]
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_ib_taikhoan]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_delete_ib_taikhoan]
	@username nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		delete from dbo.IB_TaiKhoan 
		where dbo.IB_TaiKhoan.Username = @username
			and dbo.IB_TaiKhoan.TaiKhoan = @taikhoan_id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_khachhang]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_khachhang]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.KhachHang where dbo.KhachHang.ID = @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_nhanvien]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_nhanvien]
	@id nvarchar(50)
as
begin
	begin try
		-- xoa trong csdl --
		delete from dbo.NhanVien where dbo.NhanVien.ID = @id;
		-- xoa login --
		exec sp_droplogin @id;
		-- xoa user trond database --
		exec sp_dropuser @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_the]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_the]
	@id nvarchar(50)
as
begin
	begin try
		delete from dbo.The where dbo.The.ID = @id;
		return -1;
	end try
	begin catch
		return 1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_the_taikhoan]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_delete_the_taikhoan]
	@the_id nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		-- them vao csdl --
		delete from dbo.The_TaiKhoan
			where dbo.The_TaiKhoan.The = @the_id
				and dbo.The_TaiKhoan.TaiKhoan = @taikhoan_id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_ib]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_ib]
	@username nvarchar(50),
	@pass nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	begin try
		-- insert into database --
		insert into dbo.InternetBanking values(@username,@pass,@khachhang);
		-- them login --
		exec sp_addlogin @username,@pass;
		-- them user --
		exec sp_adduser @username, @username;
		-- them rolemember --
		exec sp_addrolemember @username, 'KhachHang';
		-- them role server --
		exec sp_addsrvrolemember @username, 'processadmin';
		exec sp_addsrvrolemember @username, 'sysadmin';

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_ib_taikhoan]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_ib_taikhoan]
	@username nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	-- them vao csdl --
	begin try
		insert into dbo.IB_TaiKhoan values (@username,@taikhoan_id);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_khachhang]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_khachhang]
	@hoten nvarchar(200),
	@chinhanh nvarchar(50),
	@diachi text,
	@sdt nvarchar(20),
	@ngaysinh date
as
begin
	begin try
		declare @sumkhachhangchinhanh int, @id nvarchar(50);
		select @sumkhachhangchinhanh = Count(*) from dbo.KhachHang where dbo.KhachHang.ChiNhanh = @chinhanh;
		set @sumkhachhangchinhanh = @sumkhachhangchinhanh + 1;
		set @id = CONCAT('KH',@chinhanh,CAST(@sumkhachhangchinhanh as nvarchar(10)));
		-- them vao csdl --
		insert into dbo.KhachHang values(@id,@hoten,@chinhanh,@diachi,@sdt,@ngaysinh);

		return 1;
	end try
	begin catch
		return -1;
	end catch
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_nhanvien]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_nhanvien]
	@hoten nvarchar(200),
	@ngaysinh date,
	@luongcb int,
	@heso float,
	@chinhanh nvarchar(50),
	@diachi text,
	@sdt nvarchar(20)
as
begin
	declare @sumnhanvienchinhanh int, @id nvarchar(50);
	select @sumnhanvienchinhanh = Count(*) from dbo.NhanVien where dbo.NhanVien.ChiNhanh = @chinhanh;
	set @sumnhanvienchinhanh = @sumnhanvienchinhanh + 1;
	set @id = CONCAT('NV',@chinhanh,CAST(@sumnhanvienchinhanh as nvarchar(10)));
	begin try
		insert into dbo.NhanVien values(@id,@hoten,@ngaysinh,@luongcb,@heso,@chinhanh,@diachi,@sdt);
		-- them login --
		exec sp_addlogin @id,@id;
		-- them user --
		exec sp_adduser @id,@id;
		-- them rolemember --
		exec sp_addrolemember 'NhanVien', @id;
		-- gan server role --
		exec sp_addsrvrolemember @id, 'processadmin';
		exec sp_addsrvrolemember @id, 'sysadmin';
	end try
	begin catch
		print 'bi loi nang';
	end catch;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_the]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_the]
	@pass nvarchar(256),
	@khachhang nvarchar(50)
as
begin
	begin try
		declare @id nvarchar(50), @sumthekhachhang int;
		select @sumthekhachhang = count(*) from dbo.The where dbo.The.KhachHang = @khachhang;
		set @sumthekhachhang = @sumthekhachhang + 1;
		set @id = CONCAT('THE',@khachhang,CAST(@sumthekhachhang as nvarchar(10)));
		-- them the --
		insert into dbo.The values (@id,@pass,@khachhang);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_the_taikhoan]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_the_taikhoan]
	@the_id nvarchar(50),
	@taikhoan_id nvarchar(50)
as
begin
	begin try
		-- them vao csdl --
		insert into dbo.The_TaiKhoan values(@the_id,@taikhoan_id);
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_khachhang]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_khachhang]
	@id nvarchar(50),
	@hoten nvarchar(200),
	@ngaysinh date,
	@diachi text,
	@sdt nvarchar(20)
as 
begin
	begin try
		update dbo.KhachHang
		set dbo.KhachHang.DiaChi = @diachi,
			dbo.KhachHang.Hoten = @hoten,
			dbo.KhachHang.Sdt = @sdt,
			dbo.KhachHang.NgaySinh = @ngaysinh
		where dbo.KhachHang.ID = @id;

		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_nhanvien_nhanvien]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_nhanvien_nhanvien]
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
/****** Object:  StoredProcedure [dbo].[sp_update_nhanvien_qlcn]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_nhanvien_qlcn]
	@id nvarchar(50),
	@heso float,
	@luongcb int
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
/****** Object:  StoredProcedure [dbo].[sp_update_pass_ib]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_pass_ib]
	@username nvarchar(50),
	@pass_new nvarchar(256)
as
begin
	begin try
		update dbo.InternetBanking
			set dbo.InternetBanking.Password = @pass_new
			where dbo.InternetBanking.Username = @username;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
/****** Object:  StoredProcedure [dbo].[sp_update_pass_the]    Script Date: 6/6/2019 7:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_update_pass_the]
	@id nvarchar(50),
	@pass_new nvarchar(256)
as
begin
	begin try
		update dbo.The
			set dbo.The.Password = @pass_new
			where dbo.The.ID = @id;
		return 1;
	end try
	begin catch
		return -1;
	end catch;
end
GO
