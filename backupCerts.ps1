Param (
    [Parameter(Mandatory=$True,Position=1)]
    [string]$logPath,

    [Parameter(Mandatory=$True,Position=2)]
    [string]$backupLoc,

    [Parameter(Mandatory=$True,Position=3)]
    [string[]]$certPath
)

<#

.DESCRIPTION
  Backup certificates on the Backup Server

.PARAMETER logPath
    The path for the log file

.PARAMETER backupLoc
    Backup location path for the scheduled tasks, jobs

.PARAMETER certPath
    Path where the certificate is located

.NOTES
  Version:        1.1
  Author:         Tome Kirov
  Creation Date:  31.05.2017
  Purpose/Change: Backup procedure
  
.EXAMPLE
  .\backupCerts.ps1 -logPath "C:\logs" - backupLoc "C:\backups" -certPath "Cert:\LocalMachine\My\<SOME_CERT_NAME_HERE>"

#>


#Create log file
$datestamp = (Get-Date).Date.ToString("yyyyMMdd")
$TranscriptFileName = "$($logPath)\backup_$($env:computername)_CertsToAccServer_$datestamp.log"
Start-Transcript -Path $TranscriptFileName -Append

#Get certificate files
$certs = Get-ChildItem -Path $certPath

#function that export certificates
function exportCerts
{
    try
    {
        #If the backup directory for certificates does not exist, create it
        if( -Not(Test-Path $backupLoc))
        {
            New-Item $backupLoc -ItemType directory
        }

        foreach($cert in $certs)
        {
            #Export certificate
            Export-Certificate -Cert $cert -Type P7B -FilePath $backupLoc\$($cert.FriendlyName)_$timestamp.p7b
        }
		
    }

    catch [Exception]
    {
        $ErrorMessage = $_.Exception.Message
        Write-Host ("Error: {0}" -f $_.Exception.Message)
        Send-MailMessage -From <> -To <> -Subject "Cannot backup certificates on the $($env:computername) server!" -SmtpServer localhost -Body "The error message was: $ErrorMessage."
        exit 1;    
    }
    
}

#Export certificates
exportCerts

exit 0;

Stop-Transcript