Param (
    [Parameter(Position=1)]
	[string]$serverName,
	
    [Parameter(Position=2)]
    [string]$database,
	
	[Parameter(Position=3)]
	[string]$bkpPath,
	
	[Parameter(Position=4)]
	[string]$user,
	
	[Parameter(Position=5)]
	[string]$pass
)

<#

.DESCRIPTION
  Restore database

.USAGE
  .\restoreDBs.ps1 [<serverName>] [<database_name>] [<backup_path>] [<sql_user>] [<sql_user_pass>]
  
.SWITCHES
  /? Displays this help text
  
.AVAILABLE PARAMETERS
  serverName = <server_instance>
  database   = <database_name>
  bkpPath    = <backup_file_path>
  user       = <sql_user>
  pass       = <sql_user_password>
  
.OUTPUTS
  Log file stored in C:\Logs\restoreDatabases_yyyyMMdd.log  
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  21.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\restoreDatabases_$datestamp.log"

try
{  
    Invoke-Sqlcmd -ServerInstance $serverName -Username $user -Password $pass -Query "ALTER DATABASE $database SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
    Invoke-Sqlcmd -ServerInstance $serverName -Username $user -Password $pass -Query "RESTORE DATABASE $database FROM DISK='$bkpPath' WITH REPLACE,RECOVERY" -QueryTimeout 600
    Invoke-Sqlcmd -ServerInstance $serverName -Username $user -Password $pass -Query "ALTER DATABASE $database SET MULTI_USER WITH ROLLBACK IMMEDIATE"
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
    Write-Host "There was an error. Please take a look at the log file(s) located at $logFile ."
    exit 1;
}

exit 0;