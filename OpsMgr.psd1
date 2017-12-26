<# 
#Run the following code to create OpsMgr module
#To Use run import-module OpsMgr; Start-OperationsManagerClientShell -ManagementServerName: "" -PersistConnection: $true -Interactive: $true;
if (-not (test-path $home\Documents\WindowsPowerShell\Modules\OpsMgr))
{new-item  $home\Documents\WindowsPowerShell\Modules\OpsMgr -type directory}
Set-Location "C:\Program Files\System Center Operations Manager 2007"
Copy-Item "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll","Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml",`
"Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml","Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll-help.xml",`
"Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Functions.ps1","Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1",`
"Microsoft.EnterpriseManagement.OperationsManager.ClientShell.NonInteractiveStartup.ps1" `
-destination $home\Documents\WindowsPowerShell\Modules\OpsMgr
Set-Location "C:\Program Files\System Center Operations Manager 2007\SDK Binaries"
Copy-Item  "Microsoft.EnterpriseManagement.OperationsManager.dll","Microsoft.EnterpriseManagement.OperationsManager.Common.dll" -destination $home\Documents\WindowsPowerShell\Modules\OpsMgr
#>


@{
ModuleVersion="0.0.0.1"
Description="A Wrapper for Microsoft's Operations Manager Shell "
Author="Chad Miller"
Copyright="© 2010, Chad Miller, released under the Ms-PL"
CompanyName="http://sev17.com"
CLRVersion="2.0"
FormatsToProcess="Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml"
NestedModules="Microsoft.EnterpriseManagement.OperationsManager.ClientShell"
RequiredAssemblies="Microsoft.EnterpriseManagement.OperationsManager.dll","Microsoft.EnterpriseManagement.OperationsManager.Common.dll"
TypesToProcess="Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml"
ScriptsToProcess="Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Functions.ps1"
}