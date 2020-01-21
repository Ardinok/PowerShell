#Variables

$computername = "FDDS10"

$sourcefile = "C:\Temp\CPAgent_Lab.msi"

#This section will install the software 

foreach ($computer in $computername) 

{

$destinationFolder = "\\$computer\C$\Program Files\Glidewell Laboratories"

#This section will copy the $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.

if (!(Test-Path -path $destinationFolder))

{

New-Item $destinationFolder -Type Directory

}

Copy-Item -Path $sourcefile -Destination $destinationFolder

Invoke-Command -ComputerName $computer -ScriptBlock { & cmd /c "msiexec.exe /i c:\temp\cpagent_lab.msi" /qn ADVANCED_OPTIONS=1 CHANNEL=100}

}