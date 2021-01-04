using Microsoft.SharePoint.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoFeedbackTracker_2._0Web
{
    public partial class Default : System.Web.UI.Page
    {
        SharePointContext spContext = null;

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
            // button controls 
            btnApplyCustomization.Click += BtnApplyCustomization_Click;
            btnDisableCustomization.Click += BtnDisableCustomization_Click;

            spContext = SharePointContextProvider.Current.GetSharePointContext(Context);

            using (var clientContext = spContext.CreateAppOnlyClientContextForSPAppWeb())
            {
                FixLookupColumns(clientContext);
            }
        }

        private void BtnApplyCustomization_Click(object sender, EventArgs e)
        {
            OutputMessage("Starting...", true);

            using (var clientContext = spContext.CreateAppOnlyClientContextForSPHost())
            {
                AddJsFile(clientContext, Page.Request.Url.GetLeftPart(UriPartial.Authority) + '/',
                    spContext.SPAppWebUrl.AbsoluteUri);
                //AddJsFile(clientContext, spContext.SPAppWebUrl.AbsoluteUri);
            }
        }

        private void BtnDisableCustomization_Click(object sender, EventArgs e)
        {
            OutputMessage("Starting...", true);

            using (var clientContext = spContext.CreateAppOnlyClientContextForSPHost())
            {
                RemoveJsFile(clientContext);
            }
        }

        private void RemoveJsFile(ClientContext ctx)
        {
            var hostWeb = ctx.Web;
            var existingActions = hostWeb.UserCustomActions;
            ctx.Load(existingActions);
            ctx.ExecuteQuery();

            for (var i = 0; i < existingActions.Count; i++)
            {
                var action = existingActions[i];
                if (action.Description == "feedbackCustomization" &&
                    action.Location == "ScriptLink")
                {
                    action.DeleteObject();
                }
            }
            ctx.ExecuteQuery();
            OutputMessage("Removed successfully!");
            
        }

        private void AddJsFile(ClientContext ctx, string scriptLocation, string appWebUrl)
        {
            var hostWeb = ctx.Web;
            var revision = Guid.NewGuid().ToString("D");
            var jsLink = string.Format("{0}Scripts/hostInjection.js?rev={1}", scriptLocation, revision);

            var scriptBlock = @"
            var demoFeedbackAppWebUrl = '" + appWebUrl + @"';
            var demoFeedbackProviderAppUrl = '" + scriptLocation + @"';  
           
//SPAppToken     
            var headID = document.getElementsByTagName('head')[0];
            var newScript = document.createElement('script');
            newScript.type = 'text/javascript';
            newScript.src = '" + jsLink + @"';
            headID.appendChild(newScript); 
            var newStyle = document.createElement('link');
            newStyle.type = 'text/css';
            newStyle.rel = 'stylesheet';
            newStyle.href = '" + scriptLocation + @"content/feedback.css';
            headID.appendChild(newStyle);";

            var existingActions = hostWeb.UserCustomActions;
            ctx.Load(existingActions);
            ctx.ExecuteQuery();

            for (var i = 0; i < existingActions.Count; i++)
            {
                var action = existingActions[i];
                if (action.Description == "feedbackCustomization" &&
                    action.Location == "ScriptLink")
                {
                    action.DeleteObject();
                }
            }

            ctx.ExecuteQuery();

            var newAction = existingActions.Add();
            newAction.Description = "feedbackCustomization";
            newAction.Location = "ScriptLink";

            newAction.ScriptBlock = scriptBlock;
            newAction.Update();
            ctx.Load(newAction);
            ctx.ExecuteQuery();
            OutputMessage("Added successfully!");
        }

        private void FixLookupColumns(ClientContext clientContext)
        {
            try
            {
                var appWeb = clientContext.Web;
                var areasList = appWeb.Lists.GetByTitle("Areas");
                var feedbackList = appWeb.Lists.GetByTitle("Feedback Tracker");
                var field = appWeb.AvailableFields.GetByInternalNameOrTitle("Area");
                var listField = feedbackList.Fields.GetByInternalNameOrTitle("Area");
                clientContext.Load(areasList);
                clientContext.Load(feedbackList);
                feedbackList.Update();
                var views = feedbackList.Views;

                clientContext.Load(field);
                clientContext.Load(listField);
                clientContext.ExecuteQuery();

                var fieldLookup = clientContext.CastTo<FieldLookup>(field);
                fieldLookup.LookupField = "Title";
                fieldLookup.UpdateAndPushChanges(true);

                var fieldLookupList = clientContext.CastTo<FieldLookup>(listField);
                fieldLookupList.LookupField = "Title";
                fieldLookupList.UpdateAndPushChanges(true);
                feedbackList.Update();

                clientContext.ExecuteQuery();
            }
            catch (Exception ex)
            {
                litError.Text = ex.Message;
            }
        }

        private void OutputMessage(string text, bool overwrite = false)
        {
            if (overwrite)
            {
                message.InnerText = string.Empty;
            }
            message.InnerText += text + Environment.NewLine;
        }
    }
}