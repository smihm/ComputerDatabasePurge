#**********************************
# SCript Name: purgeMachine.ps1
# Version: 1
# Author: smihm
# Date: 02/11/2014
#
# Description: This script will purge a single computer from SCCM, Sophos, Keyserver, and Acitve Directory.
#
#**********************************
#$ErrorActionPreference = "SilentlyContinue"
$ErrorActionPreference = "Continue"

# Import Modules
import-module ActiveDirectory

# Variables
$result = 0
$SCCMServer = "sccm.win.brockport.edu" 
$sitename = "BRO" 
$shell = new-object -comobject "WScript.Shell"

while($result -ne 6){
$cname = Read-Host "Enter desired computer name:"
$cname = $cname.toupper()


# VBScrit code: 6 is Yes; 7 is No
$result = $shell.popup("The computer name you entered is: $cname. Is this correct?",0,"Confirm Machine:  $cname",4+32)
}

#--------------------------Remove From AD Start------------------------------
#Get Distinguished Name
$filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$cname))"

$distName = ([adsisearcher]$filter).FindOne().Properties.distinguishedname
if(!$distName){
    $shell.popup("The computer $cname does not exsist within Active Directory.  Press Ok to Continue",0,"Machine Does Not Exist within Active Directory",0+48)}
else{
    $AdminCredentials = Get-Credential "win\"
    Remove-ADComputer -Identity "$distName" -AuthType Negotiate -Credential $AdminCredentials -Server "win.brockport.edu" -Confirm}
    
$distName = ([adsisearcher]$filter).FindOne().Properties.distinguishedname
if(!$distName){
    $shell.popup("The computer $cname was successfully removed from Active Directory.  Press Ok to Continue",0,"Machine Does Not Exist within Active Directory",0+64)}
#--------------------------Remove From AD End----------------------------------
#--------------------------Remove From SCCM Start------------------------------
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
#--------------------------Remove From SCCM End------------------------------
#--------------------------Remove From Sophos Start----------------------------
#--------------------------Remove From Sophos End------------------------------
#--------------------------Remove From Key Server Start----------------------------
#--------------------------Remove From Key Server End------------------------------