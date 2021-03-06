import-module ActiveDirectory

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
#Get Distinguished Name
$filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$cname))"
$distName = ([adsisearcher]$filter).FindOne().Properties.distinguishedname

if(!$distName){
    $shell.popup("The computer $cname does not exsist within Active Directory.  Press Ok to Continue",0,"Machine Does Not Exist within Active Directory",0+48)}
else{
    $AdminCredentials = Get-Credential "win\"
    Remove-ADComputer -Identity "$distName" -AuthType Negotiate -Credential $AdminCredentials -Server "win.brockport.edu" -Confirm}