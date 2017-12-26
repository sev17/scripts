#######################
<#
.SYNOPSIS
test ldap connectivity for an LDAP Server.
.DESCRIPTION
The test-ldapconnection script tests connectivity to an LDAP Server 
.EXAMPLE
./test-ldapconnection.ps1 -LDAPServer "yourLDAPserver20:17010"
This command compares LDAP entries.
.NOTES
Version History
v1.0   - Chad Miller - 7/1/2015 - Initial release
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullorEmpty()]
    [ValidateSet("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")]
    [string[]]$LDAPServer = ("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")
)


BEGIN {Add-Type -AssemblyName System.DirectoryServices.Protocols}
PROCESS {
        try {
            $LDAPServer | foreach {
            $name=$_; $LdapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($name)
            $LdapConnection.Bind()
            new-object psobject -property @{Test="Test-LdapConnection";Args="$name";Result=$true;Message=$null}
            $LdapConnection.Dispose()
            }
        }
        
        catch { new-object psobject -property @{Test="Test-LdapConnection";Args="$name";Result=$false;Message="$($_.ToString())"} }
}
END {}
