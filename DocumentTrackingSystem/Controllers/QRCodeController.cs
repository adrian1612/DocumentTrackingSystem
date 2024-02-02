using DocumentTrackingSystem.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem.Models
{
    [Authorized]
    public class QRCodeController : Controller
    {
        tbl_QRCode mod = new tbl_QRCode();
        public ActionResult Index()
        {
            var list = mod.List();
            return View(list);
        }

        public ActionResult Action(string Type, int? ID = null)
        {
            switch (Type)
            {
                case "Add":
                    return RedirectToAction("Create");
                case "Edit":
                    return RedirectToAction("Edit", new { ID = ID });
            }
            return View();
        }

        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Create(tbl_QRCode m)
        {
            Session["GenerateCount"] = null;
            return RedirectToAction("GenerateQR", new { Count = m.Count });
        }

        public ActionResult GenerateQR(int Count)
        {
            if (Session["GenerateCount"] == null)
            {
                var list = mod.Create(new tbl_QRCode { Count = Count });
                Tools.ReportWrapper("~/Reports/QRCodes.rdlc", "QRCodes", ReportFormat.PDF, (d, p) =>
                {
                    d.Add(new Microsoft.Reporting.WebForms.ReportDataSource("QRCode", list));
                });
            }
            Session["GenerateCount"] = 1;
            return RedirectToAction("Index");
        } 

        public ActionResult Edit(int ID)
        {
            var item = mod.Find(ID);
            return View(item);
        }

        [HttpPost]
        public ActionResult Edit(tbl_QRCode m)
        {
            if (ModelState.IsValid)
            {
                mod.Update(m);
                return RedirectToAction("Index");
            }
            return View(m);
        }

        public ActionResult Detail(int ID)
        {
            var item = mod.Find(ID);
            return View(item);
        }

        public ActionResult Delete(int ID)
        {
            var item = mod.Find(ID);
            return View(item);
        }

        [HttpPost]
        public ActionResult Delete(tbl_QRCode m)
        {
            m.Delete(m);
            return RedirectToAction("Index");
        }
    }
}