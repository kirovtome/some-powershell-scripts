Param (
    [Parameter(Position=1)]
    $serverName,
	
    [Parameter(Position=2)]
    $database,
	
    [Parameter(Position=3)]
    [string[]]$queries,
	
    [Parameter(Position=4)]
    [string]$user,
	
    [Parameter(Position=5)]
    [string]$pass
)

<#

.DESCRIPTION
  Execute queries on database(s)
  
.USAGE
  .\runQueries_PC.ps1 [<serverName>] [<database_name>] [<query_path>] [<sql_user>] [<sql_user_pass>]
  
.SWITCHES
  /? Displays this help text
  
.AVAILABLE PARAMETERS
  serverName = <server_instance>
  databases  = <database(s)_name(s)>
  queries    = <query_path> <query1_path>
  user       = <sql_user>
  pass       = <sql_user_password>

.OUTPUTS
  Log file stored in C:\Logs\runQueries_yyyyMMdd.log

.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  21.03.2018
  Purpose/Change: Deployment procedure
  
#>


#Create log file for the script
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\runQueries_$datestamp.log"
  
try
{  
	foreach($query in $queries)
	{
		Write-Output "Start executing $query on $serverName\$database..."
		Invoke-Sqlcmd -InputFile $query -ServerInstance $serverName -Database $database -Username $user -Password $pass -Verbose	
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
