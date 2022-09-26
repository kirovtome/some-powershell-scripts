Param (
	[Parameter(Position=1)]
	[string]$serverName,
	
    [Parameter(Position=2)]
    [string[]]$databases,
	
	[Parameter(Position=3)]
	[string]$destPath,
	
	[Parameter(Position=4)]
	[string]$user,
	
	[Parameter(Position=5)]
	[string]$pass
)

<#

.DESCRIPTION
  Backup database(s)

.USAGE
  .\backupDBs.ps1 [<serverName>] [<database(s)_name(s)>] [<backup_path>] [<sql_user>] [<sql_user_pass>]

.SWITCHES
  /? Displays this help text

.AVAILABLE PARAMETERS
  serverName = <server_instance>
  databases  = <database(s)_name(s)>
  destPath   = <backup_file_path>
  user       = <sql_user>
  pass       = <sql_user_password>
  
.OUTPUTS
  Log file stored in C:\Logs\backupDatabases_yyyyMMdd.log
  
.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  20.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\backupDatabases_$datestamp.log"

try
{  	
    #Create If not exists the backup directory
    If(!(Test-Path -Path $destPath))
    {
        New-Item -Path $destPath -ItemType directory | Out-Null
    }

    foreach($db in $databases)
    {
		$userPass = ConvertTo-SecureString -String $pass -AsPlainText -Force
		$cred = New-Object Management.Automation.PSCredential -ArgumentList $user, $userPass
		$bkpFile = $destPath + "\" + $db + "_" + $datestamp + ".bak"
		Get-SqlDatabase -ServerInstance $serverName -Credential $cred | Where-Object {$_.Name -eq $db } | Backup-SqlDatabase -BackupFile $bkpFile -Initialize
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