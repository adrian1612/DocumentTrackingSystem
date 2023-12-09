using DocumentTrackingSystem.Classes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Web;

namespace DocumentTrackingSystem.Models
{
    public class tbl_User
    {
        dbcontrol s = new dbcontrol();
        [Display(Name = "ID")]
        public Int32 ID { get; set; }

        [Display(Name = "Username")]
        [MinLength(4, ErrorMessage = "Atleast minimum of 4 character.")]
        [Required]
        public String Username { get; set; }

        [Display(Name = "Password")]
        [DataType(DataType.Password)]
        [MinLength(6, ErrorMessage = "Atleast minimum of 6 character.")]
        [Required]
        public String Password { get; set; }

        [Display(Name = "Role")]
        public Role Role { get; set; }

        [Display(Name = "Active")]
        public Boolean Active { get; set; }

        [Display(Name = "Given name")]
        [Required]
        public String fname { get; set; }

        [Display(Name = "Middle name")]
        public String mn { get; set; }

        [Display(Name = "Surname")]
        [Required]
        public String lname { get; set; }

        public string Fullname { get { return $"{fname} {mn} {lname}"; } }

        [Display(Name = "Gender")]
        [Required]
        public String gender { get; set; }

        [Display(Name = "Email")]
        [DataType(DataType.EmailAddress)]
        [Required]
        public String email { get; set; }

        [Display(Name = "Address")]
        [DataType(DataType.MultilineText)]
        [Required]
        public String address { get; set; }

        [Display(Name = "Timestamp")]
        [ScaffoldColumn(false)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:yyyy-MM-dd}")]
        [DataType(DataType.Date)]
        public DateTime? Timestamp { get; set; }

        public tbl_User()
        {
        }
        public List<tbl_User> List()
        {

            return s.Query<tbl_User>("tbl_User_Proc", p => { p.Add("@Type", "Search"); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).ToList();
        }

        public tbl_User Find(int ID)
        {

            return s.Query<tbl_User>("tbl_User_Proc", p => { p.Add("@Type", "Find"); p.Add("@ID", ID); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        public tbl_User Login(string username, string password)
        {
            return s.Query<tbl_User>("tbl_User_Proc", p => { p.Add("@Type", "Login"); p.Add("@Username", username); p.Add("@Password", password); }, CommandType.StoredProcedure)
            .Select(r =>
            {

                return r;
            }).SingleOrDefault();
        }

        /// <summary>
        /// Add user to database and return true if succeded and false if otherwise
        /// </summary>
        /// <param name="obj">User parameters</param>
        /// <returns>bool</returns>
        public bool Create(tbl_User obj)
        {
            var result = false;
            s.Query("tbl_User_Proc", p =>
            {
                p.Add("@Type", "Create");
                p.Add("@Username", obj.Username);
                p.Add("@Password", obj.Password);
                p.Add("@Role", obj.Role);
                p.Add("@Active", obj.Active);
                p.Add("@fname", obj.fname);
                p.Add("@mn", obj.mn);
                p.Add("@lname", obj.lname);
                p.Add("@gender", obj.gender);
                p.Add("@email", obj.email);
                p.Add("@address", obj.address);
            }, CommandType.StoredProcedure)
            .ForEach(r =>
            {
                result = (bool)r["Response"];
            });
            return result;
        }

        /// <summary>
        /// Update user to database and return true if succeded and false if otherwise
        /// </summary>
        /// <param name="obj">User parameters</param>
        /// <returns>bool</returns>
        public bool Update(tbl_User obj)
        {
            var result = false;
            s.Query("tbl_User_Proc", p =>
            {
                p.Add("@Type", "Update");
                p.Add("@ID", obj.ID);
                p.Add("@Username", obj.Username);
                p.Add("@Password", obj.Password);
                p.Add("@Role", obj.Role);
                p.Add("@Active", obj.Active);
                p.Add("@fname", obj.fname);
                p.Add("@mn", obj.mn);
                p.Add("@lname", obj.lname);
                p.Add("@gender", obj.gender);
                p.Add("@email", obj.email);
                p.Add("@address", obj.address);
            }, CommandType.StoredProcedure)
            .ForEach(r =>
            {
                result = (bool)r["Response"];
            });
            return result;
        }

        public void UpdateProfile(tbl_User obj)
        {
            s.Query("tbl_User_Proc", p =>
            {
                p.Add("@Type", "UpdateProfile");
                p.Add("@ID", obj.ID);
                p.Add("@Username", obj.Username);
                p.Add("@Password", obj.Password);
                p.Add("@fname", obj.fname);
                p.Add("@mn", obj.mn);
                p.Add("@lname", obj.lname);
                p.Add("@gender", obj.gender);
                p.Add("@email", obj.email);
                p.Add("@address", obj.address);
            }, CommandType.StoredProcedure);
        }

        public void Delete(tbl_User obj)
        {
            s.Query("DELETE FROM [tbl_User] WHERE ID = @ID", p =>
            {
                p.Add("@ID", obj.ID);
            });
        }
    }

    public enum Role
    {
        [Display(Name = "Super Admin")]
        Super_Admin = 1,
        [Display(Name = "Admin")]
        Admin = 2,
        [Display(Name = "User")]
        User = 3
    }

}