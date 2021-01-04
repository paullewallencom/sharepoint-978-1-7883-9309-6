using Microsoft.SharePoint.Client;
using OfficeDevPnP.Core;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Security;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoFeedbackTracker_2._0Web
{
    public partial class Handler : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string siteUrl = Page.Request["SPAppWebUrl"];
            string acsAppId = ConfigurationManager.AppSettings["ClientId"];
            string acsSupport = ConfigurationManager.AppSettings["ClientSecret"];
            AuthenticationManager authManager = new AuthenticationManager();
            ClientContext context = authManager.GetAppOnlyAuthenticatedContext(siteUrl, acsAppId, acsSupport);
            

            string action = Page.Request["action"];
            string result = string.Empty;
            switch (action)
            {
                case "GetAreas":
                    result = GetAreas(context);
                    break;
                case "PostFeedback":
                    result = PostFeedback(context);
                    break;
                default:
                    break;
            }

            Response.ContentType = "application/json";
            Response.Write(result);
        }

        private string PostFeedback(ClientContext ctx)
        {
            string result = "{ \"d\": true }";
            var areaId = Convert.ToInt32(Request["areaId"]);
            var title = Request["title"];
            var desc = Request["msg"];

            var list = ctx.Web.Lists.GetByTitle("Feedback Tracker");
            ListItemCreationInformation itemCreateInfo = new ListItemCreationInformation();
            Microsoft.SharePoint.Client.ListItem li;
            li = list.AddItem(itemCreateInfo);
            li["Title"] = title;
            li["Message"] = desc;
            li["Area"] = areaId;
            li.Update();
            ctx.ExecuteQuery();
            return result;
        }

        public static string GetAreas(ClientContext ctx)
        {
            string result = "{ \"d\":[";
            var list = ctx.Web.Lists.GetByTitle("Areas");
            var items = list.GetItems(new CamlQuery());
            ctx.Load(items, i => i.Include(item => item.DisplayName,
                                           item => item.Id));
            ctx.ExecuteQuery();
            foreach (var item in items)
            {
                result += "{ \"Title\": \"" + item.DisplayName + "\", \"ID\": " + item.Id + " },";
            }
            result = result.TrimEnd(',');
            result += "]}";
            return result;
        }
    }
}