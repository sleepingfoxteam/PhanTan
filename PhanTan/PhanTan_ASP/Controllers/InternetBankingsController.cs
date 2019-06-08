using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using PhanTan_ASP.Models;

namespace PhanTan_ASP.Controllers
{
    public class InternetBankingsController : Controller
    {
        private NganHangEntities db = new NganHangEntities();

        // GET: InternetBankings
        public ActionResult Index()
        {
            var internetBankings = db.InternetBankings.Include(i => i.KhachHang1);
            return View(internetBankings.ToList());
        }

        // GET: InternetBankings/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            InternetBanking internetBanking = db.InternetBankings.Find(id);
            if (internetBanking == null)
            {
                return HttpNotFound();
            }
            return View(internetBanking);
        }

        // GET: InternetBankings/Create
        public ActionResult Create()
        {
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten");
            return View();
        }

        // POST: InternetBankings/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "Username,Password,KhachHang,rowguid")] InternetBanking internetBanking)
        {
            if (ModelState.IsValid)
            {
                db.InternetBankings.Add(internetBanking);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", internetBanking.KhachHang);
            return View(internetBanking);
        }

        // GET: InternetBankings/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            InternetBanking internetBanking = db.InternetBankings.Find(id);
            if (internetBanking == null)
            {
                return HttpNotFound();
            }
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", internetBanking.KhachHang);
            return View(internetBanking);
        }

        // POST: InternetBankings/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Username,Password,KhachHang,rowguid")] InternetBanking internetBanking)
        {
            if (ModelState.IsValid)
            {
                db.Entry(internetBanking).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", internetBanking.KhachHang);
            return View(internetBanking);
        }

        // GET: InternetBankings/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            InternetBanking internetBanking = db.InternetBankings.Find(id);
            if (internetBanking == null)
            {
                return HttpNotFound();
            }
            return View(internetBanking);
        }

        // POST: InternetBankings/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            InternetBanking internetBanking = db.InternetBankings.Find(id);
            db.InternetBankings.Remove(internetBanking);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
