# Environment setup 
# Import the ActiveDirectory module to enable the Get-ADComputer CmdLet 
Import-Module ActiveDirectory

# Variables
$shell = new-object -comobject "WScript.Shell"

#$ErrorActionPreference = "SilentlyContinue"
$ErrorActionPreference = "Continue"
$result = 0

while($result -ne 6){
$cname = Read-Host "Enter desired computer name:"
$cname = $cname.toupper()
$shell = new-object -comobject "WScript.Shell"

# VBScrit code: 6 is Yes; 7 is No
$result = $shell.popup("The computer name you entered is: $cname. Is this correct?",0,"Confirm Machine:  $cname",4+32)
}
 
$SCCMServer = "sccm.win.brockport.edu" 
$sitename = "BRO" 

# Get the resourceID from SCCM 
$resID = Get-WmiObject -computername $SCCMServer -query "select resourceID from sms_r_system where name like `'$cname`'" -Namespace "root\sms\site_$sitename" 
$computerID = $resID.ResourceID 
if ($resID.ResourceId -eq $null) { 
        $msgboxValue = "No SCCM record for that computer"
        $shell.popup("No SCCM record for computer $cname exist.",0,"SCCM Machine Not Detected",0+64)} 
    else { 
        $comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)"  
        # Output to screen 
        # Delete the computer account 
        $comp.psbase.delete()
        #$shell.popup("$cname with resourceID $computerID will be deleted",0,"SCCM Machine Deleted",0+64)
        $resID = Get-WmiObject -computername $SCCMServer -query "select resourceID from sms_r_system where name like `'$cname`'" -Namespace "root\sms\site_$sitename" 
        $computerID = $resID.ResourceID
        if(!$resID.ResourceID){
        $shell.popup("$cname was successfully deleted from System Center Configuration Manager.",0,"SCCM Machine Deleted",0+64)} 
}