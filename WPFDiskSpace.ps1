#Usage: Get-WmiObject -computername Z002 Win32_LogicalDisk -filter "DriveType=3" | ./WPFDiskSpace.ps1
#Note: Requires .NET 3.5, Visifire Charts (tested on v2.1.0), Powerboots (tested on v0.1)

$libraryDir = Convert-Path (Resolve-Path "$ProfileDir\Libraries")
[Void][Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path "$libraryDir\WPFVisifire.Charts.dll")) )

if (!(Get-PSSnapin | ?{$_.name -eq 'PoshWpf'}))
{ Add-PsSnapin PoshWpf }

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
    $ds1.LegendText = "UsedSpace"
    $ds1.LabelEnabled = $true
    #$ds1.LabelText = "#YValue"

    $ds2 = New-Object Visifire.Charts.DataSeries
    $ds2.RenderAs = [Visifire.Charts.RenderAs]"StackedBar"
    $ds2.LegendText = "FreeSpace"
    $ds2.LabelEnabled = $true
    #$ds2.LabelText = "#YValue"
    $ds2.RadiusX = 5
    $ds2.RadiusY = 5
 
    foreach ($disk in $input)
    {

    $pFree = $([int](([double]$disk.FreeSpace/[double]$disk.Size) * 100))
    $pUsed = $([int]((([double]$disk.Size - [double]$disk.FreeSpace)/[double]$disk.Size) * 100))
    $dp1 = new-object Visifire.Charts.DataPoint
    $dp1.AxisXLabel = ($disk.Name)
    $dp1.YValue = ([math]::round((([double]$disk.Size - [double]$disk.FreeSpace)/1GB),2))
    $dp1.LabelText = "$pUsed"
    $ds1.DataPoints.Add($dp1)

    $dp2 = new-object Visifire.Charts.DataPoint
    $dp2.YValue = ([math]::round(($disk.FreeSpace/1GB),2))
    $dp2.LabelText = "$pFree"
    $ds2.DataPoints.Add($dp2)


    }   
    $chart.Series.Add($ds1)
    $chart.Series.Add($ds2)

    $chart
} -Title "Disk Space"
