#Launches the session as the current user + Administrator rights
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

$strUsername = Read-Host -Prompt 'What is the username?'

#Exports a backup of their user profile registry and saves it to their documents folder

Write-Output "$strUsername"

reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" C:\Users\$strUsername\Documents\Regbak.reg

Write-Output "Profile registry key backed up to C:\users\$strUsername\Documents\regbak.reg."

#Function that renames the user profile folder and adds bak + date
Function RenameFile ($location)
 {   
    $d = Get-Date -uFormat "%Y-%m-%d"

    $old = $location + $strUsername
    $new = $strUsername + "_" + "bak" + "_" + $d

    Rename-Item $old $new -Confirm
 }

RenameFile -location "C:\Users\"

Write-Output "User profile has been renamed."

#Removes user profile in the registry

Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$strUsername" } | Remove-CimInstance -Confirm

Write-Output "User profile has been deleted in the registry." 

Pause