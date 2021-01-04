# Action args in scheduled task:
# -ExecutionPolicy Bypass "& 'D:\Dropbox\Dev\_packt\Vol2\Section 2\Video 2.1\BatchJob.ps1'"
function Process-SSItem {
    param($item, $web)
    $at = $item["ArtefactType"]
    $dn = $item["DepartmentName"]
    $template = $at
    if ($at -eq "Calendar") { $template = "Events" }
    New-PnPList -Web $web -Title "($dn) $at" -Template $template -OnQuickLaunch
    $item["Processed"] = $true
    $item.Update()
    $item.Context.ExecuteQuery()
}

Connect-SPOnline -Url https://oleglearnssp.sharepoint.com/powershell
$web = Get-PnPWeb /powershell
$items = Get-PnPListItem -Web $web -List "List Self-Service" `
    -Query "<View><Query><Where><Eq><FieldRef Name='Processed'/><Value Type='Integer'>0</Value></Eq></Where></Query></View>" -ErrorAction Stop
$items | Foreach {
    Process-SSItem $_ $web
}