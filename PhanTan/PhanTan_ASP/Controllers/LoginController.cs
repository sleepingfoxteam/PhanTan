using Newtonsoft.Json.Linq;
using PhanTan_ASP.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Mvc;
using System.Web.Security;

namespace PhanTan_ASP.Controllers
{
    public class LoginController : Controller
    { 
        // GET: Login
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public dynamic Check()
        {
            string json;
            using (var reader = new StreamReader(Request.InputStream))
            {
                json = reader.ReadToEnd();
            }
            var object_json = JObject.Parse(json);
            string username = object_json.Value<string>("username");
            string password = object_json.Value<string>("password");
            string chinhanh = object_json.Value<string>("chinhanh");
            var result = ConnectDatabase(username, password, chinhanh);
            if(result == "connected")
            {
                string configconnectionstring = getConfigConnectionString(username, password, chinhanh);
                // update web.config
                try
                {
                    Configuration webconfig = WebConfigurationManager.OpenWebConfiguration("~");
                    var section = (ConnectionStringsSection)webconfig.GetSection("connectionStrings");
                    section.ConnectionStrings["NganHangEntities"].ConnectionString = configconnectionstring;
                    webconfig.Save();
                    string[] roles = Roles.GetAllRoles();
                    return 1;
                }
                catch(Exception ex)
                {
                    return ex.Message;
                }
            }
            else
            {
                return result;
            }
        }

        public dynamic ConnectDatabase(string username, string password, string chinhanh)
        {
            try
            {
                SqlConnection conn = new SqlConnection();
                conn.ConnectionString = "data source = DESKTOP-4AOI1UG\\" + chinhanh + "; initial catalog = NganHang; user id = " + username + "; password = " + password;
                conn.Open();
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    conn.Close();
                    return "connected";
                }
                return "cannot open";
            }
            catch(Exception ex)
            {
                return ex.Message;
            }
        }

        public string getConfigConnectionString(string username,string password,string chinhanh)
        {
            string connectionstring = "metadata=res://*/Models.PhanTan.csdl|res://*/Models.PhanTan.ssdl|res://*/Models.PhanTan.msl;provider=System.Data.SqlClient;provider connection string=\"data source=DESKTOP-4AOI1UG\\"+chinhanh+";initial catalog=NganHang;user id="+username+";password="+password+";MultipleActiveResultSets=True;App=EntityFramework\"";
            return connectionstring;
        }
    }
}