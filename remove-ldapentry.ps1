#######################
<#
.SYNOPSIS
Removes an LDAP entry for use with Oracle LDAP name resolution.
.DESCRIPTION
The remove-ldapentry script removexs an ldap entry for LDAP Descriptor using the command-line utility ldifde.
.EXAMPLE
./remove-ldapentry.ps1 -LDAPDescriptor ora1dev
This command removes ora1dev LDAP entry.
.NOTES
Version History
v1.0   - Chad Miller - 6/4/2015 - Initial release
v1.1   - Chad Miller - 6/15/2015 - Hostname/sid entries only created if multiple host and sid passed
v1.2   - Chad Miller - 6/15/2015 - Fixed issues with Ldif file generation
v1.3   - Chad Miller - 11/14/2015 - Simplified logic to only remove LDAPDescriptors
#>
[CmdletBinding(SupportsShouldProcess=$true)] param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string[]]$LDAPDescriptor
)


$ErrorActionPreference = "Continue"

#$LDAPServers = @("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")
$LDAPServers = @("yourLDAPserver1xb:17010","yourLDAPserver1xa:17010")

$path = "$PSScriptRoot\remove.ldif"
New-Item -Path $path -ItemType File -Force -WhatIf:$false  | out-null

#Add delete entries for each LDAPDescriptor
foreach ($ld in $LDAPDescriptor) {
$value = $null
$value = @"

dn: CN=$($ld),CN=OracleContext,DC=yourDC,DC=com
changetype: delete
"@

    Add-Content -Value $value -Path $path -WhatIf:$false 
}

foreach($LDAPServer in $LDAPServers) {
    if ($PSCmdlet.ShouldProcess("C:\windows\system32\ldifde -i -s $LDAPServer -f $path -k")) {
        $result = & "C:\windows\system32\ldifde" -i -s $LDAPServer -f $path -k

        $result = $result -join "`n"

        new-object psobject -property @{
            ExitCode = $lastexitcode
            Command = "C:\windows\system32\ldifde -i -s $LDAPServer -f $path -k"
            Result = $result
            Success = ($lastexitcode -eq 0)}

        #Save log files per LDAPServer
        rename-item -path "$PSScriptRoot\ldif.log" -NewName "$($LDAPServer -replace ':','_')_ldif.log" -ErrorAction Ignore -WhatIf:$false
        rename-item -path "$PSScriptRoot\ldif.err" -NewName "$($LDAPServer -replace ':','_')_ldif.err" -ErrorAction Ignore -WhatIf:$false
    }
}