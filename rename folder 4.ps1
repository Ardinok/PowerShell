#Launches the session as the current user + Administrator rights
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Global:usrname = $null
$Global:enDer =  ''
$Global:dc = Get-ADDomainController -Discover | select -ExpandProperty name


#GUI settings

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Backup and remove local profile"
$Form.TopMost                    = $false
$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter") {Invoke-Expression $Global:enDer}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 120
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(15,25)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Type Username Below"
$Label1.AutoSize = $True
$Label1.Location = New-Object System.Drawing.Size(15,10)

$ShowDetails = New-Object System.Windows.Forms.Label
$ShowDetails.AutoSize = $True
$ShowDetails.Location = New-Object System.Drawing.Size(15,50)

$Status = New-Object System.Windows.Forms.Label
$Status.font = 'Microsoft Sans Serif,14'
$Status.AutoSize = $True
$Status.Location = New-Object System.Drawing.Size(15,360)
$Status.ForeColor = "red"

$Button1 = New-Object System.Windows.Forms.Button
$Button1.Text = "Submit"
$Button1.AutoSize = $True
$Button1.Location = New-Object System.Drawing.Size(300,25)
$Button1.add_click({$global:usrname= $textbox1.text;get-userdetailz $global:usrname})

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

    $old = $location + $global:usrname
    $new = $global:usrname + "_" + "bak" + "_" + $d

    Rename-Item $old $new
}


#Function that removes user profile in the registry
Function RegDelete
{
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$global:usrname" } | Remove-CimInstance
}

#Textbox button
$btnSubmit.Add_Click(
{
#Defines user profile that you're renaming
$global:usrname = $tbxProfileName.Text
# 3. Determine which GUID matches $tbxProfileName in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
## for each parse ProfileImagePath to match C:\Users\($tbxProfileName)
## HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid 
## for each parse SidString to match ProfileImagePath.
## remove ProfileGuid entry and remove ProfileList entry

#Obtains SID for user name, displays it, and then prompts to delete it
$objUser = New-Object System.Security.Principal.NTAccount("glidewelllab","$global:usrname")
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