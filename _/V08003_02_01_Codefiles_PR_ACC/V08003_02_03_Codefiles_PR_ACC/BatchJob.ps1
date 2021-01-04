$tenant = "oleglearnssp"
$user = "oleg@$tenant.onmicrosoft.com"
# add this url to windows credential store
Connect-PnPOnline -Url "https://$tenant.sharepoint.com"

$creds = Get-StoredCredential -Target "https://$tenant.sharepoint.com" -Type Generic

function Process-SiteSelfServiceItem {
    param($item, $webUrl, $creds)
    $siteType = $item["SiteType"]
    $relDep = $item["RelatedDepartment"]
    $url = $siteType + "s"
    
    Connect-SPOService -Url "https://$tenant-admin.sharepoint.com" -Credential $creds

    try {
         New-SPOSite -Url "https://$tenant.sharepoint.com/sites/$url" -Title "$siteType(-s) Root" -Template 'STS#0' `
                -Owner $user -StorageQuota 100 -ResourceQuota 25 -ErrorAction SilentlyContinue
    } catch [Exception] {
        Write-Host  $_.Exception.Message
    }

    Connect-SPOnline -Url "https://$tenant.sharepoint.com/sites/$url" -Credentials $creds
    $template = "STS#0"
    if ($siteType -eq "Blog") { $template = "BLOG#0" }
    if ($siteType -eq "Project") { $template = "PROJECTSITE#0" }
    $targetUrl = "https://$tenant.sharepoint.com/sites/$url/$relDep"
    Write-Host $targetUrl
    New-PnPWeb -Title "$relDep $siteType" -Url $relDep -Template $template

    Apply-PnPProvisioningTemplate -Path "pnptemplate-$siteType.xml" `
        -Parameters @{depName="$relDep"} -Web "$relDep"

    Disconnect-PnPOnline 

    Connect-PnPOnline $webUrl
    $item["IsProcessed"] = $true
    $item["SiteLink"] = "$targetUrl"
    $item.Update()
    $item.Context.ExecuteQuery() 
}

$web = Get-PnPWeb /powershell
$items = Get-PnPListItem -Web $web -List "Site Self-Service" `
    -Query "<View><Query><Where><Eq><FieldRef Name='IsProcessed'/><Value Type='Integer'>0</Value></Eq></Where></Query></View>" -ErrorAction Stop
$items | Foreach {
    Process-SiteSelfServiceItem $_ $web.Url $creds
}

