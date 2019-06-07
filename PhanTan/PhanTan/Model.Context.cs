﻿//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PhanTan
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Objects;
    using System.Data.Objects.DataClasses;
    using System.Linq;
    
    public partial class NganHangEntities : DbContext
    {
        public NganHangEntities()
            : base("name=NganHangEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public DbSet<ChiNhanh> ChiNhanhs { get; set; }
        public DbSet<IB_TaiKhoan> IB_TaiKhoan { get; set; }
        public DbSet<InternetBanking> InternetBankings { get; set; }
        public DbSet<KhachHang> KhachHangs { get; set; }
        public DbSet<NhanVien> NhanViens { get; set; }
        public DbSet<The> Thes { get; set; }
        public DbSet<The_TaiKhoan> The_TaiKhoan { get; set; }
        public DbSet<TKTK> TKTKs { get; set; }
        public DbSet<TKTT> TKTTs { get; set; }
    
        public virtual int sp_delete_internet_banking(string username)
        {
            var usernameParameter = username != null ?
                new ObjectParameter("username", username) :
                new ObjectParameter("username", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_delete_internet_banking", usernameParameter);
        }
    
        public virtual int sp_delete_khachhang(string id)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_delete_khachhang", idParameter);
        }
    
        public virtual int sp_delete_nhanvien(string id)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_delete_nhanvien", idParameter);
        }
    
        public virtual int sp_delete_the(string id)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_delete_the", idParameter);
        }
    
        public virtual int sp_insert_internet_banking(string username, string password, string khachhang)
        {
            var usernameParameter = username != null ?
                new ObjectParameter("username", username) :
                new ObjectParameter("username", typeof(string));
    
            var passwordParameter = password != null ?
                new ObjectParameter("password", password) :
                new ObjectParameter("password", typeof(string));
    
            var khachhangParameter = khachhang != null ?
                new ObjectParameter("khachhang", khachhang) :
                new ObjectParameter("khachhang", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_internet_banking", usernameParameter, passwordParameter, khachhangParameter);
        }
    
        public virtual int sp_insert_khachhang(string hoten, string chinhanh, Nullable<System.DateTime> ngaysinh, string diachi, string sdt)
        {
            var hotenParameter = hoten != null ?
                new ObjectParameter("hoten", hoten) :
                new ObjectParameter("hoten", typeof(string));
    
            var chinhanhParameter = chinhanh != null ?
                new ObjectParameter("chinhanh", chinhanh) :
                new ObjectParameter("chinhanh", typeof(string));
    
            var ngaysinhParameter = ngaysinh.HasValue ?
                new ObjectParameter("ngaysinh", ngaysinh) :
                new ObjectParameter("ngaysinh", typeof(System.DateTime));
    
            var diachiParameter = diachi != null ?
                new ObjectParameter("diachi", diachi) :
                new ObjectParameter("diachi", typeof(string));
    
            var sdtParameter = sdt != null ?
                new ObjectParameter("sdt", sdt) :
                new ObjectParameter("sdt", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_khachhang", hotenParameter, chinhanhParameter, ngaysinhParameter, diachiParameter, sdtParameter);
        }
    
        public virtual int sp_insert_nhanvien(string hoten, Nullable<System.DateTime> ngaysinh, Nullable<int> luongcb, Nullable<double> heso, string diachi, string sdt, string chinhanh)
        {
            var hotenParameter = hoten != null ?
                new ObjectParameter("hoten", hoten) :
                new ObjectParameter("hoten", typeof(string));
    
            var ngaysinhParameter = ngaysinh.HasValue ?
                new ObjectParameter("ngaysinh", ngaysinh) :
                new ObjectParameter("ngaysinh", typeof(System.DateTime));
    
            var luongcbParameter = luongcb.HasValue ?
                new ObjectParameter("luongcb", luongcb) :
                new ObjectParameter("luongcb", typeof(int));
    
            var hesoParameter = heso.HasValue ?
                new ObjectParameter("heso", heso) :
                new ObjectParameter("heso", typeof(double));
    
            var diachiParameter = diachi != null ?
                new ObjectParameter("diachi", diachi) :
                new ObjectParameter("diachi", typeof(string));
    
            var sdtParameter = sdt != null ?
                new ObjectParameter("sdt", sdt) :
                new ObjectParameter("sdt", typeof(string));
    
            var chinhanhParameter = chinhanh != null ?
                new ObjectParameter("chinhanh", chinhanh) :
                new ObjectParameter("chinhanh", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_nhanvien", hotenParameter, ngaysinhParameter, luongcbParameter, hesoParameter, diachiParameter, sdtParameter, chinhanhParameter);
        }
    
        public virtual int sp_insert_the(string khachhang)
        {
            var khachhangParameter = khachhang != null ?
                new ObjectParameter("khachhang", khachhang) :
                new ObjectParameter("khachhang", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_the", khachhangParameter);
        }
    
        public virtual int sp_insert_tktk(string khachhang, Nullable<int> sodu, Nullable<int> kyhan, Nullable<double> laisuat, Nullable<System.DateTime> ngaybatdau, Nullable<System.DateTime> ngayhethan, string taikhoanlienket, string chinhanh)
        {
            var khachhangParameter = khachhang != null ?
                new ObjectParameter("khachhang", khachhang) :
                new ObjectParameter("khachhang", typeof(string));
    
            var soduParameter = sodu.HasValue ?
                new ObjectParameter("sodu", sodu) :
                new ObjectParameter("sodu", typeof(int));
    
            var kyhanParameter = kyhan.HasValue ?
                new ObjectParameter("kyhan", kyhan) :
                new ObjectParameter("kyhan", typeof(int));
    
            var laisuatParameter = laisuat.HasValue ?
                new ObjectParameter("laisuat", laisuat) :
                new ObjectParameter("laisuat", typeof(double));
    
            var ngaybatdauParameter = ngaybatdau.HasValue ?
                new ObjectParameter("ngaybatdau", ngaybatdau) :
                new ObjectParameter("ngaybatdau", typeof(System.DateTime));
    
            var ngayhethanParameter = ngayhethan.HasValue ?
                new ObjectParameter("ngayhethan", ngayhethan) :
                new ObjectParameter("ngayhethan", typeof(System.DateTime));
    
            var taikhoanlienketParameter = taikhoanlienket != null ?
                new ObjectParameter("taikhoanlienket", taikhoanlienket) :
                new ObjectParameter("taikhoanlienket", typeof(string));
    
            var chinhanhParameter = chinhanh != null ?
                new ObjectParameter("chinhanh", chinhanh) :
                new ObjectParameter("chinhanh", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_tktk", khachhangParameter, soduParameter, kyhanParameter, laisuatParameter, ngaybatdauParameter, ngayhethanParameter, taikhoanlienketParameter, chinhanhParameter);
        }
    
        public virtual int sp_insert_tktt(string khachhang, string chinhanh, Nullable<int> sodu)
        {
            var khachhangParameter = khachhang != null ?
                new ObjectParameter("khachhang", khachhang) :
                new ObjectParameter("khachhang", typeof(string));
    
            var chinhanhParameter = chinhanh != null ?
                new ObjectParameter("chinhanh", chinhanh) :
                new ObjectParameter("chinhanh", typeof(string));
    
            var soduParameter = sodu.HasValue ?
                new ObjectParameter("sodu", sodu) :
                new ObjectParameter("sodu", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_insert_tktt", khachhangParameter, chinhanhParameter, soduParameter);
        }
    
        public virtual int sp_renamediagram(string diagramname, Nullable<int> owner_id, string new_diagramname)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            var new_diagramnameParameter = new_diagramname != null ?
                new ObjectParameter("new_diagramname", new_diagramname) :
                new ObjectParameter("new_diagramname", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_renamediagram", diagramnameParameter, owner_idParameter, new_diagramnameParameter);
        }
    
        public virtual ObjectResult<sp_select_nhanvien_Result> sp_select_nhanvien(string hoten, string sdt, Nullable<int> luongcb, Nullable<double> heso)
        {
            var hotenParameter = hoten != null ?
                new ObjectParameter("hoten", hoten) :
                new ObjectParameter("hoten", typeof(string));
    
            var sdtParameter = sdt != null ?
                new ObjectParameter("sdt", sdt) :
                new ObjectParameter("sdt", typeof(string));
    
            var luongcbParameter = luongcb.HasValue ?
                new ObjectParameter("luongcb", luongcb) :
                new ObjectParameter("luongcb", typeof(int));
    
            var hesoParameter = heso.HasValue ?
                new ObjectParameter("heso", heso) :
                new ObjectParameter("heso", typeof(double));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<sp_select_nhanvien_Result>("sp_select_nhanvien", hotenParameter, sdtParameter, luongcbParameter, hesoParameter);
        }
    
        public virtual int sp_update_internet_banking(string username, string password)
        {
            var usernameParameter = username != null ?
                new ObjectParameter("username", username) :
                new ObjectParameter("username", typeof(string));
    
            var passwordParameter = password != null ?
                new ObjectParameter("password", password) :
                new ObjectParameter("password", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_internet_banking", usernameParameter, passwordParameter);
        }
    
        public virtual int sp_update_khachhang(string id, string hoten, Nullable<System.DateTime> ngaysinh, string diachi, string sdt)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            var hotenParameter = hoten != null ?
                new ObjectParameter("hoten", hoten) :
                new ObjectParameter("hoten", typeof(string));
    
            var ngaysinhParameter = ngaysinh.HasValue ?
                new ObjectParameter("ngaysinh", ngaysinh) :
                new ObjectParameter("ngaysinh", typeof(System.DateTime));
    
            var diachiParameter = diachi != null ?
                new ObjectParameter("diachi", diachi) :
                new ObjectParameter("diachi", typeof(string));
    
            var sdtParameter = sdt != null ?
                new ObjectParameter("sdt", sdt) :
                new ObjectParameter("sdt", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_khachhang", idParameter, hotenParameter, ngaysinhParameter, diachiParameter, sdtParameter);
        }
    
        public virtual int sp_update_nhanvien_nhanvien(string id, string hoten, Nullable<System.DateTime> ngaysinh, string diachi, string sdt)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            var hotenParameter = hoten != null ?
                new ObjectParameter("hoten", hoten) :
                new ObjectParameter("hoten", typeof(string));
    
            var ngaysinhParameter = ngaysinh.HasValue ?
                new ObjectParameter("ngaysinh", ngaysinh) :
                new ObjectParameter("ngaysinh", typeof(System.DateTime));
    
            var diachiParameter = diachi != null ?
                new ObjectParameter("diachi", diachi) :
                new ObjectParameter("diachi", typeof(string));
    
            var sdtParameter = sdt != null ?
                new ObjectParameter("sdt", sdt) :
                new ObjectParameter("sdt", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_nhanvien_nhanvien", idParameter, hotenParameter, ngaysinhParameter, diachiParameter, sdtParameter);
        }
    
        public virtual int sp_update_nhanvien_quanly(string id, Nullable<int> luongcb, Nullable<double> heso)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            var luongcbParameter = luongcb.HasValue ?
                new ObjectParameter("luongcb", luongcb) :
                new ObjectParameter("luongcb", typeof(int));
    
            var hesoParameter = heso.HasValue ?
                new ObjectParameter("heso", heso) :
                new ObjectParameter("heso", typeof(double));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_nhanvien_quanly", idParameter, luongcbParameter, hesoParameter);
        }
    
        public virtual int sp_update_the(string id, string pass)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            var passParameter = pass != null ?
                new ObjectParameter("pass", pass) :
                new ObjectParameter("pass", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_the", idParameter, passParameter);
        }
    
        public virtual int sp_update_tktt(string id, Nullable<int> sodu)
        {
            var idParameter = id != null ?
                new ObjectParameter("id", id) :
                new ObjectParameter("id", typeof(string));
    
            var soduParameter = sodu.HasValue ?
                new ObjectParameter("sodu", sodu) :
                new ObjectParameter("sodu", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_update_tktt", idParameter, soduParameter);
        }
    }
}
