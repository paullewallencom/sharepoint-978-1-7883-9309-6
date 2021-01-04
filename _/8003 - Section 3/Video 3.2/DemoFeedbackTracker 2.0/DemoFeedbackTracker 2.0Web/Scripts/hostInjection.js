demoFeedbackAppWebUrl = demoFeedbackAppWebUrl.toLowerCase();
demoFeedbackProviderAppUrl = demoFeedbackProviderAppUrl.toLowerCase();

console.log("Here we are at: " + window.location.href);

var headID;
var newScript;

if (!window.jQuery) {
    headID = document.getElementsByTagName('head')[0];
    newScript = document.createElement('script');
    newScript.type = 'text/javascript';
    newScript.src = demoFeedbackProviderAppUrl + '/scripts/jquery-1.9.1.min.js';
    headID.appendChild(newScript);
}

defer();

function defer() {
    if (window.jQuery) {
        $.getScript("/_layouts/15/SP.js", function () {
            $.getScript(demoFeedbackAppWebUrl + "/_layouts/15/SP.RequestExecutor.js", function () {
                $.getScript("/_layouts/15/init.js", mainLogic);
            });
        });
    }
    else {
        setTimeout(function () { defer() }, 100);
    }
}

var executor;
function mainLogic() {
    loadFeedbackControlHtml();

    $.ajax({
        type: "GET",
        url: demoFeedbackProviderAppUrl + "/pages/handler.aspx?action=GetAreas&" + getStandardTokens(),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (msg) {
            for (var i = 0; i < msg.d.length; i++) {
                $('#feedbackAreaSelect').append($('<option>', { value: msg.d[i].ID }).text(msg.d[i].Title));
            }
        },
        error: function (msg, err) {
            //debugger
            //alert("error:" + JSON.stringify(msg));
            console.log("error:" + JSON.stringify(msg));
        }
    });

    $("#feedback-tab").click(function () {
        $("#feedback-form").toggle("slide");
    });
    $("#feedback-form form").on('submit', onFeedbackFormSubmitClick);
}

function onFeedbackFormSubmitClick(event) {
    event.preventDefault();

    // gather parameters
    var title = $("#feedback-form").find("input[type='text'][name='title']").val();
    var message = $("#feedback-form").find("textarea[name='body']").val();
    var areaId = $("#feedbackAreaSelect").val();

    $.ajax({
        url: demoFeedbackProviderAppUrl + "/pages/handler.aspx?action=PostFeedback&" + getStandardTokens()
            + "&areaId=" + areaId + "&title=" + title + "&msg=" + message,
        method: "GET",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            $("#feedback-form").find("input[type='text'][name='title']").val('');
            $("#feedback-form").find("textarea[name='body']").val('');
            $("#feedback-form").toggle("slide");
        },
        error: function (msg, err) {
            //alert("error:" + JSON.stringify(msg));
            console.log("error:" + JSON.stringify(msg));
        }
    });
}

function loadFeedbackControlHtml() {
    var feedbackHtmlContainer = document.createElement("div");
    $(feedbackHtmlContainer).html('	<div id="feedback">\
		<div id="feedback-form" style=\'display:none;\' class="col-xs-4 col-md-4 panel panel-default">\
			<form method="POST" class="form panel-body" role="form">\
				<div class="form-group">\
					<input class="form-control" name="title" required autofocus placeholder="Title of feedback" type="text" />\
				</div>\
				<div class="form-group">\
                    Area:\
					<select id="feedbackAreaSelect" class="form-control" name="area" required></select>\
				</div>\
				<div class="form-group">\
					<textarea class="form-control" name="body" required placeholder="Please write your feedback here..." rows="5"></textarea>\
				</div>\
				<button class="btn btn-primary pull-right" type="submit">Send</button>\
			</form>\
		</div>\
		<div id="feedback-tab">Feedback</div>\
	</div>');
    $("#contentRow").prepend(feedbackHtmlContainer);
}

function getStandardTokens() {
    return "SPHostUrl=" + window.location.protocol + "//" + window.location.hostname
        + "&SPAppWebUrl=" + demoFeedbackAppWebUrl;// + "&SPProductNumber=16%2E0%2E6525%2E1205&SPLanguage=en-US&SPClientTag=54";
}