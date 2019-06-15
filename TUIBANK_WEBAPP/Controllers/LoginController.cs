using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Linq;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Mvc;
using TUIBANK_WEBAPP.Models;

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

        [HttpPost]
        public dynamic Login()
        {
            string username = Request["username"];
            string password = Request["password"];
            string branch = Request["branch"];
            branch = branch.Equals("BRHCM")==true ? "CN1" : "CN2";
            string CONNECTION_STRING = "metadata=res://*/Models.TUIBANK.csdl|res://*/Models.TUIBANK.ssdl|res://*/Models.TUIBANK.msl;provider=System.Data.SqlClient;provider connection string=\"data source=DESKTOP-4AOI1UG\\"+branch+";initial catalog=TUIBANK;user id="+username+";password="+password+";MultipleActiveResultSets=True;App=EntityFramework\"";
            string SHORT = "Data Source = DESKTOP-4AOI1UG\\"+branch+"; Initial Catalog = TUIBANK; Persist Security Info = True; User ID ="+username+ "; Password = " + password;
            SqlConnection conn = new SqlConnection(SHORT);
            bool loged = false;
            try
            {
                conn.Open();
                if(conn.State == System.Data.ConnectionState.Open)
                {
                    loged = true;
                }
                conn.Close();
            }
            catch(Exception ex)
            {
                return ex.Message;
            }
            if(loged == true)
            {
                try
                {
                    Configuration connectionConfiguration = WebConfigurationManager.OpenWebConfiguration("~");
                    connectionConfiguration.ConnectionStrings.ConnectionStrings["TUIBANKEntities"].ConnectionString = CONNECTION_STRING;
                    connectionConfiguration.Save(ConfigurationSaveMode.Modified);
                    ConfigurationManager.RefreshSection("connectionStrings");
                    // TODO: get role of user
                    TUIBANKEntities db = new TUIBANKEntities();
                    return RedirectToAction("Index", "Home", new { role = "Staff"});
                }
                catch(Exception ex)
                {
                    return ex.Message;
                }
            }
            else
            {
                return -1;
            }
        }
    }
}