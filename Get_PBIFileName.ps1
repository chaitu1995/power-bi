#Parameters
param(
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$reportImportPath
)
 
try{
foreach($file in Get-ChildItem -Path $reportImportPath)
{
    Write-Host "FileName" $file.Name
    if($file.Name.EndsWith(".pbix"))
    {
        $uniqueNameUntrimmed=$file.Name
        $uniqueName =$uniqueNameUntrimmed.Trim(".pbix")
        Write-Host "Trimmed Name UniqueName" $uniqueName
        "##vso[task.setvariable variable=reportName;]$uniqueName"
        "##vso[task.setvariable variable=datasetname;]$uniqueName"
        break;
    }else
    {
        Write-Host "PBI File doesn't exist"
    }
}
}catch
    {
        Write-Host $_.Exception.Message
        exit
    }