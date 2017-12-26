#Edit SSIS.psm1 and Comment/Uncomment 2005 or 2008 version of SSIS assembly
#add-type -AssemblyName "Microsoft.SqlServer.ManagedDTS, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
add-type -AssemblyName "Microsoft.SqlServer.ManagedDTS, Version=10.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

#Import the SSIS module
import-module SSIS

#Work with SSIS packages stored on the file system
$packages = dir "C:\Program Files\Microsoft SQL Server\100\DTS\Packages\*" | select -ExpandProperty Fullname | foreach {get-ispackage -path $_ }
$packages | foreach {$package = $_; $_.Configurations | Select @{n='Package';e={$Package.DisplayName}}, Name,ConfigurationString}
$packages | foreach {$package = $_; $_.Connections | Select @{n='Package';e={$Package.DisplayName}}, Name,ConnectionString}

#Create a new folder on the SSIS server
new-isitem "\msdb" "sqlpsx" "Z002"
#Copy SSIS packages from the file system to SQL Server and change the connection string for SSISCONFIG
copy-isitemfiletosql -path "C:\Program Files\Microsoft SQL Server\100\DTS\Packages\*" -destination "msdb\sqlpsx" -destinationServer "Z002" -connectionInfo @{SSISCONFIG=".\SQLEXPRESS"}

#Work with SSIS packages on SQL Server
$packages = get-isitem -path '\sqlpsx' -topLevelFolder 'msdb' -serverName "Z002\SQL2K8" | where {$_.Flags -eq 'Package'} | foreach {get-ispackage -path $_.literalPath -serverName $_.Servername}
$packages | foreach {$package = $_; $_.Configurations | Select @{n='Package';e={$Package.DisplayName}}, Name,ConfigurationString}
$packages | foreach {$package = $_; $_.Connections | Select @{n='Package';e={$Package.DisplayName}}, Name,ConnectionString}