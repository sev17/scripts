
add-type -AssemblyName System.DirectoryServices.AccountManagement
$ComputerName = 'yourServer'

$ctype = [System.DirectoryServices.AccountManagement.ContextType]::Domain
$OU = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($ctype,$ComputerName) | Select  -ExpandProperty DistinguishedName

$OU -like "*OU=SQL*" 
