using DocumentTrackingSystem.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem.Models
{
    public class DocumentController : Controller
    {
        tbl_Document mod = new tbl_Document();
        public ActionResult Index()
        {
            var list = mod.List();
            return View(list);
        }

        [ActionName("Search")]
        public ActionResult SearchFromReceived(string query)
        {
            var list = mod.List(search: query);
            if (list.Count >= 1)
            {
                ViewBag.Keyword = list[0].ReceivedFrom;
            }
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

        public ActionResult ReceivedFrom(string Term)
        {
            return Json(mod.ReceivedFromList(Term), JsonRequestBehavior.AllowGet);
        }

        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Create(tbl_Document m)
        {
            if (ModelState.IsValid)
            {
                mod.Create(m);
                return RedirectToAction("Index");
            }
            return View(m);
        }

        public ActionResult Edit(int ID)
        {
            var item = mod.Find(ID);
            return View(item);
        }

        [HttpPost]
        public ActionResult Edit(tbl_Document m)
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
        public ActionResult Delete(tbl_Document m)
        {
            m.Delete(m);
            return RedirectToAction("Index");
        }
    }
}