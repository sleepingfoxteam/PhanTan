//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TUIBANK_WEBAPP.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Account
    {
        public string AccountID { get; set; }
        public string Customer { get; set; }
        public System.DateTime StartDate { get; set; }
        public Nullable<System.DateTime> EndDate { get; set; }
        public Nullable<double> Interest { get; set; }
        public Nullable<int> Period { get; set; }
        public int Balance { get; set; }
        public string Branch { get; set; }
        public System.Guid rowguid { get; set; }
    
        public virtual Branch Branch1 { get; set; }
        public virtual Customer Customer1 { get; set; }
    }
}
