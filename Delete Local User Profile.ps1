#Launches the session as the current user + Administrator rights
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

$strUsername = Read-Host -Prompt 'What is the username?'
$comp = hostname
#Displays SID for the above username and deletes it
$objUser = New-Object System.Security.Principal.NTAccount("glidewelllab","$strUsername")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value

#Exports a backup of their user profile registry and saves it to their documents folder
Function RegExport
{
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" C:\Users\$strUsername\Documents\Regbak.reg
}

RegExport

#Function that renames the user profile folder and adds bak + date
Function RenameFile ($location)
{
    $d = Get-Date -uFormat "%Y-%m-%d"

    $old = $location + $strUsername
    $new = $strUsername + "_" + "bak" + "_" + $d

    Rename-Item $old $new -Confirm
}

RenameFile -location "C:\Users\"

#Removes user profile in the registry
Function RegDelete
{
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$strUsername" } | Remove-CimInstance -Confirm
}

RegDelete 
