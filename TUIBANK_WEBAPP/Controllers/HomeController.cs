using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace TUIBANK_WEBAPP.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(string role)
        {

            if (role != null)
            {
                Session["role"] = role;
                return View();
            }
            return View("RoleEx","~/Views/Shared/_empty_layout.cshtml");
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}