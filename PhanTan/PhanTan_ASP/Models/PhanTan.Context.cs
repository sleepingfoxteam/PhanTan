﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PhanTan_ASP.Models
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
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
    
        public virtual DbSet<ChiNhanh> ChiNhanhs { get; set; }
        public virtual DbSet<IB_TaiKhoan> IB_TaiKhoan { get; set; }
        public virtual DbSet<InternetBanking> InternetBankings { get; set; }
        public virtual DbSet<KhachHang> KhachHangs { get; set; }
        public virtual DbSet<NhanVien> NhanViens { get; set; }
        public virtual DbSet<The> Thes { get; set; }
        public virtual DbSet<The_TaiKhoan> The_TaiKhoan { get; set; }
        public virtual DbSet<TKTK> TKTKs { get; set; }
        public virtual DbSet<TKTT> TKTTs { get; set; }
    
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
    
        public virtual int sp_select_nhanvien(string hoten, string sdt, Nullable<int> luongcb, Nullable<double> heso)
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
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_select_nhanvien", hotenParameter, sdtParameter, luongcbParameter, hesoParameter);
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
