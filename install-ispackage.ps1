#######################
<#
.SYNOPSIS
Installs an SSIS package to a SQL Server store.
.DESCRIPTION
The Install-ISPackage script installs an Dtsx file to a SQL Server store using the command-line utility dtutil.
Works for 2005 and higher
.EXAMPLE
./install-ispackage.ps1 -DtsxFullName "C:\Users\Public\bin\SSIS\sqlpsx1.dtsx" -ServerInstance "Z001\SQL1" -PackageFullName "SQLPSX\sqlpsx1"
This command install the sqlpsx1.dtsx package to SQL Server instance Z001\SQL1 under the SQLPSX folder as sqlpsx1. If SQLPSX folder does not exist it will be created.
.NOTES
Version History
v1.0   - Chad Miller - 6/26/2012 - Initial release
v1.1   - Chad Miller - 7/05/2012 - Updated to output object. Fixed lastexitcode check in test functions
v1.2   - Chad Miller - 7/09/2012 - Added SqlVersion and Dtutil Path logic
v1.3   - Chad Miller - 7/10/2012 - Fixed 2005 path logic
v1.4   - Chad Miller - 9/25/2012 - Fixed 2012 path logic
#>
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$DtsxFullName,
[Parameter(Position=1, Mandatory=$true)]
[string]
$ServerInstance,
[Parameter(Position=2, Mandatory=$true)]
[string]
$PackageFullName
)


$ErrorActionPreference = "Stop"
$Script:dtutil = $null
$exitCode = @{
0="The utility executed successfully."
1="The utility failed."
4="The utility cannot locate the requested package."
5="The utility cannot load the requested package."
6="The utility cannot resolve the command line because it contains either syntactic or semantic errors"}

#######################
function Get-SqlVersion
{
    param($ServerInstance)
    
    write-verbose "sqlcmd -S `"$ServerInstance`" -d `"master`" -Q `"SET NOCOUNT ON; SELECT SERVERPROPERTY('ProductVersion')`" -h -1 -W"
    
    $SqlVersion = sqlcmd -S "$ServerInstance" -d "master" -Q "SET NOCOUNT ON; SELECT SERVERPROPERTY('ProductVersion')" -h -1 -W

    if ($lastexitcode -ne 0) {
        throw $SqlVersion
    }
    else {
        $SqlVersion
    }
    
} #Get-SqlVersion

