#######################
<#
.SYNOPSIS
Adds an LDAP entry for use with Oracle LDAP name resolution.
.DESCRIPTION
The add-ldapentry script adds an ldap entry for LDAP Descriptor using the command-line utility ldifde.
.EXAMPLE
./add-ldapentry.ps1 -LDAPDescriptor oradev -ScanAddress orad1-scan -HostName orad1dbadm01,orad1dbadm02 -SID oradev1,oradev2
This command adds oradev LDAP entries: one for scan address, two for HostName/SID and one for CD.
.EXAMPLE
./add-ldapentry.ps1 -LDAPDescriptor oradev -ScanAddress orad1-scan -HostName orad1dbadm01,orad1dbadm02 -SID oradev1,oradev2 -backupservices
This command adds oradev LDAP entries: one for scan address, two for HostName/SID and one for CD and two for RMAN
.EXAMPLE
./add-ldapentry.ps1 -LDAPDescriptor oradev -ScanAddress orad1-scan -pdbserviceonly
This command adds LDAP entry for PDB using scan address and <PDB>"_svc" database service 
.NOTES
Version History
v1.0   - Chad Miller - 5/31/2015 - Initial release
v1.1   - Chad Miller - 6/15/2015 - Hostname/sid entries only created if multiple host and sid passed
v1.2   - Chad Miller - 6/15/2015 - Fixed issues with Ldif file generation
v1.3   - Chad Miller - 6/26/2015 - Fixed HOST and LDAP Servers
v1.4   - Chad Miller - 11/14/2015 - Added BackupServices and PdbServiceOnly logic
#>
[CmdletBinding(SupportsShouldProcess=$true)] param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$LDAPDescriptor,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$ScanAddress,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullorEmpty()]
    [string[]]$HostName,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullorEmpty()]
    [string[]]$SID,
    [switch]$BackupServices,
    [switch]$PdbServiceOnly
)


$ErrorActionPreference = "Continue"

#$LDAPServers = @("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")
$LDAPServers = @("yourLDAPserver1xb:17010","yourLDAPserver1xa:17010")

$path = "$PSScriptRoot\add.ldif"
New-Item -Path $path -ItemType File -Force -WhatIf:$false | out-null

####################### 
function Add-PdbServiceOnly
{

    #Add PdbServiceOnly to ldif file. For non-RAC the ScanAdress will be HostName of single node

$value = $null
$value = @"
dn: CN=$($LDAPDescriptor),CN=OracleContext,DC=yourDC,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: $($LDAPDescriptor)
orclNetDescString: (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($ScanAddress))(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=$($LDAPDescriptor)_svc.rjf.com)))
"@

Add-Content -Value $value -Path $path -WhatIf:$false

} #Add-PdbServiceOnly

####################### 
function Add-ScanAddress 
{
    #Add ScanAddress to ldif file. For non-RAC the ScanAdress will be HostName of single node

$value = $null
$value = @"
dn: CN=$($LDAPDescriptor),CN=OracleContext,DC=yourDC,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: $($LDAPDescriptor)
orclNetDescString: (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($ScanAddress))(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=$($LDAPDescriptor)_ad.rjf.com)))
"@

Add-Content -Value $value -Path $path -WhatIf:$false

} #Add-ScanAddress

####################### 
function Add-HostNameSID 
{
    #For each HostName/SID add entry to ldif file

for ($i=0; $i -lt $HostName.length; $i++) {
$value = $null
$value = @"

dn: CN=$($SID[$i]),CN=OracleContext,DC=yourDC,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: $($SID[$i])
orclNetDescString: (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($HostName[$i]))(PORT=1521)))(CONNECT_DATA=(SID=$($SID[$i]))))
"@

Add-Content -Value $value -Path $path -WhatIf:$false

}

} #Add-HostNameSID

####################### 
function Add-CD
{
    #Add Continous Delivery cd_ prefixed LDAP entry to ldif file

$value = $null
$value = @"

dn: CN=cd_$($LDAPDescriptor),CN=OracleContext,DC=yourDC,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: cd_$($LDAPDescriptor)
orclNetDescString: (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($ScanAddress))(PORT=1521)))(CONNECT_DATA=(SID=$($LDAPDescriptor)_ad.rjf.com)))
"@

    Add-Content -Value $value -Path $path -WhatIf:$false
    
} #Add-CD

####################### 
function Add-BackupServices
{
    #Add BackupServices entry to ldif file

for ($i=0; $i -lt $HostName.length; $i++) {
$k = $i + 1
$value = $null
$value = @"

dn: CN=$($LDAPDescriptor)_bkup$($k),CN=OracleContext,DC=yourDC,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: $($LDAPDescriptor)_bkup$($k)
orclNetDescString: (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($HostName[$i]))(PORT=1521)))(CONNECT_DATA=(SID=$($SID[$i]))))
"@

Add-Content -Value $value -Path $path -WhatIf:$false

}

} #Add-BackupServices

####################### 
function Invoke-LDIFDE
{
    #Run Ldifde.exe for each LDAPServer. Note -WhatIf will show what would have run without running It

    foreach($LDAPServer in $LDAPServers) {
        if ($PSCmdlet.ShouldProcess("C:\windows\system32\ldifde -i -s $LDAPServer -f $path -k -j .")) {
            $result = & "C:\windows\system32\ldifde" -i -s $LDAPServer -f $path -k -j .

            $result = $result -join "`n"

            new-object psobject -property @{
                ExitCode = $lastexitcode
                Command = "C:\windows\system32\ldifde -i -s $LDAPServer -f $path -k -j ."
                Result = $result
                Success = ($lastexitcode -eq 0)}

            #Save log files per LDAPServer
            rename-item -path "$PSScriptRoot\ldif.log" -NewName "$($LDAPServer -replace ':','_')_ldif.log" -ErrorAction Ignore -WhatIf:$false
            rename-item -path "$PSScriptRoot\ldif.err" -NewName "$($LDAPServer -replace ':','_')_ldif.err" -ErrorAction Ignore -WhatIf:$false
        }
    }

} #Invoke-LDIFDE

#######################
#       MAIN          #
#######################
#add entries to ldif file based on params

if ($PdbServiceOnly) {
    Add-PdbServiceOnly
}
else {
    Add-ScanAddress
    Add-CD

    if ($Hostname.length -gt 1 -and $SID.length -gt 1) {
        Add-HostNameSID
        if ($BackupServices) {
            Add-BackupServices
        }
    }
}
#Run Ldifde.exe for each LDAPServer
Invoke-LDIFDE