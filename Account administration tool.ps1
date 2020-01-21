Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Global:usrname = $null
$Global:enDer =  ''
$Global:dc = Get-ADDomainController -Discover | select -ExpandProperty name

#region begin GUI{ 

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "User account administration"
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
$Button1.Text = "Check"
$Button1.AutoSize = $True
$Button1.Location = New-Object System.Drawing.Size(300,25)
$Button1.add_click({$global:usrname= $textbox1.text;get-userdetailz $global:usrname})

$ButtonUnlock = New-Object System.Windows.Forms.Button
#button text is generated in the userdetails function during $lckout variable creation
$ButtonUnlock.AutoSize = $True
$ButtonUnlock.Location = New-Object System.Drawing.Size(300,50)
$ButtonUnlock.BackColor = "green"
$ButtonUnlock.add_click({UnlockAccount $Global:usrname})

$ButtonLockAcc = New-Object System.Windows.Forms.Button
$ButtonLockAcc.AutoSize = $True
$ButtonLockAcc.Location = New-Object System.Drawing.Size(300,50)
$ButtonLockAcc.BackColor = "red"
$ButtonLockAcc.add_click({LockAccount $Global:usrname})

$ButtonReset = New-Object System.Windows.Forms.Button
$ButtonReset.AutoSize = $True
$ButtonReset.Location = New-Object System.Drawing.Size(300,75)
$ButtonReset.Text = "Reset"
$ButtonReset.add_click({ClearForm;MainForm})

$ButtonSetPSW = New-Object System.Windows.Forms.Button
$ButtonSetPSW.AutoSize = $True
$ButtonSetPSW.Location = New-Object System.Drawing.Size(300,100)
$ButtonSetPSW.Text = "SetPSW"
$ButtonSetPSW.add_click({SetPSW $Global:usrname})

$Provide1 = New-Object System.Windows.Forms.Label
$Provide1.Text = "Type Password"
$Provide1.AutoSize = $True
$Provide1.Location = New-Object System.Drawing.Size(15,10)

$Provide2 = New-Object System.Windows.Forms.Label
$Provide2.Text = "Type it again"
$Provide2.AutoSize = $True
$Provide2.Location = New-Object System.Drawing.Size(15,60)

$Inpu1                        = New-Object System.Windows.Forms.TextBox
$Inpu1.PasswordChar = '*'
$Inpu1.multiline              = $false
$Inpu1.width                  = 120
$Inpu1.height                 = 20
$Inpu1.location               = New-Object System.Drawing.Size(15,35)
$Inpu1.Font                   = 'Microsoft Sans Serif,10'

$Inpu2                        = New-Object System.Windows.Forms.TextBox
$Inpu2.PasswordChar = '*'
$Inpu2.multiline              = $false
$Inpu2.width                  = 120
$Inpu2.height                 = 20
$Inpu2.location               = New-Object System.Drawing.Size(15,85)
$Inpu2.Font                   = 'Microsoft Sans Serif,10'

$ButtonExecSetPSW = New-Object System.Windows.Forms.Button
$ButtonExecSetPSW.AutoSize = $True
$ButtonExecSetPSW.Location = New-Object System.Drawing.Size(300,100)
$ButtonExecSetPSW.Text = "Confirm"
$ButtonExecSetPSW.add_click({InnerSetPSW})



#-----Functions------

function SetPSW ($usrname){
ClearForm
$Global:enDer =  'innersetpsw'
$form.Controls.Addrange(@($Provide1,$Provide2,$Inpu1,$Inpu2,$ButtonExecSetPSW))
$ERR = $false
}

Function InnerSetPSW {
if (![string]::IsNullOrWhiteSpace($Inpu1.Text)) {
Write-Host "NOT NULL"

if ($Inpu1.Text -eq $Inpu2.Text)  {
Write-Host "A match!"
$PSW = $Inpu1.Text | ConvertTo-SecureString -AsPlainText -Force
try {
Set-ADAccountPassword -Identity $usrname -NewPassword $PSW -Reset
}
catch  {
$Status.Text = $_.exception.message
$ERR = $true
}
if (!$ERR) {
ClearForm
$Inpu1.Text,$Inpu2.Text = $null
$Status.ForeColor= "green"
$Status.Text = "$usrname Password reset successfull"
$Global:enDer =  'clearform;mainform'
$form.Controls.Add($ButtonReset)
}


}

else {
$Status.ForeColor= "red"
$Status.Text="No mach! Try again"
}
$form.Controls.Add($Status)
}
else {Write-Host "NULL";$status.text="NULL is not COOL";$Status.ForeColor="red";$form.controls.add($status)}
}

