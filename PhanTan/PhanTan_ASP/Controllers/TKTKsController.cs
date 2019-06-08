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
    public class TKTKsController : Controller
    {
        private NganHangEntities db = new NganHangEntities();

        // GET: TKTKs
        public ActionResult Index()
        {
            var tKTKs = db.TKTKs.Include(t => t.ChiNhanh1).Include(t => t.KhachHang1).Include(t => t.TKTT);
            return View(tKTKs.ToList());
        }

        // GET: TKTKs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTK tKTK = db.TKTKs.Find(id);
            if (tKTK == null)
            {
                return HttpNotFound();
            }
            return View(tKTK);
        }

        // GET: TKTKs/Create
        public ActionResult Create()
        {
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN");
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten");
            ViewBag.TaiKhoanLienKet = new SelectList(db.TKTTs, "ID", "KhachHang");
            return View();
        }

        // POST: TKTKs/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "ID,KhachHang,SoDu,KyHan,LaiSuat,NgayBatDau,NgayHetHan,TaiKhoanLienKet,ChiNhanh,rowguid")] TKTK tKTK)
        {
            if (ModelState.IsValid)
            {
                db.TKTKs.Add(tKTK);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTK.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTK.KhachHang);
            ViewBag.TaiKhoanLienKet = new SelectList(db.TKTTs, "ID", "KhachHang", tKTK.TaiKhoanLienKet);
            return View(tKTK);
        }

        // GET: TKTKs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTK tKTK = db.TKTKs.Find(id);
            if (tKTK == null)
            {
                return HttpNotFound();
            }
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTK.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTK.KhachHang);
            ViewBag.TaiKhoanLienKet = new SelectList(db.TKTTs, "ID", "KhachHang", tKTK.TaiKhoanLienKet);
            return View(tKTK);
        }

        // POST: TKTKs/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ID,KhachHang,SoDu,KyHan,LaiSuat,NgayBatDau,NgayHetHan,TaiKhoanLienKet,ChiNhanh,rowguid")] TKTK tKTK)
        {
            if (ModelState.IsValid)
            {
                db.Entry(tKTK).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.ChiNhanh = new SelectList(db.ChiNhanhs, "ID", "TenCN", tKTK.ChiNhanh);
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", tKTK.KhachHang);
            ViewBag.TaiKhoanLienKet = new SelectList(db.TKTTs, "ID", "KhachHang", tKTK.TaiKhoanLienKet);
            return View(tKTK);
        }

        // GET: TKTKs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            TKTK tKTK = db.TKTKs.Find(id);
            if (tKTK == null)
            {
                return HttpNotFound();
            }
            return View(tKTK);
        }

        // POST: TKTKs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            TKTK tKTK = db.TKTKs.Find(id);
            db.TKTKs.Remove(tKTK);
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
