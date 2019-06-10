using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PhanTan_ASP.Controllers
{
    public class UserController : Controller
    {
        // GET: User
        public ActionResult Index()
        {
            return View("Index","~/Views/Shared/_layout_user.cshtml");
        }
        
        //GET: TaiKhoanThanhToan
        public ActionResult TaiKhoanThanhToan()
        {
            return View("TaiKhoanThanhToan", "~/Views/Shared/_layout_user.cshtml");
        }

        // GET: TaiKhoanTietKiem
        public ActionResult TaiKhoanTietKiem()
        {
            return View("TaiKhoanTietKiem", "~/Views/Shared/_layout_user.cshtml");
        }

        // GET: TheThanhToan
        public ActionResult TheThanhToan()
        {
            return View("TheThanhToan", "~/Views/Shared/_layout_user.cshtml");
        }
    }
}