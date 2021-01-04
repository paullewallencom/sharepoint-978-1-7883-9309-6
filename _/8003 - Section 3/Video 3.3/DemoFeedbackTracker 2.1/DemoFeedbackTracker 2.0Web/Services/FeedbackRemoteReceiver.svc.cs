using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.SharePoint.Client;
using Microsoft.SharePoint.Client.EventReceivers;
using Microsoft.SharePoint.Client.Utilities;
using OfficeDevPnP.Core;
using System.Configuration;

namespace DemoFeedbackTracker_2._0Web.Services
{
    public class FeedbackRemoteReceiver : IRemoteEventService
    {
        /// <summary>
        /// Handles events that occur before an action occurs, such as when a user adds or deletes a list item.
        /// </summary>
        /// <param name="properties">Holds information about the remote event.</param>
        /// <returns>Holds information returned from the remote event.</returns>
        public SPRemoteEventResult ProcessEvent(SPRemoteEventProperties properties)
        {
            SPRemoteEventResult result = new SPRemoteEventResult();
            ClientContext clientContext = null;
            try
            {
                clientContext = TokenHelper.CreateRemoteEventReceiverClientContext(properties);
            }
            catch (Exception ex)
            {
                // TODO : Log
            }

            if (clientContext == null)
            {
                string siteUrl = properties.ItemEventProperties.WebUrl;
                string acsAppId = ConfigurationManager.AppSettings["ClientId"];
                string acsSupport = ConfigurationManager.AppSettings["ClientSecret"];
                AuthenticationManager authManager = new AuthenticationManager();
                clientContext = authManager.GetAppOnlyAuthenticatedContext(siteUrl, acsAppId, acsSupport);
            }

            if (clientContext == null)
            {
                result.Status = SPRemoteEventServiceStatus.CancelNoError;
                return result;
            }

            using (clientContext)
            {
                clientContext.Load(clientContext.Web);
                var currentUser = clientContext.Web.CurrentUser;
                clientContext.Load(currentUser);
                clientContext.ExecuteQuery();

                string title = properties.ItemEventProperties.AfterProperties["Title"].ToString();
                var emailp = new EmailProperties();
                emailp.To = new List<string> { currentUser.Email,
                    "...@....onmicrosoft.com" };
                emailp.From = "notification@onmicrosoft.com";
                emailp.Body = "<b>html here...</b>";
                emailp.Subject = "subject: " + title;
                Utility.SendEmail(clientContext, emailp);
                clientContext.ExecuteQuery();
            }

            return result;
        }

        /// <summary>
        /// Handles events that occur after an action occurs, such as after a user adds an item to a list or deletes an item from a list.
        /// </summary>
        /// <param name="properties">Holds information about the remote event.</param>
        public void ProcessOneWayEvent(SPRemoteEventProperties properties)
        {
            using (ClientContext clientContext = TokenHelper.CreateRemoteEventReceiverClientContext(properties))
            {
                if (clientContext != null)
                {
                    clientContext.Load(clientContext.Web);
                    clientContext.ExecuteQuery();
                }
            }
        }
    }
}