#######################
function Set-DtutilPath
{
    param($SqlVersion)

    $paths = [Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"

    if ($SqlVersion -like "9*") {
        $Script:dtutil = $paths | where { $_ -like "*Program Files\Microsoft SQL Server\90\DTS\Binn\" }
        if ($Script:dtutil -eq $null) {
            throw "SQL Server 2005 Version of dtutil not found."
        }
    }
    elseif ($SqlVersion -like "10*") {
        $Script:dtutil = $paths | where { $_ -like "*Program Files\Microsoft SQL Server\100\DTS\Binn\" }
        if ($Script:dtutil -eq $null) {
            throw "SQL Server 2008 or 2008R2 Version of dtutil not found."
        }
    }
    elseif ($SqlVersion -like "11*") {
        $Script:dtutil = $paths | where { $_ -like "*Program Files\Microsoft SQL Server\110\DTS\Binn\" }
        if ($Script:dtutil -eq $null) {
            throw "SQL Server 2012 Version of dtutil not found."
        }
    }

    if ($Script:dtutil -eq $null) {
        throw "Unable to find path to dtutil.exe. Verify dtutil installed."
    }
    else {
        $Script:dtutil += 'dtutil.exe'
    }
    
} #Set-DtutilPath
 
#######################
function install-package
{
    param($DtsxFullName, $ServerInstance, $PackageFullName)
    
    $result = & $Script:dtutil /File "$DtsxFullName" /DestServer "$ServerInstance" /Copy SQL`;"$PackageFullName" /Quiet
    $result = $result -join "`n"

    new-object psobject -property @{
        ExitCode = $lastexitcode
        ExitDescription = "$($exitcode[$lastexitcode])"
        Command = "$Script:dtutil /File `"$DtsxFullName`" /DestServer `"$ServerInstance`" /Copy SQL;`"$PackageFullName`" /Quiet"
        Result = $result
        Success = ($lastexitcode -eq 0)}

    if ($lastexitcode -ne 0) {
        throw $exitcode[$lastexitcode]
    }

} #install-package

#######################
function test-path
{
    param($ServerInstance, $FolderPath)

    write-verbose "$Script:dtutil /SourceServer `"$ServerInstance`" /FExists SQL`;`"$FolderPath`""

    $result = & $Script:dtutil /SourceServer "$ServerInstance" /FExists SQL`;"$FolderPath"

    if ($lastexitcode -gt 1) {
        $result = $result -join "`n"
        throw "$result `n $($exitcode[$lastexitcode])"
    }

    if ($result -and $result[4] -eq "The specified folder exists.") {
        $true
    }
    else {
        $false
    }

} #test-path

#######################
function test-packagepath
{
    param($ServerInstance, $PackageFullName)

    write-verbose "$Script:dtutil /SourceServer `"$ServerInstance`" /SQL `"$PackageFullName`" /EXISTS"
    
    $result = & $Script:dtutil /SourceServer "$ServerInstance" /SQL "$PackageFullName" /EXISTS

    if ($lastexitcode -gt 1) {
        $result = $result -join "`n"
        throw "$result `n $($exitcode[$lastexitcode])"
    }

    new-object psobject -property @{
        ExitCode = $lastexitcode
        ExitDescription = "$($exitcode[$lastexitcode])"
        Command = "$Script:dtutil /SourceServer `"$ServerInstance`" /SQL `"$PackageFullName`" /EXISTS"
        Result = $result[4]
        Success = ($lastexitcode -eq 0 -and $result -and $result[4] -eq "The specified package exists.")}


} #test-packagepath

#######################
function new-folder
{
    param($ServerInstance, $ParentFolderPath, $NewFolderName)

    $result = & $Script:dtutil /SourceServer "$ServerInstance" /FCreate SQL`;"$ParentFolderPath"`;"$NewFolderName"
    $result = $result -join "`n"

    new-object psobject -property @{
        ExitCode = $lastexitcode
        ExitDescription = "$($exitcode[$lastexitcode])"
        Command = "$Script:dtutil /SourceServer `"$ServerInstance`" /FCreate SQL;`"$ParentFolderPath`";`"$NewFolderName`""
        Result = $result
        Success = ($lastexitcode -eq 0)}

    if ($lastexitcode -ne 0) {
        throw $exitcode[$lastexitcode]
    }

} #new-folder

#######################
function Get-FolderList
{
    param($PackageFullName)

    if ($PackageFullName -match '\\') {
        $folders = $PackageFullName  -split "\\"
        0..$($folders.Length -2) | foreach { 
        new-object psobject -property @{
            Parent=$(if($_-gt 0) { $($folders[0..$($_ -1)] -join "\") } else { "\" })
            FullPath=$($folders[0..$_] -join "\")
            Child=$folders[$_]}}
    }

} #Get-FolderList
 
#######################
##     MAIN          ##
#######################

try {
    #1. Get Sql Version
    $SqlVersion = Get-SqlVersion -ServerInstance $ServerInstance
    
    #2. Set Dtutil Path based on Sql Version
    Set-DtutilPath -SqlVersion $SqlVersion
    
    #3. Get SSIS Folder List, verify exists and create missing folders
    Get-FolderList -PackageFullName $PackageFullName |
    where { $(test-path -ServerInstance $ServerInstance -FolderPath $_.FullPath) -eq $false } |
    foreach { new-folder -ServerInstance $ServerInstance -ParentFolderPath $_.Parent -NewFolderName $_.Child }

    #4. Install SSIS Package
    install-package -DtsxFullName $DtsxFullName -ServerInstance $ServerInstance -PackageFullName $PackageFullName
    
    #5. Verify Package
    test-packagepath -ServerInstance $ServerInstance -PackageFullName $PackageFullName
}
catch {
    write-error "$_ `n $("Failed to install DtsxFullName {0} to ServerInstance {1} PackageFullName {2}" -f $DtsxFullName,$ServerInstance,$PackageFullName)"
}