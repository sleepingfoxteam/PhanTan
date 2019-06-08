using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PhanTan_ASP.Controllers
{
    public class HomeController : Controller
    {
       
        public ActionResult Index()
        {
            Session["role"] = "KhachHang";
            return View("Index","~/Views/Shared/_layout_khachhang.cshtml");
        }
    }
}