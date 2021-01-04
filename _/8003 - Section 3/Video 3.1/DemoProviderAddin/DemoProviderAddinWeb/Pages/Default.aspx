<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DemoProviderAddinWeb.Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script
          src="https://code.jquery.com/jquery-1.12.4.min.js"
          integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ="
          crossorigin="anonymous"></script>
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
            $.getScript(scriptbase + "SP.UI.Controls.js")
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
    <div 
        id="chrome_ctrl_container"
        data-ms-control="SP.UI.Controls.Navigation"  
        data-ms-options=
            '{  
                "appHelpPageUrl" : "Help.aspx",
                "appIconUrl" : "https://upload.wikimedia.org/wikipedia/en/2/2a/PacktLogo.jpg",
                "appTitle" : "First glance at provider hosted add in",
                "settingsLinks" : [
                    {
                        "linkUrl" : "Link1.aspx",
                        "displayName" : "Demo link 1"
                    },
                    {
                        "linkUrl" : "Link2.aspx",
                        "displayName" : "Demo link 2"
                    }
                ]
             }'>
    </div>
    <form id="form1" runat="server">
    <div>
        <asp:Literal runat="server" ID="litOutput" />
    </div>
    </form>
</body>
</html>
