#Parameters
param(
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$reportFile,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$user,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$token,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$org,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$project,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$definationId
)
 
try{
    $uri= "https://dev.azure.com/$($org)/$($project)/_apis/build/builds?api-version=5.0"
 
    foreach($reportName in [System.IO.File]::ReadLines($reportFile)){
        if (!$reportName) { Write-Host "reportName is null" break }
        $body = '{
                "definition": {
                    "id": "'+$definationId+'"
                } ,
                "parameters":  "{\"reportName\":\"'
                 
        $body=$body+ $reportName +'\"'+"}"
        $body=$body+ '"'
        $body=$body+'}'
 
        $bodyJson=$body | ConvertFrom-Json
        Write-Output $bodyJson
        $bodyString=$bodyJson | ConvertTo-Json -Depth 100
        Write-Output $bodyString
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))
        $buildresponse = Invoke-RestMethod -Method Post -UseDefaultCredentials -ContentType application/json -Uri $Uri -Body $bodyString -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        write-host $buildresponse
        }
}catch
    {
        Write-Host $_.Exception.Message
        exit
    }