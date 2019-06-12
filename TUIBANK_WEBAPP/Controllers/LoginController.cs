using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace TUIBANK_WEBAPP.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        public ActionResult Index()
        {
            return View("Index","~/Views/Shared/_empty_layout.cshtml");
        }

        public ActionResult DangXuat()
        {
            return View("Index", "~/Views/Shared/_empty_layout.cshtml");
        }
    }
}