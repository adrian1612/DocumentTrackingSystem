using DocumentTrackingSystem.Classes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Web;

namespace DocumentTrackingSystem.Models
{
    public class tbl_Activity
    {
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        [ScaffoldColumn(false)]
        public Int32 ID { get; set; }

        [Display(Name = "Document")]
        public Int32 DocumentID { get; set; }

        [Display(Name = "Date")]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-ddTHH:mm}")]
        [DataType("datetime-local")]
        public DateTime? ADate { get; set; }

        public string ADatestring { get { return $"{ADate:dd-MMM-yy hh:mm tt}"; } }

        [Display(Name = "Activity")]
        public String Activity { get; set; }

        [Display(Name = "Encoder")]
        [ScaffoldColumn(false)]
        public Int32 Encoder { get; set; }

        public string EncoderName { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        public tbl_Activity()
        {
        }


        public List<tbl_Activity> List()
        {

            return s.Query<tbl_Activity>("SELECT * FROM [vw_Activity]")
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public List<tbl_Activity> List(int DocID)
        {

            return s.Query<tbl_Activity>("SELECT * FROM [vw_Activity] WHERE DocumentID = @ID ORDER BY ID DESC", p => p.Add("@ID", DocID))
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public tbl_Activity Find(int ID)
        {

            return s.Query<tbl_Activity>("SELECT * FROM vw_Activity where ID = @ID", p => p.Add("@ID", ID))
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public int Create(tbl_Activity obj)
        {
            var ID = s.Insert("[tbl_Activity]", p =>
            {
                p.Add("DocumentID", obj.DocumentID);
                p.Add("ADate", obj.ADate);
                p.Add("Activity", obj.Activity);
                p.Add("Encoder", UserSession.User.ID);

            });
            return ID;
        }

        public void Update(tbl_Activity obj)
        {
            s.Update("[tbl_Activity]", obj.ID, p =>
            {
                p.Add("DocumentID", obj.DocumentID);
                p.Add("ADate", obj.ADate);
                p.Add("Activity", obj.Activity);
                p.Add("Encoder", UserSession.User.ID);

            });
        }
        public void Delete(tbl_Activity obj)
        {
            s.Query("DELETE FROM [tbl_Activity] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }


}