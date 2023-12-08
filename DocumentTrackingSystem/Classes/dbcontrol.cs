using DocumentTrackingSystem.Classes;
using DocumentTrackingSystem.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem.Classes
{
    public class dbcontrol : MasterControl
    {
        public dbcontrol() : base("DocumentTrackingSystem")
        {

        }
    }
}

public class Tools
{
    public static SelectList Gender
    {
        get
        {
            var list = new SelectList(new string[] { "Male", "Female" });
            return list;
        }
    }
}

public class UserSession
{
    public static tbl_User User { get { return (tbl_User)HttpContext.Current.Session["User"]; } }
}