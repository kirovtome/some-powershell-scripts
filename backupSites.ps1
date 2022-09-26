Param (
    [Parameter(Position=1)]
    [string[]]$sites,
	
	[Parameter(Position=2)]
	[string]$destPath
)

<#

.DESCRIPTION
  Compress and backup site(s)
  
.USAGE
  .\backupSites.ps1 [<site_name>] [<site1_name>] [<backup_path>]
  
.SWITCHES
  /? Displays this help text
  
.AVAILABLE PARAMETERS
  sites    = <site_name> <site1_name>
  destPath = <backup_file_path>
  
.OUTPUTS
  Log file stored in C:\Logs\backupSites_yyyyMMdd.log
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  20.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\backupSites_$datestamp.log"

#Set alias for 7Zip archive software in order to archive the backups
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"

#Set up the variable(s) for: directories to exclude from backup and the path of the backup files
$dirToExclude=@("Imports","Exports","DataFolders")

Import-Module WebAdministration

try
{
    #Create If not exists the backup directory
    If(!(Test-Path -Path $destPath))
    {
        New-Item -Path $destPath -ItemType directory | Out-Null
    }

    foreach($site in $sites)
    {
		$siteHomeDir = $(Get-Item -Path IIS:\sites\$site).physicalPath
		$files = Get-ChildItem -Path $siteHomeDir -Exclude $dirToExclude
		
		if(!$files)
		{
			Write-Output "Nothing to backup"
			exit 1;
		}
		
		sz a $destPath\$site.zip $files
    }
}

catch [Exception]
{
	#Create If not exists the log file
    If(!(Test-Path -Path $logFile))
    {
        New-Item -Path $logFile -ItemType file | Out-Null
    }
    
    $ErrorMessage = $_.Exception.Message
    "Error: {0}" -f $_.Exception.Message | Out-File $logFile -Append
    Write-Host "There was an error. Please take a look at the log file(s) located at $logFile."
    exit 1;
}

exit 0;