function ClearForm {
$form.Controls.Remove($TextBox1)
$form.Controls.Remove($Button1)
$form.Controls.Remove($Status)
$form.Controls.Remove($ShowDetails)
$form.Controls.Remove($Label1)
$form.Controls.Remove($ButtonReset)
$form.Controls.Remove($buttonSetPSW)
$form.Controls.Remove($ButtonLockAcc)
$form.Controls.Remove($ButtonUnlock)
$form.Controls.Remove($ButtonExecSetPSW)
$form.Controls.Remove($Provide1)
$form.Controls.Remove($Provide2)
$form.Controls.Remove($Inpu1)
$form.Controls.Remove($Inpu2)
$Status.Text=$null
$textbox1.text=$null
$ShowDetails.text=$null
}

function up-status ($meggase) {
$form.Controls.Remove($Status)
$Status.Text = $meggase
$form.Controls.Add($Status)
}

function get-userdetailz ($usrname){
$Status.Text=$null
$ShowDetails.text=$null
$form.Controls.Remove($ButtonUnlock)
$form.Controls.Remove($ButtonLockAcc)
$usrexist = Get-ADUser -Filter {samaccountname -eq $usrname}
if ($usrexist -eq $null) {$Status.ForeColor= "red" ; $Status.Text="User "+$Global:usrname+" not found"} else {
#Added description
$UserDetails = Get-ADUser -filter "samaccountname -eq '$Global:usrname'" –Properties “DisplayName”,"enabled","PasswordNeverExpires", “msDS-UserPasswordExpiryTimeComputed”,"emailaddress","lockedout","Description" | Select-Object -Property “Displayname”,"enabled","PasswordNeverExpires","emailaddress","lockedout",@{Name=“ExpiryDate”;Expression={[datetime]::FromFileTime($_.“msDS-UserPasswordExpiryTimeComputed”)}}, "Description"
$dspln = $UserDetails.Displayname
$enbld = if ($UserDetails.enabled -eq $true) {"Yes"} else {"No"}
$pswne = if ($UserDetails.PasswordNeverExpires -eq $true) {"Never"} else {"Yes"}
$emailadd = $UserDetails.emailaddress
$lckdout = if ($UserDetails.lockedout -eq $true) {"Yes";$ButtonUnlock.text = ("Unlock "+$Global:usrname);$Form.Controls.Add($ButtonUnlock)} else {"No"; $ButtonLockAcc.text = ("Lock "+$Global:usrname);$form.Controls.Add($ButtonLockAcc)}
$pswexp = $UserDetails.ExpiryDate
#Added description for Tech ID
$desc = $UserDetails.Description
#End of addition
#Called for description variable to display; +"Tech ID: "+$desc
$ShowDetails.Text="Displayname: "+$dspln+"`n"+"Enabled? : "+$enbld+"`n"+"Account Locked? : "+$lckdout+"`n"+"PSW Expires? :"+$pswne+"`n"+"PSW Expiration date: "+$pswexp+"`n"+"Email Address: "+$emailadd+"`n"+"Tech ID: "+$desc
$form.Controls.Add($ButtonSetPSW)
}}

function UnlockAccount ($usrname){
Unlock-ADAccount -Identity $usrname
$form.Controls.Remove($ButtonUnlock)
get-userdetailz $usrname
$Status.ForeColor= "green"
$Status.Text = "Unlocked "+$usrname

}

function LockAccount ($usrname) {
$Password = ConvertTo-SecureString 'NotMyPassword' -AsPlainText -Force
Do {
Invoke-Command -ComputerName $dc {Get-Process} -Credential (New-Object System.Management.Automation.PSCredential ($Global:usrname, $Password)) -ErrorAction SilentlyContinue}
Until ((Get-ADUser -Identity $Global:usrname -Properties LockedOut).LockedOut)
$form.Controls.Remove($ButtonLockAcc)
get-userdetailz $usrname
$Status.ForeColor= "red"
$Status.Text = "Locked "+$usrname
}

function MainForm (){
$Global:enDer =  '$global:usrname= $textbox1.text;get-userdetailz $global:usrname'
$form.Controls.Addrange(@($TextBox1,$Label1,$Button1,$Status,$ShowDetails,$ButtonReset))

}

MainForm

[void]$Form.ShowDialog()