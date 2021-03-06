﻿using Newtonsoft.Json;
using System;
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
    public class AccountsController : Controller
    {
        private TUIBANKEntities db = new TUIBANKEntities();

        // GET: Accounts
        public ActionResult Index()
        {
            var accounts = db.Accounts.Include(a => a.Branch1).Include(a => a.Customer1);
            return View(accounts.ToList());
        }

        // GET: Accounts/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Account account = db.Accounts.Find(id);
            if (account == null)
            {
                return HttpNotFound();
            }
            return View(account);
        }

        // GET: Accounts/Create
        public ActionResult Create()
        {
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName");
            ViewBag.Customer = new SelectList(db.Customers, "CustomerID", "FullName");
            return View();
        }

        // POST: Accounts/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "Customer,StartDate,EndDate,Interest,Period,Balance,Branch")] Account account)
        {
            if (ModelState.IsValid)
            {
                // default function to add into database
                //db.Accounts.Add(account);
                db.sp_add_Account(account.Customer, account.StartDate, null, account.Interest, account.Period, account.Balance, account.Branch);
                db.SaveChanges();
                return RedirectToAction("Index_Edit");
            }

            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", account.Branch);
            ViewBag.Customer = new SelectList(db.Customers, "CustomerID", "FullName", account.Customer);
            return View(account);
        }

        // GET: Accounts/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Account account = db.Accounts.Find(id);
            if (account == null)
            {
                return HttpNotFound();
            }
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", account.Branch);
            ViewBag.Customer = new SelectList(db.Customers, "CustomerID", "FullName", account.Customer);
            return View(account);
        }

        // POST: Accounts/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "AccountID,Customer,StartDate,EndDate,Interest,Period,Balance,Branch,rowguid")] Account account)
        {
            if (ModelState.IsValid)
            {
                // default function to update information
                // db.Entry(account).State = EntityState.Modified;
                // use seft define store procedure
                db.sp_update_Account(account.AccountID, account.Period, account.Interest, account.Balance, account.StartDate, account.EndDate);
                db.SaveChanges();
                return RedirectToAction("Index_Edit");
            }
            ViewBag.Branch = new SelectList(db.Branches, "BranchID", "BranchName", account.Branch);
            ViewBag.Customer = new SelectList(db.Customers, "CustomerID", "FullName", account.Customer);
            return View(account);
        }

        // GET: Accounts/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Account account = db.Accounts.Find(id);
            if (account == null)
            {
                return HttpNotFound();
            }
            return View(account);
        }

        // POST: Accounts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            Account account = db.Accounts.Find(id);
            // default function
            db.Accounts.Remove(account);
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

        // GET: Send
        public ActionResult Send()
        {
            var viewdata = db.View_Customer_Account;
            return View(viewdata.ToList());
        }

        // GET: Index_Edit
        public ActionResult Index_Edit()
        {
            var accounts = db.Accounts.Include(a => a.Branch1).Include(a => a.Customer1);
            return View(accounts.ToList());
        }

        // GET: Index_Delete
        public ActionResult Index_Delete()
        {
            var accounts = db.Accounts.Include(a => a.Branch1).Include(a => a.Customer1);
            return View(accounts.ToList());
        }

        public dynamic findAccountInfor()
        {
            string accountnumber = Request["accountnumber"];
            var information = db.sp_find_account_info(accountnumber);
            if(information != null)
            {
                string json_data = JsonConvert.SerializeObject(information.ToList().ElementAt(0));
                return json_data;
            }
            return -1;
        }
        public dynamic findAccountInforMore()
        {
            string accountnumber = Request["accountnumber"];
            var information = db.sp_find_account(accountnumber);
            if (information != null)
            {
                string json_data = JsonConvert.SerializeObject(information.ToList().ElementAt(0));
                return json_data;
            }
            return -1;
        }

        [HttpPost]
        public dynamic SendMoney()
        {
            int money = Int32.Parse(Request["money"]);
            string send_account = Request["send_account"];
            string recive_account = Request["recive_account"];
            int result = db.sp_send_money(send_account, recive_account, money);
            return result;
        }

        public ActionResult Calculator()
        {
            return View();
        }

        public dynamic Calculate()
        {
            int period, balance;
            float interest;
            Int32.TryParse(Request["period"], out period);
            Int32.TryParse(Request["balance"], out balance);
            float.TryParse(Request["interest"], out interest);
            float interest_per_period = interest/ 100 / 365 * 30 * period;
            DateTime today = DateTime.Today;
            string startdate_string = Request["startdate"];
            startdate_string = startdate_string.Split('T')[0];
            DateTime startdate;
            DateTime.TryParse(startdate_string, out startdate);
            int diff_days = (today - startdate).Days;
            int diff_months = diff_days / 30;
            Dictionary<Int64, Int64> dic_cal = new Dictionary<long, long>();
            dic_cal.Clear();
            Int64 balance_temp = balance;
            while (diff_months >= period)
            {
                Int64 cal = (Int64)(balance_temp * interest_per_period);
                dic_cal.Add(balance_temp, cal);
                balance_temp = balance_temp + cal;
                diff_months -= period;
            }
            return JsonConvert.SerializeObject(dic_cal);
        }
    }
}