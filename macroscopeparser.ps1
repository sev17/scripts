#requires -version 2

#Chad Miller
#http://www.sev17.com/
#Uses MacroScope/Antlr to parse SQL query for tables and table aliases
#Download MacroScope from http://macroscope.sourceforge.net/ and compile from source
#Or grab compiled assemblies from http://cid-ea42395138308430.skydrive.live.com/embedicon.aspx/Public/Blog/macroscopeParser.zip

param ($commandText)

#Assumes MacroScope and Antlr3 assemblies are in same directory
add-type -Path $(Resolve-Path .\Antlr3.Runtime.dll | Select-Object -ExpandProperty Path)
add-type -Path $(Resolve-Path .\MacroScope.dll | Select-Object -ExpandProperty Path)

#######################
function Get-Table
{
    param($table)

    $table

    if ($table.HasNext)
    { Get-Table $table.Next }
    
}

$sqlparser =[MacroScope.Factory]::CreateParser($commandText)
$expression = $sqlparser.queryExpression()
Get-Table $expression.From.Item | Select @{n='Name';e={$_.Source.Identifier}}, @{n='Alias';e={$_.Alias}}