Param (
    [Parameter(Position=1)]
    [string[]]$sites
)

<#

.DESCRIPTION
  Stop IIS Web sites

.USAGE
  .\stopSites.ps1 [<site_name>]
  
.SWITCHES
  /? Displays this help text

.AVAILABLE PARAMETERS
  sites = <site_name>, <site1_name>
  
.OUTPUTS
  Log file stored in C:\Logs\stopSites_yyyyMMdd.log
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  20.03.2018
  Purpose/Change: Deployment procedure

#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\stopSites_$datestamp.log"

Import-Module WebAdministration

try
{	
    foreach($site in $sites)
    {       
        Stop-Website $site
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