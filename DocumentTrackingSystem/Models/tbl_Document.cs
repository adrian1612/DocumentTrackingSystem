using DocumentTrackingSystem.Classes;
using IronBarCode;
using QRCoder;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Drawing;
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
        public int QRCode { get; set; }

        public string QRCodeText { get; set; }

        public byte[] QRCodeBytes
        {
            get
            {
                if (string.IsNullOrEmpty(QRCodeText))
                {
                    return null;
                }
                else
                {
                    var qrgen = new QRCodeGenerator();
                    var qrdata = qrgen.CreateQrCode(QRCodeText, QRCodeGenerator.ECCLevel.Q);
                    var qrcode = new QRCode(qrdata);
                    var bmp = qrcode.GetGraphic(7);
                    var converter = new ImageConverter();
                    var result = (byte[])converter.ConvertTo(bmp, typeof(byte[]));
                    return result;
                }
            }
        }

        public byte[] Barcode
        {
            get
            {
                var barcode = BarcodeWriter.CreateBarcode(QRCodeText, BarcodeWriterEncoding.Code128).Image;
                var converter = new ImageConverter();
                var result = (byte[])converter.ConvertTo(barcode, typeof(byte[]));
                return result;
            }
        }

        public string Barcode64
        {
            get
            {
                var output = "";
                if (QRCodeBytes != null)
                {
                    output = $"data:image/bmp;base64,{Convert.ToBase64String(Barcode)}";
                }
                return output;
            }
        }

        public string QRCode64
        {
            get
            {
                var output = "";
                if (QRCodeBytes != null)
                {
                    output = $"data:image/bmp;base64,{Convert.ToBase64String(QRCodeBytes)}";
                }
                return output;
            }
        }

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

        public int? startSeries { get; set; }

        public int? endSeries { get; set; }

        public DateTime? ADate { get; set; }
        public string Activity { get; set; }

        public List<tbl_Activity> Activities { get; set; }

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

        public tbl_Document DocumentInquiry(string QRCode)
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => { p.Add("@Type", "QRCode"); p.Add("@QRCode", QRCode); }, CommandType.StoredProcedure)
            .Select(r =>
            {
                r.Activities = new tbl_Activity().List(r.ID);
                return r;
            }).SingleOrDefault();
        }

        public List<tbl_Document> GenerateQR(int startSeries, int endSeries)
        {

            return s.Query<tbl_Document>("tbl_Document_Proc", p => { p.Add("@Type", "GenerateQR"); p.Add("@startSeries", startSeries); p.Add("@endSeries", endSeries); }, CommandType.StoredProcedure)
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
                switch (ReportType)
                {
                    case ReportType.ByDate:
                        p.Add("@From", obj.From);
                        p.Add("@To", obj.To);
                        break;
                    case ReportType.ByOffice:
                        p.Add("@Search", obj.OfficeName);
                        break;
                    case ReportType.ByDocumentType:
                        p.Add("@Search", obj.CategoryName);
                        break;
                    case ReportType.ByQRCode:
                        p.Add("@Search", obj.QRCode);
                        break;
                }
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
                r.Activities = new tbl_Activity().List(r.ID);
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
                p.Add("@QRCode", obj.QRCode);
                if(obj.Upload != null)
                    p.Add("@Filename", obj.Upload.FileName);
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
                p.Add("@QRCode", obj.QRCode);
                p.Add("@Filename", obj.Upload == null ? obj.Filename : obj.Upload.FileName);
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

        public List<tbl_Activity> AddActivity(tbl_Activity obj)
        {
            return s.Query<tbl_Activity>("tbl_Document_Proc", p =>
            {
                p.Add("@Type", "AddActivity");
                p.Add("@ID", obj.DocumentID);
                p.Add("@ADate", obj.ADate);
                p.Add("@Activity", obj.Activity);
                p.Add("@Encoder", UserSession.User.ID);
            }, CommandType.StoredProcedure).ToList();
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