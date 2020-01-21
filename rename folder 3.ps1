#Launches the session as the current user + Administrator rights
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}


#GUI settings
Add-Type -AssemblyName System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Backup and Remove Local Windows Profile'
$main_form.Width = 600
$main_form.Height = 200
$main_form.AutoSize = $true

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Profile to Remove"
$lblTitle.Location = New-Object System.Drawing.Point(0,10)
$lblTitle.AutoSize = $true
$main_form.Controls.Add($lblTitle)

$tbxProfileName = New-Object System.Windows.Forms.TextBox
$tbxProfileName.Width = 150
$tbxProfileName.Multiline = $false
$tbxProfileName.Location = New-Object System.Drawing.Point(150,10)
$main_form.Controls.Add($tbxProfileName)

$btnSubmit = New-Object System.Windows.Forms.Button
$btnSubmit.Location = New-Object System.Drawing.Size(400,10)
$btnSubmit.Size = New-Object System.Drawing.Size(120,23)
$btnSubmit.Text = "Submit"
$main_form.Controls.Add($btnSubmit)


#Exports a backup of their user profile registry and saves it to their documents folder
Function RegExport
{
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" C:\Users\$strUsername\Documents\Regbak.reg
}


#Function that renames the user profile folder and adds bak + date
Function RenameFile ($location)
{
    $d = Get-Date -uFormat "%Y-%m-%d"

    $old = $location + $strUsername
    $new = $strUsername + "_" + "bak" + "_" + $d

    Rename-Item $old $new
}


#Function that removes user profile in the registry
Function RegDelete
{
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$strUsername" } | Remove-CimInstance
}

#Textbox button
$btnSubmit.Add_Click(
{
#Defines user profile that you're renaming
$strUsername = $tbxProfileName.Text
# 3. Determine which GUID matches $tbxProfileName in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
## for each parse ProfileImagePath to match C:\Users\($tbxProfileName)
## HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid 
## for each parse SidString to match ProfileImagePath.
## remove ProfileGuid entry and remove ProfileList entry

#Obtains SID for user name, displays it, and then prompts to delete it
$objUser = New-Object System.Security.Principal.NTAccount("glidewelllab","$strUsername")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
RegExport
Rename-Item -location "C:\Users\" -Confirm
RegDelete -Confirm
}
)



##Must be at the end of the script
$main_form.ShowDialog()
##################################