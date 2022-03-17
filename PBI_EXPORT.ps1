#parameters
param(
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$sourceWorkSpaceName,
 
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
$artifactPath,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$Password,
 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$Username
)
 
 
try{
    #Connecting Power BI with Master Use
    $password = $Password | ConvertTo-SecureString -asPlainText -Force
    $username = $Username
    $credential = New-Object System.Management.Automation.PSCredential($username, $password)
    Connect-PowerBIServiceAccount -Credential $credential
 
    #Connecting PowerBI SPN
    #$clientSec = "$client_secret" | ConvertTo-SecureString -AsPlainText -Force
    #$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $clientSec
    #Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credentials -TenantId $tenantId
 
        Write-Host "Exporting: " $reportName
 
        #Getting the Workspace Name from $sourceWorkSpaceName imput Parameter
        $sourceWorkSpace = Get-PowerBIWorkspace -Name $sourceWorkSpaceName
 
        #Getting the Report Id from $reportName input Parameter
        $powerBIReport = Get-PowerBIReport -Name $reportName -WorkspaceId $sourceWorkSpace.id
 
        if (!$sourceWorkSpace) { Write-Host "sourceWorkSpace is null" break }
        if (!$powerBIReport) { Write-Host "powerBIReport is null" break}
        #Performing PBI Report Export and keeping in Artifact Path
        $pbiFile = Export-PowerBIReport -Id $powerBIReport.Id -WorkspaceId $sourceWorkSpace.id -OutFile $artifactPath/$reportName.pbix
}catch
    {
        Write-Host $_.Exception.Message
        Resolve-PowerBIError
        exit
    }