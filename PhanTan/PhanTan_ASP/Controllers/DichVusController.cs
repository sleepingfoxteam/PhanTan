using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PhanTan_ASP.Controllers
{
    public class DichVusController : Controller
    {
        // GET: DichVus
        public ActionResult Index()
        {
            return View();
        }

        // GET: TaiKhoanThanhToan
        public ActionResult TaiKhoanThanhToan()
        {
            return View();
        }

        //GET: TaiKhoanTietKiem
        public ActionResult TaiKhoanTietKiem()
        {
            return View();
        }

        public ActionResult TheThanhToan()
        {
            return View();
        }

        public ActionResult InternetBanking()
        {
            return View();
        }
    }
}