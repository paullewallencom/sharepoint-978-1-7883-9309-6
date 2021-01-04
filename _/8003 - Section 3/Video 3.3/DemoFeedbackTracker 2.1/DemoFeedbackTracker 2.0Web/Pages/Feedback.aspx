<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="DemoFeedbackTracker_2._0Web.Feedback" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript">
        var hostweburl;

        // Load the SharePoint resources.
        $(document).ready(function () {
            // Get the URI decoded add-in web URL.
            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            // The SharePoint js files URL are in the form:
            // web_url/_layouts/15/resource.js
            var scriptbase = hostweburl + "/_layouts/15/";
            // Load the js file and continue to the 
            // success handler.
            $.getScript(scriptbase + "SP.UI.Controls.js", function () {
                var chromeSettings = {
                    "appHelpPageUrl": "Help.aspx",
                    "appIconUrl": "https://upload.wikimedia.org/wikipedia/en/2/2a/PacktLogo.jpg",
                    "appTitle": "Demo Feedback Tracker 2.0 (provider-hosted) - Feedback List",
                    "settingsLinks": [
                        {
                            "linkUrl": "Default.aspx" + window.location.search,
                            "displayName": "App home page"
                        },
                        {
                            "linkUrl": "Feedback.aspx" + window.location.search,
                            "displayName": "Feedback list"
                        }
                    ]
                }
                var nav = new SP.UI.Controls.Navigation("chrome_ctrl_container", chromeSettings);
                nav.setVisible(true);
            });

        });

        // Function to retrieve a query string value.
        function getQueryStringParameter(paramToRetrieve) {
            var params = document.URL.split("?")[1].replace("&amp;", "&").split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve) return singleParam[1];
            }
        }
    </script>
</head>
<body>
    <!-- Chrome control placeholder. Options are declared inline.  -->
    <div id="chrome_ctrl_container" data-ms-control="SP.UI.Controls.Navigation"></div>
    <form id="form1" runat="server">
    <div>
        <asp:HyperLink runat="server" ID="hlFeedbackList"></asp:HyperLink>
        <asp:GridView runat="server" ID="gvListData"></asp:GridView>
    </div>
    </form>
</body>
</html>
