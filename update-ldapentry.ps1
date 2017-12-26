#######################
<#
.SYNOPSIS
Updates an LDAP entry for use with Oracle LDAP name resolution.
.DESCRIPTION
The update-ldapentry script updates an ldap entry for LDAP Descriptor using the command-line utility ldifde.
.EXAMPLE
./update-ldapentry.ps1 -LDAPDescriptor ora1dev -ScanAddress ora1-scan -HostName ora1dbadm01,ora1dbadm02 -SID ora1dev1,ora1dev2
This command updates ora1dev LDAP entries: one for scan address, two for HostName/SID and one for CD.
.NOTES
Version History
v1.0   - Chad Miller - 6/4/2015 - Initial release
v1.1   - Chad Miller - 6/15/2015 - Hostname/sid entries only created if multiple host and sid passed
v1.2   - Chad Miller - 6/15/2015 - Fixed issues with Ldif file generation
v1.3   - Chad Miller - 6/26/2015 - Fixed HOST and LDAP Servers
v1.4   - Chad Miller - 11/14/2015 - Simplified logic to only update explicit LDAPDescriptor with specific orlNetDescString
#>
[CmdletBinding(SupportsShouldProcess=$true)] param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$LDAPDescriptor,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$orclNetDescString
)


$ErrorActionPreference = "Continue"

#$LDAPServers = @("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")
$LDAPServers = @("yourLDAPserver1xb:17010","yourLDAPserver1xa:17010")

$path = "$PSScriptRoot\update.ldif"
New-Item -Path $path -ItemType File -Force -WhatIf:$false | out-null

#1. Add ScanAddress to ldif file. For non-RAC the ScanAdress will be HostName of single node
$value = $null
$value = @"
dn: CN=$($LDAPDescriptor),CN=OracleContext,DC=yourDC,DC=com
changetype: modify
replace: orclNetDescString
orclNetDescString: $($orclNetDescString)
"@

Add-Content -Value $value -Path $path -WhatIf:$false

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