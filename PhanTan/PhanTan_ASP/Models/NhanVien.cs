//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
    public partial class NhanVien
    {
        public string ID { get; set; }
        public string HoTen { get; set; }
        public Nullable<System.DateTime> NgaySinh { get; set; }
        public int LuongCB { get; set; }
        public double HeSo { get; set; }
        public string ChiNhanh { get; set; }
        public string DiaChi { get; set; }
        public string Sdt { get; set; }
        public System.Guid rowguid { get; set; }
    
        public virtual ChiNhanh ChiNhanh1 { get; set; }
    }
}
