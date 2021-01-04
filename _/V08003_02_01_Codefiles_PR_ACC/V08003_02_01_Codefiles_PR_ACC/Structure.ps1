Connect-SPOnline -Url https://oleglearnssp.sharepoint.com/powershell
$webRoot = Get-PnPWeb /powershell
$web = Get-PnPWeb /
$ctx = $webRoot.Context

#remove items
Remove-PnPList -Identity "List Self-Service" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPContentType -Identity "List self-service CT" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Artefact Type" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Department Name" -Web $webRoot -ErrorAction SilentlyContinue -Force
Remove-PnPField -Identity "Processed" -Web $webRoot -ErrorAction SilentlyContinue -Force

# Add Site Columns
Add-PnPField -Web $webRoot -InternalName ArtefactType -DisplayName "Artefact Type" -Required `
                    -Type Choice -Choices "Calendar","Announcements" -Group "PnP-Demo" -ErrorAction SilentlyContinue
$fieldArtefact = Get-PnPField -Identity ArtefactType

Add-PnPField -Web $webRoot -InternalName DepartmentName -DisplayName "Department Name" -Required `
                    -Type Text -Group "PnP-Demo" -ErrorAction SilentlyContinue
$fieldDepName = Get-PnPField -Identity DepartmentName

Add-PnPField -Web $webRoot -InternalName Processed -DisplayName "Processed" -Required `
                    -Type Boolean -Group "PnP-Demo" -ErrorAction SilentlyContinue
$fieldProcessed = Get-PnPField -Identity Processed
$fieldProcessed.DefaultValue = 0
$fieldProcessed.Update()

# Add Content Type
#Get-Help -Name Add-PnPContentType -Examples
Add-PnPContentType -Name "List self-service CT" -Web $webRoot -Group "Pnp-Demo" -ErrorAction SilentlyContinue
$ctypeLstSS = Get-PnPContentType "List self-service CT" -Web $webRoot
Add-PnPFieldToContentType -Web $webRoot -Field $fieldArtefact.Id -ContentType $ctypeLstSS -Required
Add-PnPFieldToContentType -Web $webRoot -Field $fieldDepName.Id -ContentType $ctypeLstSS -Required
Add-PnPFieldToContentType -Web $webRoot -Field $fieldProcessed.Id -ContentType $ctypeLstSS
$fieldTitle = Get-PnPField -Identity "Title" -Web $web
#Remove-PnPFieldFromContentType -Field $fieldTitle.Id -ContentType $ctypeLstSS
#$ctypeLstSS.FieldLinks

# Add new list with ctype
New-PnPList -Title "List Self-Service" -OnQuickLaunch -Web $webRoot -Template GenericList `
            -Url "Lists/ListSelfService" -ErrorAction SilentlyContinue
$list = Get-PnPList -Identity "List Self-Service"
$list.ContentTypesEnabled = $true
$list.EnableAttachments = $false
$list.Update()
Add-PnPContentTypeToList -Web $webRoot -List "List Self-Service" -ContentType "List self-service CT"
Remove-PnPContentTypeFromList -Web $webRoot -List "List Self-Service" -ContentType Item

# Hide Processed field from new/edit forms
$f = Get-PnPField -Web $webRoot -List $list.Id -Identity $fieldProcessed.Id
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
    -Fields $fieldArtefact.InternalName,$fieldDepName.InternalName,$fieldProcessed.InternalName `
    -ErrorAction SilentlyContinue