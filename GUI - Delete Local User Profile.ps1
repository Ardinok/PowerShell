Add-Type -AssemblyName PresentationFramework

Function Get-UserProfile {
    [CmdletBinding()]
    #This param() block indicates the start of parameters declaration
    param (
        <#
            This parameter accepts the name of the target computer.
            It is also set to mandatory so that the function does not execute without specifying the value.
        #>
        [Parameter(Mandatory)]
        [string]$strUsername
    )
    <#
        Command gets SID and translates it to SID registry value.
    #>
    $objUser = New-Object System.Security.Principal.NTAccount("glidewelllab","$strUsername")
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
   $strSID
}

#Where is the XAML file?
$xamlFile = "C:\Users\brian.gee\source\repos\DiskGUI-sample\DiskGUI-sample\MainWindow.xaml"

#Create window
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
	$window = [Windows.Markup.XamlReader]::Load( $reader)
} catch {
	Write-Warning $_.Exception
	throw
}

#Create variables based on form control names.
#Variable will be named as 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
	try {
		Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
	} catch {
		throw
	}
}
Get-Variable var_*

$var_btnQuery.Add_Click( {
	#clear the result box
    $result = Get-Userprofile $var_txtstrUsername.Text
	$var_txtResults.Text = "SID: $($strSID.Value)"
	})


$Null = $window.ShowDialog()