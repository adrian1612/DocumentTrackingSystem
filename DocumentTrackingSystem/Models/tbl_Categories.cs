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

            return s.Query<tbl_Categories>("SELECT * FROM [vw_Categories]")
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public tbl_Categories Find(int ID)
        {

            return s.Query<tbl_Categories>("SELECT * FROM [vw_Categories] where ID = @ID", p => p.Add("@ID", ID))
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public int Create(tbl_Categories obj)
        {
            var ID = s.Insert("[tbl_Categories]", p =>
            {
                p.Add("Category", obj.Category);
                p.Add("Color", obj.Color);
            });
            return ID;
        }

        public void Update(tbl_Categories obj)
        {
            s.Update("[tbl_Categories]", obj.ID, p =>
            {
                p.Add("Category", obj.Category);
                p.Add("Color", obj.Color);
            });
        }
        public void Delete(tbl_Categories obj)
        {
            s.Query("DELETE FROM [tbl_Categories] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }


}