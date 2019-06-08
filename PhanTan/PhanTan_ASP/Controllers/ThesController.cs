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
    public class ThesController : Controller
    {
        private NganHangEntities db = new NganHangEntities();

        // GET: Thes
        public ActionResult Index()
        {
            var thes = db.Thes.Include(t => t.KhachHang1);
            return View(thes.ToList());
        }

        // GET: Thes/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            The the = db.Thes.Find(id);
            if (the == null)
            {
                return HttpNotFound();
            }
            return View(the);
        }

        // GET: Thes/Create
        public ActionResult Create()
        {
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten");
            return View();
        }

        // POST: Thes/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "ID,Password,KhachHang,rowguid")] The the)
        {
            if (ModelState.IsValid)
            {
                db.Thes.Add(the);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", the.KhachHang);
            return View(the);
        }

        // GET: Thes/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            The the = db.Thes.Find(id);
            if (the == null)
            {
                return HttpNotFound();
            }
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", the.KhachHang);
            return View(the);
        }

        // POST: Thes/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ID,Password,KhachHang,rowguid")] The the)
        {
            if (ModelState.IsValid)
            {
                db.Entry(the).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.KhachHang = new SelectList(db.KhachHangs, "ID", "Hoten", the.KhachHang);
            return View(the);
        }

        // GET: Thes/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            The the = db.Thes.Find(id);
            if (the == null)
            {
                return HttpNotFound();
            }
            return View(the);
        }

        // POST: Thes/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            The the = db.Thes.Find(id);
            db.Thes.Remove(the);
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
