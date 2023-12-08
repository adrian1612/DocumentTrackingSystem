using DocumentTrackingSystem.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DocumentTrackingSystem
{
    public class Authorized : AuthorizeAttribute
    {
        private readonly string[] allowedroles;
        public Authorized(params string[] roles)
        {
            this.allowedroles = roles;
        }

        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            bool authorize = false;
            if (allowedroles.Count() >= 1)
            {
                foreach (var role in allowedroles)
                {
                    if (UserSession.User.Role.ToString() == role || role == UserSession.User.Username)
                    {
                        authorize = true;
                    }
                }
            }
            else
            {
                if (UserSession.User != null)
                {
                    authorize = true;
                }
                else
                {
                    httpContext.Response.Redirect("/");
                }
            }
            
            return authorize;
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            filterContext.Result = new RedirectToRouteResult(new System.Web.Routing.RouteValueDictionary
            {
                { "controller", "Home" },
                { "action", "RestrictedAccess" }
            });
        }
    }

    /// <summary>
    /// Author: Adrian Aranilla Jaspio
    /// Position: Programmer
    /// Date: June 23, 2023 3:30 PM
    /// 
    /// Subordinate: Jose Lamud Montenegro
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, Inherited = true, AllowMultiple = false)]
    public class FilterDisplay : FilterAttribute, IAuthorizationFilter
    {
        //Change model according to structure, make sure the model has Role or filtering properties
        /*tbl_user*/
        tbl_User session { get { return HttpContext.Current.Session["User"] as tbl_User; } }

        //1) Add properties to filter
        public string Add { get; set; } = "";
        public string Edit { get; set; } = "";
        public string Delete { get; set; } = "";
        public bool DisplayNullProperties { get; set; }

        protected void FilterCore(FilterDisplay obj)
        {
            if (obj == null) return;
            string output = string.Empty;
            var list = new List<ObjectProp>();
            //2) Add items here to filter the front-end
            list.Add(new ObjectProp(obj.Add, "[aria-action='Add']"));
            list.Add(new ObjectProp(obj.Edit, "[aria-action='Edit']"));
            list.Add(new ObjectProp(obj.Delete, "[aria-action='Delete']"));

            //Do not touch this!
            var items = (from r in list where !(string.IsNullOrEmpty(r.Prop) && obj.DisplayNullProperties) && !r.RoleExist(session.Role) select r).ToList();
            items.ForEach(r =>
            {
                output += $"{r.Html},";
            });

            if (!string.IsNullOrEmpty(output))
            {
                output = output.Substring(0, output.Length - 1);
                string css = $"<style id='filtercss'>{output}{{ display: none !important; }}</style>";
                string js = $"<script id='filterjs'>window.addEventListener('load', function () {{ $(`{output}, #filtercss, #filterjs`).remove(); }})</script>";
                HttpContext.Current.Response.Write($"{css}{js}");
            }
        }

        class ObjectProp
        {
            public string Prop { get; set; }
            public string Html { get; set; }
            public ObjectProp(string Prop, string Html)
            {
                this.Prop = Prop;
                this.Html = Html;
            }

            public bool RoleExist(object Role)
            {
                return Prop.Split(',').ToList().Exists(f => f == $"{Role}");
            }
        }

        void IAuthorizationFilter.OnAuthorization(AuthorizationContext filterContext)
        {
            var item = (from a in filterContext.ActionDescriptor.GetCustomAttributes(true) where a.GetType() == typeof(FilterDisplay) select (FilterDisplay)a).FirstOrDefault();
            FilterCore(item);
        }
    }
}

