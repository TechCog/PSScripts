<#
.Synopsis
  Script to get details of MFA enabled users.

.DESCRIPTION
 This script can be used to get details of MFA enabled users

. NOTES
   Author Subodh Uniyal <TechCognizance@outlook.com>

. Disclaimer: Author holds no responsibility to damages caused due to incorrect use of this script.
  It is recommended that you run this script in  your lab before using in production.

.EXAMPLE
This example will give MFA details of supplied UPN "User@domain.com"

   Get-MFAUserDetails -UPN User@domain.com

.EXAMPLE
This example will give MFA details of users supplied in "MFAUPN.txt" file, one UPN per line, without any header. 

 Get-MFAUserDetails -UserList C:\temp\MFAUPN.txt

 .EXAMPLE
This example will give MFA details of ALL Users enabled for MFA in your Microsoft 365 environment. 

 Get-MFAUserDetails -All

#>

    Param
    (
        
        [Parameter(ValueFromPipeline=$true)]
                   [String[]]$UserList,
                   [String]$UPN,
                   [String[]]$All
    )

#Connect to MSOL
Write-Host "Checking Current MsolService Session"
try {
    Get-MsolDomain -ErrorAction Stop | Out-Null
} catch {
Write-Host "No current session detected. Please supply credentials to connect to Microsoft Online Service"
Connect-MsolService

}

try
{
    Get-MsolDomain -ErrorAction Stop > $null
}
catch 
{
    if ($cred -eq $null) {$cred = Get-Credential $O365Adminuser}
    Write-Output "Connecting to Office 365..."
    Connect-MsolService -Credential $cred
}


$Result = @()
$Results = @()
$reportPath = ".\"
$ReportName = "MFAReport_$(get-date -format dd-MM-yyyy_hh-mm-ss).CSV"
$MFAReport = $reportPath + $reportName


Function Get-MFAUserDetails
{
$Result = @()
$Results = @()
Foreach ($User in $List)
{

Write-Host "Processing user "$User.DisplayName""
    $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
    $StrongAuthenticationUserDetails = $User | Select-Object -ExpandProperty StrongAuthenticationUserDetails
    $StrongAuthenticationMethods = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

$Result = [PSCustomObject]@{
DisplayName = $User.DisplayName
UPN = $User.UserPrincipalName
IsLicensed = $User.IsLicensed
RememberDevicesNotIssuedBefore = $StrongAuthenticationRequirements.RememberDevicesNotIssuedBefore
StrongAuthenticationUserDetailsPhoneNumber = $StrongAuthenticationUserDetails.PhoneNumber
StrongAuthenticationUserDetailsEmail = $StrongAuthenticationUserDetails.Email
DefaultStrongAuthenticationMethodType = ($StrongAuthenticationMethods | Where {$_.IsDefault -eq $True}).MethodType
}
$Results +=$Result
}
$Results | ft
$Results | Export-Csv $MFAReport -NoTypeInformation
$Location = (Get-Location).path + "\" + "$ReportName"
Write-Host "Results are saved in File $Location" -ForegroundColor Yellow
}

 IF ($UserList) 
    {
    $List = Get-Content -Path $UserList | foreach {Get-MsolUser -UserPrincipalName $_}
    Write-Host "Processing with UserList provided, there are "($List).count" users to process."
    
    Get-MFAUserDetails($List)
    }
     ElseIf ($UPN)
       {
       $List = Get-MsolUser -UserPrincipalName $UPN
       Get-MFAUserDetails($List)
       }
        ElseIF ($All)
         {
         $List = Get-Msoluser -all | Where-Object {$_.StrongAuthenticationMethods -like "*"}
         Write-Host "Processing with all users enabled for MFA"
          Get-MFAUserDetails($List)
         }
           Else
           {
           Write-Host "Please input at least one parameter, check help for details."
           }
