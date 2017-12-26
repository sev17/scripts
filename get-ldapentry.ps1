#######################
<#
.SYNOPSIS
Gets ldap entries for an LDAP Server.
.DESCRIPTION
The Get-ldapentry script gets Oracle LDAP aliases entries for an LDAP Server 
.EXAMPLE
./get-ldapentry.ps1 -LDAPServer "yourLDAPserver40:17010"
This command gets LDAP entries.
.NOTES
Version History
v1.0   - Chad Miller - 7/1/2015  - Initial release
v2.0   - Chad Miller - 3/10/2016 - Fixed ony returned 1000 entries
v3.0   - Chad Miller - 10/11/2016 - Removed oldservers servers
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullorEmpty()]
    [ValidateSet("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")]
    [string[]]$LDAPServer = ("yourLDAPserver20:17010","yourLDAPserver21:17010","yourLDAPserver40:17010","yourLDAPserver41:17010","yourLDAPserver1xb:17010","yourLDAPserver2xb:17010","yourLDAPserver1xa:17010","yourLDAPserver2xa:17010")
)


BEGIN {}
PROCESS {
    foreach ($LDAP in $LDAPServer) {

    $defaultAdminContext = "dc=rjfit,dc=com"
    $oracleHostEntryPath = "LDAP://{0}/cn=OracleContext,{1}" -f $LDAP, $defaultAdminContext
    $directoryEntry = New-Object System.DirectoryServices.DirectoryEntry($oracleHostEntryPath,$null,$null,[System.DirectoryServices.AuthenticationTypes]::Anonymous)

    $directorySearcher = New-Object System.DirectoryServices.DirectorySearcher($directoryEntry,"(objectCategory=orclNetService)",@('orclnetdescstring','cn'))
    $directorySearcher.PageSize = 1000
    $directorySearcher.SearchScope = "Subtree"
    $directorySearcher.FindAll() | foreach {$_.Properties } | 
    Select @{n='cn';e={$_["cn"]}}, @{n='orclnetdescstring';e={[System.Text.Encoding]::UTF8.GetString($($_["orclnetdescstring"]))}}, @{n='LDAPServer';e={$LDAP}}
    }
}
END {}