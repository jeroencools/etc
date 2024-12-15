# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Define variables
$localPath = "ENTER PATH"
$ftpHost = "ENTER HOST"
$remotePath = "ENTER PATH"

# Prompt for username and password
$ftpUsername = Read-Host "Enter FTP username"
$ftpPassword = Read-Host "Enter FTP password" -AsSecureString

# Sync local folder to a temporary folder
$tempPath = "C:\Temp\secondbrain"
Robocopy $localPath $tempPath /MIR

# Create WinSCP session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = $ftpHost
    UserName = $ftpUsername
    Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ftpPassword))
}

# Create session and set executable path
$session = New-Object WinSCP.Session
$session.ExecutablePath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"

try {
    $session.Open($sessionOptions)
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

    $session.PutFiles("$tempPath\*", $remotePath, $False, $transferOptions).Check()
}
finally {
    $session.Dispose()
}

# Clean up temporary folder
Remove-Item -Recurse -Force $tempPath