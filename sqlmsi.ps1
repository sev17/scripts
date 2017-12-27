#######################
<#
.SYNOPSIS
Creates an MSI file which is used to execute a SQL script using sqlcmd.exe.
.DESCRIPTION
The Out-SqlMsi script creates an MSI file which is used to execute a SQL script using sqlcmd.exe.
.EXAMPLE
./out-sqlmsi.ps1 -ServerInstance "Z001\SQL1" -InputFile "c:\users\u00\desktop\test.sql"
This command creates a test.msi file which executes the script c:\users\u00\desktop\test.sql against  SQL Server instance Z001\SQL1.
.NOTES
Version History
v1.0   - Chad Miller - 3/13/2013 - Initial release
candle.exe -dserverinstance=".\SQL1" -dinputfile="c:\users\u00\desktop\test.sql" -doutputfile="c:\users\u00\desktop\test.out" -ext WixUtilExtension -nologo sqlmsi.wxs
light.exe -ext WixUtilExtension -sw1076 -nologo sqlmsi.wixobj
(Start-Process -FilePath "msiexec.exe" -ArgumentList "/i c:\users\u00\desktop\sqlmsi.msi /log c:\users\u00\desktop\msilog.log" -Wait -Passthru).ExitCode
#>
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$ServerInstance,
[Parameter(Position=1, Mandatory=$true)]
[ValidateScript({Test-Path "$_"})]
[string]
$InputFile
)


$ErrorActionPreference = "Stop"
$InputFile = $(resolve-path $InputFile).ProviderPath
$SourceFile = "sqlmsi.wxs"
$OutputFile = [system.io.path]::ChangeExtension($InputFile,"out")
$ObjectFile = [system.io.path]::ChangeExtension($InputFile,"wixobj")
$MsiFile = [system.io.path]::ChangeExtension($InputFile,"msi")

if (test-path "C:\Program Files (x86)\WiX Toolset v3.7\bin\") {
    $wixbin = "C:\Program Files (x86)\WiX Toolset v3.7\bin\"
}
elseif (test-path "C:\Program Files\WiX Toolset v3.7\bin\") {
        $wixbin = "C:\Program Files\WiX Toolset v3.7\bin\"
}
else {
    throw 'Cannot Find Wix Installation'
}
$is64 = [bool](gwmi win32_operatingsystem  | ?{$_.caption -like "*x64*" -or $_.OSArchitecture -eq'64-bit'})

#######################
function Test-SqlConnection
{
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$ServerInstance)

    $sqlConn = new-object ("Data.SqlClient.SqlConnection") "Data Source=$ServerInstance;Integrated Security=true;Initial Catalog=master;Connect Timeout=15;"                                         
    try {
        $sqlConn.Open()
        $sqlConn.Dispose()
    } 
    catch {
        throw $_
    }
} #Test-Sql

#######################
function Invoke-Candle
{
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$ServerInstance,
[Parameter(Position=1, Mandatory=$true)]
[string]
$InputFile,
[Parameter(Position=2, Mandatory=$true)]
[string]
$OutputFile,
[Parameter(Position=3, Mandatory=$true)]
[string]
$ObjectFile,
[Parameter(Position=4, Mandatory=$true)]
[ValidateScript({Test-Path "$_"})]
[string]
$SourceFile
)

    if ($is64) {
        $options = @"
-dserverinstance="$ServerInstance" -dinputfile="$InputFile" -doutputfile="$OutputFile" -arch x64 -ext WixUtilExtension -nologo -out "$ObjectFile" "$SourceFile"
"@
    }
    else {
        $options = @"
-dserverinstance="$ServerInstance" -dinputfile="$InputFile" -doutputfile="$OutputFile" -ext WixUtilExtension -nologo -out "$ObjectFile" "$SourceFile"
"@
    }
    $tempFile = [io.path]::GetTempFileName()
    $exitCode = (Start-Process -FilePath "$wixbin\candle.exe" -ArgumentList @"
$options
"@ -Wait -NoNewWindow -RedirectStandardOutput $tempFile -Passthru).ExitCode

    #$result = &"$wixbin\candle.exe" -dserverinstance="$ServerInstance" -dinputfile="$InputFile" -doutputfile="$OutputFile" -ext WixUtilExtension -nologo -out "$ObjectFile" "$SourceFile"
    #$result = $result -join "`n"
    
    $result = [System.IO.File]::ReadAllText("$tempfile")
    remove-item $tempFile
    
    new-object psobject -property @{
        ExitCode = $exitcode
        Command = "candle.exe -dserverinstance=`"$ServerInstance`" -dinputfile=`"$InputFile`" -doutputfile=`"$OutputFile`" -ext WixUtilExtension -nologo -out `"$ObjectFile`" `"$SourceFile`""
        Result = $result
        Success = ($exitcode -eq 0)}

    if ($exitcode -ne 0) {
        throw $result
    }

} #Invoke-Candle

#######################
function Invoke-Light
{
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$MsiFile,
[Parameter(Position=1, Mandatory=$true)]
[ValidateScript({Test-Path "$_"})]
[string]
$ObjectFile
)

    $tempFile = [io.path]::GetTempFileName()
    $exitCode = (Start-Process -FilePath "$wixbin\light.exe" -ArgumentList @"
-ext WixUtilExtension -sw1076 -nologo -out "$MsiFile" "$ObjectFile"
"@ -Wait -NoNewWindow -RedirectStandardOutput $tempFile -Passthru).ExitCode
    
    #$result = &"$wixbin\light.exe" -ext WixUtilExtension -sw1076 -nologo -out "$MsiFile" "$ObjectFile"
    #$result = $result -join "`n"

    $result = [System.IO.File]::ReadAllText("$tempfile")
    remove-item $tempFile

    new-object psobject -property @{
        ExitCode = $exitcode
        Command = "light.exe -ext WixUtilExtension -sw1076 -nologo -out $MsiFile $ObjectFile"
        Result = $result
        Success = ($exitcode -eq 0)}

    if ($exitcode -ne 0) {
        throw $result
    }

} #Invoke-Light

#######################
##     MAIN          ##
#######################

try {
    Test-SqlConnection -ServerInstance  $ServerInstance
    Invoke-Candle -ServerInstance $ServerInstance -InputFile $InputFile -OutputFile $OutputFile -ObjectFile $ObjectFile -SourceFile $SourceFile
    Invoke-Light -ObjectFile $ObjectFile -msiFile $MsiFile
}
catch {
    write-error "$_ `n Failed to create MSI"
}
