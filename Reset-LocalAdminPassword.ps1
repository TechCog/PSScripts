<#
.Synopsis
  Script to reset password of local administrator on computer(s)

.DESCRIPTION
 This script can be used to reset password of local user account in domain joined or workgroup computers.
 It can also rename the Local administrator according to input provided. input list as txt file is mandatory. 

. NOTES
   Author Subodh Uniyal <TechCognizance@outlook.com>

. Disclaimer: Author holds no responsibility to damages caused due to incorrect use of this script.
  It is recommended that you run this script in  your lab before using in production.

.EXAMPLE

This example will reset the password of account Administrator on computer mentioned in ComputerList.txt

   Reset-LocalAdminPassword -Path C:\ComputerList.txt -AdminAccountName Administrator

.EXAMPLE

This example will reset password of account Administrator and rename it as NewLocalAdmin

 Reset-LocalAdminPassword -Path C:\ComputerList.txt -AdminAccountName Administrator -NewName NEWLocalAdmin
#>

Param (

[Parameter(Mandatory=$True)]
[String]$Path,

[Parameter(Mandatory =$True)]
[String]$AdminAccountName,

[String]$NewName

        )


$List = Get-Content -Path $Path  

$AdminAccountName = $AdminAccountName -replace '(^\s+|\s+$)','' -replace '\s+',' '
$NewName = $NewName -replace '(^\s+|\s+$)','' -replace '\s+',' '

$logFile          =        'Not_Reachable_PCs.txt'
$AccessDeniedPCs  =        'AccessDeniedPCs.txt'


#Getting NEW password

$NewPassword = Read-Host "Please Enter NEW Passowrd for Administrator" -AsSecureString
$NewPassword1 = Read-Host "Re-enter NEW Passowrd for Administrator" -AsSecureString
$pwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword))
$pwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword1))
 
if ($pwd1_text -ceq $pwd2_text) {
Write-Host "Passwords matched"

} else {
Write-Host "Password does not match"
Exit
}

#Getting Current Local Admin Password

$AdminPassword = Read-Host "Please enter passowrd of current local Admin" -AsSecureString
$AdminPassword1 = Read-Host "Re-enter passowrd of current local Admin" -AsSecureString
$pwd11_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
$pwd12_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword1))
 
if ($pwd11_text -ceq $pwd12_text) {
Write-Host  "Passwords matched"

} else {
Write-Host -ForegroundColor Red "Password does not match"
Exit
}


Foreach ($Computer in $List)
{

if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction 0 )
    {
$AdminAccount = "$Computer\$AdminAccountName"

$User = New-Object System.DirectoryServices.DirectoryEntry("WinNT://$Computer/$AdminAccountName",$AdminAccount,$pwd11_text)

Try {

$User.psbase.Invoke('SetPassword', $pwd1_text)

Write-Verbose "Password of $AdminAccountName has been set on $Computer"

if ($NewName)
{$User.psbase.rename($NewName)
Write-Verbose "$AdminAccountName has renamed to $NewName on $Computer"

}


}

catch {

$ErrorMessage = $_.Exception.Message
$FailedItem = $_.Exception.ItemName

Out-File -FilePath $AccessDeniedPCs   -InputObject $Computer -Append -Force
Out-File -FilePath $AccessDeniedPCs   -InputObject $ErrorMessage -Append -Force
Out-File -FilePath $AccessDeniedPCs   -InputObject $FailedItem -Append -Force }

  }          
else 

    {
    Out-File -FilePath $logFile  -InputObject $Computer -Append -Force
    }
    
 }

