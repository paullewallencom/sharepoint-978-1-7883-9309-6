### 1. Install Azure Resource Management module via PowerShellGet
Install-Module AzureRM

### 2. Connect to your Azure portal
Login-AzureRmAccount

### 3. Register/Enable Microsoft.ServiceBus provider for your subscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ServiceBus

### 4. Create resource group, namespace in a specific azure location
$ResGrpName = "RERGroup"
$Namespace = "Oleglearnssp"
$Location = "northeurope"
# Query to see if the namespace currently exists
$CurrentNamespace = Get-AzureRMServiceBusNamespace -ResourceGroup $ResGrpName -NamespaceName $Namespace

# Check if the namespace already exists or needs to be created
if ($CurrentNamespace)
{
    Write-Host "The namespace $Namespace already exists in the $Location region:"
    # Report what was found
    Get-AzureRMServiceBusNamespace -ResourceGroup $ResGrpName -NamespaceName $Namespace
}
else
{
    Write-Host "The $Namespace namespace does not exist."
    Write-Host "Creating the $Namespace namespace in the $Location region..."
    New-AzureRmServiceBusNamespace -ResourceGroup $ResGrpName `
                            -NamespaceName $Namespace -Location $Location
    $CurrentNamespace = Get-AzureRMServiceBusNamespace -ResourceGroup $ResGrpName `
                            -NamespaceName $Namespace
    Write-Host "The $Namespace namespace in Resource Group $ResGrpName in the $Location region has been successfully created."
}