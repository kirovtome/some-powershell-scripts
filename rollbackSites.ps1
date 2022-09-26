Param (
    [Parameter(Position=1)]
    [string[]]$sites,
	
	[Parameter(Position=2)]
	[string]$bkpDir
)

<#

.DESCRIPTION
  Extract the backup files into the home directory of site(s)
  
.PARAMETER sites
  Site(s) name
  
.USAGE
  .\rollbackSites [<site_name] [<bkp_Dir>]
  
.SWITCHES
  /? Displays this help text
  
.AVAILABLE PARAMETERS
  sites = <site_name> <site1_name>
  bkpDir = <backup_directory>
 
.OUTPUTS
  Log file stored in C:\Logs\rollbackSites_yyyyMMdd.log
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  20.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\rollbackSites_$datestamp.log"

#Set alias for 7Zip archive software in order to archive the backups
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"

Import-Module WebAdministration

try
{   
    foreach($site in $sites)
    {
	
		If(!(Test-Path -Path $bkpDir\$site.zip))
		{
			Write-Output "The required backup file $bkpDir\$site.zip does not exist!"
			exit 1;
		}
		
		else
		{
			$siteHomeDir = $(Get-Item -Path IIS:\sites\$site).physicalPath
			Write-Output "Start rolling back the $site in $siteHomeDir"
			sz x $bkpDir\$site.zip -o"$siteHomeDir" -aoa
		}
		
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
    Write-Host "There was an error. Please take a look at the log file located at $logFile."
    exit 1;
}

exit 0;