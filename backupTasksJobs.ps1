Param (
    [Parameter(Mandatory=$True,Position=1)]
    [validateset("tasks","jobs")]
    [string[]]$backupType,
	
	[Parameter(Mandatory=$True,Position=2)]
    [string]$backupLoc
)

<#

.DESCRIPTION
  Backup scheduled tasks/jobs on the Backup Server

.USAGE
  .\backupDBs.ps1 [<backup_type>] [<backup_location>] 

.SWITCHES
  /? Displays this help text

.AVAILABLE PARAMETERS
  backupType  = tasks,jobs
  backupLoc   = <backup_location>
  
.OUTPUTS
  Log file stored in C:\Logs\backupTasksJobs_yyyyMMdd.log

.NOTES
  Version:        1.0
  Author:         Tome Kirov
  Creation Date:  31.05.2017
  Purpose/Change: Backup procedure

#>


#Create log file
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$logFile = "C:\Logs\backupTasksJobs_$datestamp.log"

#Set account and backup location variables
$backupTasksPath = "$($backupLoc)\scheduledTasks\$env:computername"
$backupJobsPath = "$($backupLoc)\scheduledSQLJobs\$env:computername"

#Backup Windows Scheduled Tasks function
function backupTasks
{
    try
        {
            #If the backup directory for scheduled tasks backups does not exist, create it
            if( -Not(Test-Path $backupTasksPath))
            {
                New-Item $backupTasksPath -ItemType directory
            }

            #Export all scheduled tasks
            Get-ScheduledTask | Where-Object { $_.TaskPath -like "\" } | foreach {
            Export-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath |
            Out-File (Join-Path $backupTasksPath "$($_.TaskName).xml")
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
			Write-Host "There was an error. Please take a look at the log file(s) located at $logFile ."
			exit 1;  
        }			
}


#Backup SQL Jobs function
function backupSQLJobs
{
    try
    {
		#If the backup directory for scheduled sql jobs does not exist, create it
        if( -Not(Test-Path $backupJobsPath))
        {
            New-Item $backupJobsPath -ItemType directory
        }

        Import-Module SQLPS -DisableNameChecking

        $Server = new-object microsoft.sqlserver.management.smo.server $env:COMPUTERNAME
        $Jobs = $Server.JobServer;
        foreach($job in $Jobs.Jobs) {
        $job.script() | Out-File $backupJobsPath\$job.sql UTF8
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
		Write-Host "There was an error. Please take a look at the log file(s) located at $logFile ."
		exit 1;
    } 
}

#Execute functions
foreach($arg in $backupType)
{
	if($arg -eq "tasks")
	{
		backupTasks
	}
	
	if($arg -eq "jobs")
	{
		backupSQLJobs
	}
}

exit 0;