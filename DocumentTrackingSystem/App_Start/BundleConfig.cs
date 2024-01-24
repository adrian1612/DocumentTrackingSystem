using System.Web;
using System.Web.Optimization;

namespace DocumentTrackingSystem
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/jquery-ui-{version}.js",
                        "~/Scripts/jquery.unobtrusive-ajax.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.bundle.js",
                      "~/Scripts/jquery.mask.js",
                      "~/Scripts/echarts/echarts.js",
                      "~/Scripts/select2.js",
                      "~/Scripts/DataTables/jquery.dataTables.js",
                      "~/Scripts/DataTables/dataTables.bootstrap5.min.js",
                      "~/Scripts/DataTables/dataTables.buttons.js",
                      "~/Scripts/DataTables/buttons.print.js",
                      "~/Scripts/respond.js",
                      "~/Scripts/tinymce/tinymce.js",
                      "~/Scripts/fontawesome/all.js",
                      "~/Scripts/index.global.js",
                      "~/Scripts/main.js",
                      "~/Scripts/Angular/angular.js",
                      "~/Scripts/Angular/angular-route.js",
                      "~/Scripts/Angular/angular-animate.js",
                      "~/Scripts/scripts.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/css/select2.css",
                      "~/Content/css/select2-bootstrap-5-theme.min.css",
                      "~/Content/DataTables/css/dataTables.bootstrap5.min.css",
                      "~/Content/DataTables/css/buttons.dataTables.css",
                      "~/Content/all.css",
                      "~/Content/themes/base/jquery-ui.css",
                      "~/Content/variables.css",
                      "~/Content/bootstrap-icons/bootstrap-icons.css",
                      "~/Content/Style.css",
                      "~/Content/site.css"));
        }
    }
}
