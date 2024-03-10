using DocumentTrackingSystem.Classes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem.Models
{
    public class tbl_Categories
    {
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        [ScaffoldColumn(false)]
        public Int32 ID { get; set; }

        [Display(Name = "Document Type")]
        [Required]
        public String Category { get; set; }

        [DataType("color")]
        [Required]
        public string Color { get; set; }

        public int Total { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        public SelectList ListCategory()
        {
            return new SelectList(List(), "ID", "Category");
        }

        public tbl_Categories()
        {
        }
        public List<tbl_Categories> List()
        {

            return s.Query<tbl_Categories>("tbl_Categories_Proc", p => p.Add("@Type", "Search"), CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public tbl_Categories Find(int ID)
        {

            return s.Query<tbl_Categories>("tbl_Categories_Proc", p => { p.Add("@Type", "Find"); p.Add("@ID", ID); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public bool Create(tbl_Categories obj)
        {
            var result = false;
            s.Query("tbl_Categories_Proc", p =>
            {
                p.Add("@Type", "Create");
                p.Add("@Category", obj.Category);
                p.Add("@Color", obj.Color);
            }, CommandType.StoredProcedure).
            ForEach(r => result = (bool)r[0]);
            return result;
        }

        public bool Update(tbl_Categories obj)
        {
            var result = false;
            s.Query("tbl_Categories_Proc", p =>
            {
                p.Add("@Type", "Update");
                p.Add("@ID", obj.ID);
                p.Add("@Category", obj.Category);
                p.Add("@Color", obj.Color);
            }, CommandType.StoredProcedure).
            ForEach(r => result = (bool)r[0]);
            return result;
        }

        public void Delete(tbl_Categories obj)
        {
            s.Query("tbl_Categories_Proc", p =>
            {
                p.Add("@Type", "Delete");
                p.Add("@ID", obj.ID);
            }, CommandType.StoredProcedure);
        }
    }


}