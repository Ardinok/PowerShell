$Computers = 'glfxd3scad05'
ForEach ($Computer in $Computers) {
        #Install driver
        Add-PrinterDriver -Name "Dell Color MFP S3845cdn PCL6" -Verbose
        #Add Ports
        Add-PrinterPort -Name "IP_10.3.2.30" -PrinterHostAddress "10.3.2.30" -ComputerName $Computer -Verbose
        #Add Printers
        Add-Printer -ComputerName $Computer -name "GLFXDCPS03" -PortName "IP_10.3.2.30" -DriverName "Dell Color MFP S3845cdn PCL6"
}