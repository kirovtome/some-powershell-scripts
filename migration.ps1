Param (
    [Parameter(Position=1)]
    [string[]]$sites
)

<#

.DESCRIPTION
  Execute the migration.exe on site(s)
  
.USAGE
  .\migration.ps1 [<site_name>]
  
.SWITCHES
  /? Displays this help text
 
.AVAILABLE PARAMETERS
  sites = <site_name>, <site1_name>
  
.OUTPUTS
  Log file stored in C:\Logs\runMigrations_yyyyMMdd.log
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  21.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\runMigrations_$datestamp.log"

Import-Module WebAdministration

try
{  
    foreach($site in $sites)
    {

		if($site -like "<site1>")
		{ 
				$siteHomeDir = $(Get-Item -Path IIS:\sites\$site).physicalPath
                $arg1 = "<site1>.DataAccessLayer.dll"
                $arg2 = "Configuration"
                $arg3 = "/startUpConfigurationFile:$siteHomeDir\Web.config"
                & "$siteHomeDir\bin\migrate.exe" $arg1 $arg2 $arg3 | Out-Host
        }
        
		if($site -like "<site2>.iborn.net")
		{ 
				$siteHomeDir = $(Get-Item -Path IIS:\sites\$site).physicalPath
                $arg1 = "<site2>.DataAccessLayer.dll"
                $arg2 = "Configuration"
                $arg3 = "/startUpConfigurationFile:$siteHomeDir\Web.config"
                & "$siteHomeDir\bin\migrate.exe" $arg1 $arg2 $arg3 | Out-Host
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
    Write-Host "There was an error. Please take a look at the log file(s) located at $logFile."
    exit 1;
}

exit 0;