using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.SharePoint.Client;
using System.Data;

namespace DemoFeedbackTracker_2._0Web
{
    public partial class Feedback : System.Web.UI.Page
    {
        protected void Page_PreInit(object sender, EventArgs e)
        {
            Uri redirectUrl;
            switch (SharePointContextProvider.CheckRedirectionStatus(Context, out redirectUrl))
            {
                case RedirectionStatus.Ok:
                    return;
                case RedirectionStatus.ShouldRedirect:
                    Response.Redirect(redirectUrl.AbsoluteUri, endResponse: true);
                    break;
                case RedirectionStatus.CanNotRedirect:
                    Response.Write("An error occurred while processing your request.");
                    Response.End();
                    break;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(Context);

            using (var clientContext = spContext.CreateUserClientContextForSPAppWeb())
            {
                var lstFeedback = clientContext.Web.Lists.GetByTitle("Feedback Tracker");
                var listItems = lstFeedback.GetItems(new Microsoft.SharePoint.Client.CamlQuery());
                clientContext.Load(lstFeedback, lst => lst.Title, lst => lst.DefaultViewUrl);
                clientContext.Load(listItems, i => 
                                    i.Include(item => item.DisplayName,
                                              item => item.Id,
                                              item => item["Area"],
                                              item => item["Message"],
                                              item => item.ContentType));
                clientContext.ExecuteQuery();

                hlFeedbackList.NavigateUrl = new Uri(clientContext.Url).GetLeftPart(UriPartial.Authority) + lstFeedback.DefaultViewUrl;
                hlFeedbackList.Text = lstFeedback.Title;

                gvListData.DataSource = TransformIntoDataTable(listItems);
                gvListData.DataBind();
            }
        }

        private DataTable TransformIntoDataTable(Microsoft.SharePoint.Client.ListItemCollection listItems)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Title");
            dt.Columns.Add("Message");
            dt.Columns.Add("Area");
            dt.Columns.Add("ContentType");

            foreach (var item in listItems)
            {
                var row = dt.NewRow();
                row["Title"] = item.DisplayName;
                row["Message"] = item["Message"];
                row["ContentType"] = item.ContentType.Name;
                row["Area"] = ((FieldLookupValue)item["Area"]).LookupValue;
                dt.Rows.Add(row);
            }

            return dt;
        }
    }
}