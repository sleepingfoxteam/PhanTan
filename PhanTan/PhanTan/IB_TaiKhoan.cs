//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
    public partial class IB_TaiKhoan
    {
        public string Username { get; set; }
        public string TaiKhoan { get; set; }
        public System.Guid rowguid { get; set; }
    
        public virtual InternetBanking InternetBanking { get; set; }
        public virtual TKTT TKTT { get; set; }
    }
}