﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using TUIBANK_WEBAPP.Models;

namespace TUIBANK_WEBAPP.Controllers
{
    public class CustomersController : Controller
    {
        private TUIBANKEntities db = new TUIBANKEntities();

        // GET: Customers
        public ActionResult Index()
        {
            var customers = db.Customers.Include(c => c.Branch1);
            return View(customers.ToList());
        }

        // GET: Customers/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Customer customer = db.Customers.Find(id);
            if (customer == null)
            {
                return HttpNotFound();
            }
            return View(customer);
        }

        // GET: Customers/Create
        public ActionResult Create()
        {
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName");
            return View();
        }

        // POST: Customers/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "FullName,Birthday,Address,PhoneNumber,Branch,PID")] Customer customer)
        {
            if (ModelState.IsValid)
            {
                //default function
                //db.Customers.Add(customer);
                //use store procedure
                db.sp_add_Customer(customer.FullName, customer.Birthday, customer.Address, customer.PhoneNumber, customer.Branch, customer.PID);
                db.SaveChanges();
                return RedirectToAction("Index_Edit");
            }

            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", customer.Branch);
            return View(customer);
        }

        // GET: Customers/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Customer customer = db.Customers.Find(id);
            if (customer == null)
            {
                return HttpNotFound();
            }
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", customer.Branch);
            return View(customer);
        }

        // POST: Customers/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "CustomerID,FullName,Birthday,Address,PhoneNumber,Branch,PID,rowguid")] Customer customer)
        {
            if (ModelState.IsValid)
            {
                // defult function
                db.Entry(customer).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index_Edit");
            }
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", customer.Branch);
            return View(customer);
        }

        // GET: Customers/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Customer customer = db.Customers.Find(id);
            if (customer == null)
            {
                return HttpNotFound();
            }
            return View(customer);
        }

        // POST: Customers/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            Customer customer = db.Customers.Find(id);
            db.Customers.Remove(customer);
            db.SaveChanges();
            return RedirectToAction("Index_Delete");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        // GET: Main
        public ActionResult Main()
        {
            return View();
        }

        // GET: Index_Edit
        public ActionResult Index_Edit()
        {
            var customers = db.Customers.Include(c => c.Branch1);
            return View(customers.ToList());
        }

        // GET: Index_Delete
        public ActionResult Index_Delete()
        {
            var customers = db.Customers.Include(c => c.Branch1);
            return View(customers.ToList());
        }
    }
}
