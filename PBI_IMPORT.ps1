#parameters
param(
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$datasetname,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$targetWorkSpaceName,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$client_secret,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$clientId,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$tenantId,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$reportName,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$ParameterURL,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$artifactPath,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$Password,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$Username
)
 
#Function to get Dataset Id
#Input Prameters: WorkspaceId and DatasetName
Function getDataSetId
{
  [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            $workSpaceId,
 
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            $datasetName
        )
 
 
  $datasetid = $null;
 
  try{
    #Get Datasets
    $datasetResponse = Invoke-PowerBIRestMethod -Url "groups/$($workSpaceId)/datasets" -Method Get | ConvertFrom-Json
 
    #Get Specific Dataset
    $datasets = $datasetResponse.value
 
    foreach($dataset in $datasets){
            if($dataset.name -eq $datasetName){
            $datasetid=$dataset.id;
            return $datasetId
        }
    }
  }catch{
        Write-Host "Exception in getDataSetId" $_.Exception.Message
        Resolve-PowerBIError
        exit
    }
}
 
#Power BI Import Process - Insert/Update
 
 
try{
    #Connecting Power BI with Master User
    $password = $Password | ConvertTo-SecureString -asPlainText -Force
    $username = $Username
    $credential = New-Object System.Management.Automation.PSCredential($username, $password)
    Connect-PowerBIServiceAccount -Credential $credential
 
    #Connecting PowerBI SPN2
    #$clientSec = "$client_secret" | ConvertTo-SecureString -AsPlainText -Force
    #$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $clientSec
    #Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credentials -TenantId $tenantId
 
    #Getting Target WorkSpace
    $targetWorkSpace = Get-PowerBIWorkspace -Name $targetWorkSpaceName
    if (!$targetWorkSpace) { Write-Host "targetWorkSpace is null" break }
 
    #Importing(Upsert) PowerBI Report from Artifact path to Target Workspace
    New-PowerBIReport -Path $artifactPath/$reportName.pbix -Name $reportName -Workspace ( Get-PowerBIWorkspace -Name $targetWorkSpaceName ) -ConflictAction "CreateOrOverwrite"
 
    #Getting Target DatasetId
    $targetdatasetId = getDataSetId -workSpaceId $targetWorkSpace.id -datasetName $datasetname
    if (!$targetdatasetId) { Write-Host "targetdatasetId is null" break }
 
    #Performing Takeover
    Invoke-PowerBIRestMethod -Url "groups/$($targetWorkSpace.id)/datasets/$($targetdatasetId)/Default.TakeOver" -Method Post -Body ""
 
$json = @"
{
    "updateDetails": [
            {
            "name": "ParameterURL",
            "newValue": "$ParameterURL"
            }
        ]
}
"@
    # Updating Datasource parameter value
    Invoke-PowerBIRestMethod -Url "groups/$($targetWorkSpace.id)/datasets/$($targetdatasetId)/UpdateParameters" -Method Post -Body $json -Verbose
 
    #Refreshing Dataset
    Invoke-PowerBIRestMethod -Url "groups/$($targetWorkSpace.id)/datasets/$($targetdatasetId)/refreshes" -Method Post -Body ""
 
}catch{
        Write-Host "Exception in Post Deployment Steps " $_.Exception.Message
        Resolve-PowerBIError
        exit
}