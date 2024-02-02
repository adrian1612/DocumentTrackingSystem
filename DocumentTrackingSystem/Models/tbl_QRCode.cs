using DocumentTrackingSystem.Classes;
using QRCoder;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem.Models
{
    public class tbl_QRCode
    {
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        [ScaffoldColumn(false)]
        public Int32 ID { get; set; }

        [Display(Name = "QRCode")]
        public String QRCode { get; set; }

        public byte[] QRCodeBytes
        {
            get
            {
                var qrgen = new QRCodeGenerator();
                var qrdata = qrgen.CreateQrCode(QRCode, QRCodeGenerator.ECCLevel.Q);
                var qrcode = new QRCode(qrdata);
                var bmp = qrcode.GetGraphic(7);
                var converter = new ImageConverter();
                var result = (byte[])converter.ConvertTo(bmp, typeof(byte[]));
                return result;
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

        [Display(Name = "Count")]
        [Required]
        public int Count { get; set; }

        [Display(Name = "Encoder")]
        [ScaffoldColumn(false)]
        public Int32 Encoder { get; set; }

        public string EncoderName { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        public tbl_QRCode()
        {
        }
        public List<tbl_QRCode> List()
        {

            return s.Query<tbl_QRCode>("tbl_QRCode_Proc", p => { p.Add("@Type", "Search"); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public List<tbl_QRCode> AvailableQR(int? ID)
        {

            return s.Query<tbl_QRCode>("tbl_QRCode_Proc", p => { p.Add("@Type", "AvailableQR"); p.Add("@ID", ID); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public SelectList QRCodeList(int? ID = null)
        {
            return new SelectList(AvailableQR(ID), "ID", "QRCode");
        }

        public tbl_QRCode Find(int ID)
        {

            return s.Query<tbl_QRCode>("tbl_QRCode_Proc", p => { p.Add("@Type", "Find"); p.Add("@ID", ID); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public List<tbl_QRCode> Create(tbl_QRCode obj)
        {
            return s.Query<tbl_QRCode>("tbl_QRCode_Proc", p =>
            {
                p.Add("@Type", "Create");
                p.Add("@Count", obj.Count);
                p.Add("@Encoder", UserSession.User.ID);

            }, CommandType.StoredProcedure);
        }

        public void Update(tbl_QRCode obj)
        {
            s.Query("tbl_QRCode_Proc", p =>
            {
                p.Add("@Type", "Update");
                p.Add("@ID", obj.ID);
                p.Add("@QRCode", obj.QRCode);
                p.Add("@Encoder", obj.Encoder);

            }, CommandType.StoredProcedure);
        }
        public void Delete(tbl_QRCode obj)
        {
            s.Query("DELETE FROM [tbl_QRCode] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }


}