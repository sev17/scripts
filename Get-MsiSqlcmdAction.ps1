param(
[Parameter(Position=0, Mandatory=$true)]
[ValidateScript({Test-Path "$_"})]
[string]
$MsiFile
)

$PSScriptRoot = (Split-Path $MyInvocation.MyCommand.Path -Parent)
$MsiFile = $(resolve-path $MsiFile).ProviderPath

cscript "$PSScriptRoot\get-msisqlcmdaction.vbs" "$MsiFile" //Nologo
