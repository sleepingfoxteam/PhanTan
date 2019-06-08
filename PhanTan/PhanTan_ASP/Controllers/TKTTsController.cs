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
    public class TKTTsController : Controller
    {
        private NganHangEntities db = new NganHangEntities();

        // GET: TKTTs
        public ActionResult Index()
        {
            var tKTTs = db.TKTTs.Include(t => t.ChiNhanh1).Include(t => t.KhachHang1);
            return View(tKTTs.ToList());
        }

        // GET: TKTTs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTT tKTT = db.TKTTs.Find(id);
            if (tKTT == null)
            {
                return HttpNotFound();
            }
            return View(tKTT);
        }

        // GET: TKTTs/Create
        public ActionResult Create()
        {
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN");
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten");
            return View();
        }

        // POST: TKTTs/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "ID,KhachHang,ChiNhanh,SoDu,rowguid")] TKTT tKTT)
        {
            if (ModelState.IsValid)
            {
                db.TKTTs.Add(tKTT);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTT.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTT.KhachHang);
            return View(tKTT);
        }

        // GET: TKTTs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTT tKTT = db.TKTTs.Find(id);
            if (tKTT == null)
            {
                return HttpNotFound();
            }
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTT.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTT.KhachHang);
            return View(tKTT);
        }

        // POST: TKTTs/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ID,KhachHang,ChiNhanh,SoDu,rowguid")] TKTT tKTT)
        {
            if (ModelState.IsValid)
            {
                db.Entry(tKTT).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTT.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTT.KhachHang);
            return View(tKTT);
        }

        // GET: TKTTs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTT tKTT = db.TKTTs.Find(id);
            if (tKTT == null)
            {
                return HttpNotFound();
            }
            return View(tKTT);
        }

        // POST: TKTTs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            TKTT tKTT = db.TKTTs.Find(id);
            db.TKTTs.Remove(tKTT);
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
