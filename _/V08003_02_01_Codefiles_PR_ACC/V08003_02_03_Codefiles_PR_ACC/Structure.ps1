Install-Module -Name CredentialManager

$baseUrl = "https://oleglearnssp.sharepoint.com"
Connect-SPOnline -Url "$baseUrl/powershell"
$webRoot = Get-PnPWeb /powershell
$web = Get-PnPWeb /
$ctx = $webRoot.Context

#remove items
Remove-SPOSite -Identity "$baseUrl/sites/blogs" -Confirm:$false -ErrorAction SilentlyContinue
Remove-SPOSite -Identity "$baseUrl/sites/projects" -Confirm:$false -ErrorAction SilentlyContinue
Remove-SPOSite -Identity "$baseUrl/sites/teams" -Confirm:$false -ErrorAction SilentlyContinue
Remove-PnPList -Identity "Site Self-Service" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPContentType -Identity "Site self-service CT" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Site Type" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Related Department" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Processed?" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Site Link" -Web $webRoot -ErrorAction SilentlyContinue -Force

# Add Site Columns
Add-PnPField -Web $webRoot -InternalName SiteType -DisplayName "Site Type" -Required `
                    -Type Choice -Choices "Project","Team","Blog" -Group "PnP-Demo-Site" -ErrorAction SilentlyContinue
$fieldType = Get-PnPField -Identity SiteType

Add-PnPField -Web $webRoot -InternalName RelatedDepartment -DisplayName "Related Department" -Required `
                    -Type Text -Group "PnP-Demo-Site" -ErrorAction SilentlyContinue
$fieldDepName = Get-PnPField -Identity RelatedDepartment

Add-PnPField -Web $webRoot -InternalName IsProcessed -DisplayName "Processed?" -Required `
                    -Type Boolean -Group "PnP-Demo-Site" -ErrorAction SilentlyContinue
$fieldProcessed = Get-PnPField -Identity IsProcessed
$fieldProcessed.DefaultValue = 0
$fieldProcessed.Update()
Add-PnPField -Web $webRoot -InternalName SiteLink -DisplayName "Site Link" `
                    -Type URL -Group "PnP-Demo-Site" -ErrorAction SilentlyContinue
$fieldSiteLink = Get-PnPField -Identity SiteLink

# Add Content Type
#Get-Help -Name Add-PnPContentType -Examples
Add-PnPContentType -Name "Site self-service CT" -Web $webRoot -Group "Pnp-Demo-Site" -ErrorAction SilentlyContinue
$ctypeSiteSS = Get-PnPContentType "Site self-service CT" -Web $webRoot
Add-PnPFieldToContentType -Web $webRoot -Field $fieldType.Id -ContentType $ctypeSiteSS -Required
Add-PnPFieldToContentType -Web $webRoot -Field $fieldDepName.Id -ContentType $ctypeSiteSS -Required
Add-PnPFieldToContentType -Web $webRoot -Field $fieldSiteLink.Id -ContentType $ctypeSiteSS
Add-PnPFieldToContentType -Web $webRoot -Field $fieldProcessed.Id -ContentType $ctypeSiteSS
$fieldTitle = Get-PnPField -Identity "Title" -Web $web

# Add new list with ctype
New-PnPList -Title "Site Self-Service" -OnQuickLaunch -Web $webRoot -Template GenericList `
            -Url "Lists/SiteSelfService" -ErrorAction SilentlyContinue
$list = Get-PnPList -Identity "Site Self-Service"
$list.ContentTypesEnabled = $true
$list.EnableAttachments = $false
$list.Update()
Add-PnPContentTypeToList -Web $webRoot -List "Site Self-Service" -ContentType "Site self-service CT"
Remove-PnPContentTypeFromList -Web $webRoot -List "Site Self-Service" -ContentType Item

# Hide Processed field from new/edit forms
$f = Get-PnPField -Web $webRoot -List $list.Id -Identity $fieldProcessed.Id
$f.SetShowInEditForm($false)
$f.SetShowInNewForm($false)
$f.Update()
$f = Get-PnPField -Web $webRoot -List $list.Id -Identity $fieldSiteLink.Id
$f.SetShowInEditForm($false)
$f.SetShowInNewForm($false)
$f.Update()
$f = Get-PnPField -Web $webRoot -List $list.Id -Identity $fieldTitle.Id
$f.SetShowInEditForm($false)
$f.SetShowInNewForm($false)
$f.Update()

# Edit default view
Remove-PnPView -Web $webRoot -list $list.Id -Identity "Everything" -ErrorAction SilentlyContinue -Force
Add-PnPView -Web $webRoot -List $list.Id -Title "Everything" -SetAsDefault `
    -Fields $fieldType.InternalName,$fieldDepName.InternalName,$fieldProcessed.InternalName,$fieldSiteLink.InternalName `
    -ErrorAction SilentlyContinue