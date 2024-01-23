using DocumentTrackingSystem.Classes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Web;

namespace DocumentTrackingSystem.Models
{
    public class tbl_Document
    {
      
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        [ScaffoldColumn(false)]
        public Int32 ID { get; set; }

        [Display(Name = "Path")]
        public String Path { get; set; }

        [Display(Name = "Filename")]
        public String Filename { get; set; }

        public HttpPostedFileBase Upload { get; set; }

        [Display(Name = "QR Code")]
        [DisplayFormat(NullDisplayText = "N/A", ConvertEmptyStringToNull = true)]
        public String QRCode { get; set; }

        [Display(Name = "Received From")]
        [Required]
        public String ReceivedFrom { get; set; }

        [Display(Name = "Office")]
        [Required]
        public Int32 Office { get; set; }
        [Display(Name = "Office")]
        public string OfficeName { get; set; }

        [Display(Name = "Document Type")]
        [Required]
        public Int32 Category { get; set; }
        [Display(Name = "Document Type")]
        public string CategoryName { get; set; }

        [Display(Name = "Description")]
        [DataType(DataType.MultilineText)]
        [Required]
        public String Description { get; set; }

        [Display(Name = "Encoder")]
        [ScaffoldColumn(false)]
        public Int32 Encoder { get; set; }
        [Display(Name = "Encoder")]
        public string EncoderName { get; set; }

        [Display(Name = "Date")]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-ddThh:mm}")]
        [DataType("datetime-local")]
        public DateTime? Date { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        [Display(Name = "From")]
        public DateTime From { get; set; }

        [Display(Name = "To")]
        public DateTime To { get; set; }

        public tbl_Document()
        {
        }
        public List<tbl_Document> List()
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => { p.Add("@Type", "Search"); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public List<tbl_Document> List(string search)
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => { p.Add("@Type", "SearchFromReceived"); p.Add("@Search", search); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public List<tbl_Document> Reports(ReportType ReportType, tbl_Document obj)
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => 
            {
                p.Add("@Type", Enum.GetName(typeof(ReportType), ReportType));
                p.Add("@QRCode", obj.QRCode);
                p.Add("@Office", obj.Office);
                p.Add("@Category", obj.Category);
                p.Add("@From", obj.From);
                p.Add("@To", obj.To);
            }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public List<string> ReceivedFromList(string Term)
        {
            var list = new List<String>();
            s.Query("tbl_Document_Proc", p => { p.Add("@Type", "ReceivedFromList"); p.Add("@Search", Term); }, CommandType.StoredProcedure).ForEach(r =>
            {
                list.Add(r[0] as string);
            });
            return list;
        }

        string DestinationPath(string Sub, string ReceivedFrom)
        {
            return $"~/Attachment/{Sub}/{ReceivedFrom}";
        }

        public tbl_Document Find(int ID)
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => { p.Add("@Type", "Find"); p.Add("@ID", ID); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        tbl_Categories cat = new tbl_Categories();
        public void Create(tbl_Document obj)
        {
            var sub = cat.Find(obj.Category).Category;
            var document = s.SaveFile(DestinationPath(sub, obj.ReceivedFrom), obj.Upload, obj.Path);
            s.Query("tbl_Document_Proc", p =>
            {
                p.Add("@Type", "Create");
                p.Add("@Path", document);
                p.Add("@Filename", obj.Upload.FileName);
                p.Add("@QRCode", obj.QRCode);
                p.Add("@ReceivedFrom", obj.ReceivedFrom);
                p.Add("@Office", obj.Office);
                p.Add("@Category", obj.Category);
                p.Add("@Description", obj.Description);
                p.Add("@Encoder", UserSession.User.ID);
                p.Add("@Date", obj.Date);

            }, CommandType.StoredProcedure);
        }

        public void Update(tbl_Document obj)
        {
            var sub = cat.Find(obj.Category).Category;
            var document = s.SaveFile(DestinationPath(sub, obj.ReceivedFrom), obj.Upload, obj.Path, true);
            s.Query("tbl_Document_Proc", p =>
            {
                p.Add("@Type", "Update");
                p.Add("@ID", obj.ID);
                p.Add("@Path", document);
                p.Add("@Filename", obj.Upload == null ? obj.Filename : obj.Upload.FileName);
                p.Add("@QRCode", obj.QRCode);
                p.Add("@ReceivedFrom", obj.ReceivedFrom);
                p.Add("@Office", obj.Office);
                p.Add("@Category", obj.Category);
                p.Add("@Description", obj.Description);
                p.Add("@Date", obj.Date);

            }, CommandType.StoredProcedure);
        }
        public void Delete(tbl_Document obj)
        {
            s.Query("DELETE FROM [tbl_Document] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }

    public enum ReportType
    {
        ByDate,
        ByOffice,
        ByDocumentType,
        ByQRCode
    }


}