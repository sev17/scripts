#Usage: ./WPFTableSpace.ps1 'Z002\SqlExpress' AdventureWorks
#Note: Requires .NET 3.5, Visifire Charts (tested on v2.1.0), Powerboots (tested on v0.1), and SQLPSX (tested on v1.5)
param($sqlserver=$(throw 'sqlserver is required.'),$dbname=$(throw 'dbname is required.'),$top=10)

$libraryDir = Convert-Path (Resolve-Path "$ProfileDir\Libraries")
[Void][Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path "$libraryDir\WPFVisifire.Charts.dll")) )
. $libraryDir\LibrarySmo.ps1

if (!(Get-PSSnapin | ?{$_.name -eq 'PoshWpf'}))
{ Add-PsSnapin PoshWpf }

$qry = @"
CREATE TABLE #spaceused
(name nvarchar(128),
rows char(11),
reserved varchar(18),
data varchar(18),
index_size varchar(18),
unused varchar(18));
EXEC sp_MSforeachtable 'insert #spaceused exec sp_spaceused ''?''';
SELECT TOP $top name
, CAST(rows AS int) AS rows
, CAST(SUBSTRING(reserved,0,LEN(reserved)-2) AS int) AS reserved
, CAST(SUBSTRING(data,0,LEN(data)-2) AS int) AS data
, CAST(SUBSTRING(index_size,0,LEN(index_size)-2) AS int) AS index_size
, CAST(SUBSTRING(unused,0,LEN(unused)-2) AS int) AS unused
FROM #spaceused
ORDER BY reserved DESC;
DROP TABLE #spaceused;
"@

New-BootsWindow -Async {
    $chart = New-Object Visifire.Charts.Chart
    $chart.Height = 500 
    $chart.Width = 800 
    $chart.watermark = $false
    $chart.Theme = "Theme2"
    $chart.View3D = $true
    $chart.BorderBrush = [System.Windows.Media.Brush]"Gray"
    $chart.CornerRadius = [System.Windows.CornerRadius]5
    $chart.BorderThickness = [System.Windows.Thickness]0.5
    $chart.AnimationEnabled = $false

    $ds1 = New-Object Visifire.Charts.DataSeries
    $ds1.RenderAs = [Visifire.Charts.RenderAs]"StackedBar"
    $ds1.LegendText = "Data"
    $ds1.LabelEnabled = $true
    $ds1.LabelText = "#YValue"

    $ds2 = New-Object Visifire.Charts.DataSeries
    $ds2.RenderAs = [Visifire.Charts.RenderAs]"StackedBar"
    $ds2.LegendText = "Index"
    $ds2.LabelEnabled = $true
    $ds2.LabelText = "#YValue"
    $ds2.RadiusX = 5
    $ds2.RadiusY = 5
 
    foreach ($table in Get-SqlData $sqlserver $dbname $qry)
    {
    $dp1 = new-object Visifire.Charts.DataPoint
    $dp1.AxisXLabel = $table.name
    $dp1.YValue = $table.data
    $ds1.DataPoints.Add($dp1)

    $dp2 = new-object Visifire.Charts.DataPoint
    $dp2.YValue = $table.index_size
    $ds2.DataPoints.Add($dp2)
    }   
    $chart.Series.Add($ds1)
    $chart.Series.Add($ds2)

    $chart
} -Title "Table Space"
