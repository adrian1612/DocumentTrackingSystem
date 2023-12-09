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
    public class tbl_Office
    {
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        [ScaffoldColumn(false)]
        public Int32 ID { get; set; }

        [Display(Name = "Office")]
        [Required]
        public String Office { get; set; }

        [Display(Name = "Contact No.")]
        public String ContactNo { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        public SelectList ListOffice()
        {
            return new SelectList(List(), "ID", "Office");
        }

        public tbl_Office()
        {
        }
        public List<tbl_Office> List()
        {

            return s.Query<tbl_Office>("SELECT * FROM [tbl_Office]")
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public tbl_Office Find(int ID)
        {

            return s.Query<tbl_Office>("SELECT * FROM tbl_Office where ID = @ID", p => p.Add("@ID", ID))
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public int Create(tbl_Office obj)
        {
            var ID = s.Insert("[tbl_Office]", p =>
            {
                p.Add("Office", obj.Office);
                p.Add("ContactNo", obj.ContactNo);

            });
            return ID;
        }

        public void Update(tbl_Office obj)
        {
            s.Update("[tbl_Office]", obj.ID, p =>
            {
                p.Add("Office", obj.Office);
                p.Add("ContactNo", obj.ContactNo);

            });
        }
        public void Delete(tbl_Office obj)
        {
            s.Query("DELETE FROM [tbl_Office] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }


}