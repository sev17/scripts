#Depends on Microsoft Report Viewer Redistributable and ReportExporters
#ReportExporters available at http://www.codeproject.com/KB/reporting-services/ReportExporters_WinForms.aspx
#Download demo version of ReportExporters for compiled dlls
#Tested with Microsoft Report Viewer 2008 SP1 Redistributable, although 2005 and base 2008 version should work
#Visual Studio installations as well as SQL Server Reporting Services may already include Microsoft Report Viewer
#Microsoft Report Viewer Redist available at http://www.microsoft.com/downloads/details.aspx?familyid=BB196D5D-76C2-4A0E-9458-267D22B6AAC6&displaylang=en
#EXAMPLES
#get-alias | ./out-report.ps1 "c:\users\u00\bin\aliases.xls" xls
#get-alias | ./out-report.ps1 "c:\users\u00\bin\aliases.pdf" pdf
#get-alias | ./out-report.ps1 "c:\users\u00\bin\aliases.jpeg" -filetype image -imagetype JPEG -height 22 -width 14

param($fileName,$fileType,$imageType,$height=11,$width=8.5)

$libraryDir = Convert-Path (Resolve-Path "$ProfileDir\Libraries")
[void][reflection.assembly]::LoadWithPartialName("Microsoft.ReportViewer.WinForms")
[void][Reflection.Assembly]::LoadFrom("$libraryDir\ReportExporters.Common.dll")
[void][Reflection.Assembly]::LoadFrom("$libraryDir\ReportExporters.WinForms.dll")

$fileTypes = 'XLS','PDF','IMAGE'
if (!($fileTypes -contains $fileType)) 
{ throw 'Valid file types are XLS, PDF, IMAGE' }

$imageTypes = 'BMP','EMF','GIF','JPEG','PNG','TIFF'
if ( $imageType -and !($imageTypes -contains $imageType)) 
{ throw 'Valid image types are BMP,EMF,GIF,JPEG,PNG or TIFF' }

#######################
function New-ImageDeviceInfo
{
    param($imageType,$height,$width)

    $deviceInfo = new-object ("ReportExporters.Common.Exporting.ImageDeviceInfoSettings") $imageType
    $deviceInfo.PageHeight = new-object System.Web.UI.WebControls.Unit($height,[System.Web.UI.WebControls.UnitType]::Inch)
    $deviceInfo.PageWidth = new-object System.Web.UI.WebControls.Unit($width,[System.Web.UI.WebControls.UnitType]::Inch)
    $deviceInfo.StartPage = 0
    return $deviceInfo

} #New-ImageDeviceInfo

#DataTable section from http://mow001.blogspot.com/2006/05/powershell-out-datagrid-update-and.html
$dt = new-Object Data.datatable  
  $First = $true  
  foreach ($item in $input){  
    $DR = $DT.NewRow()  
    $Item.PsObject.get_properties() | foreach {  
      If ($first) {  
        $Col =  new-object Data.DataColumn  
        $Col.ColumnName = $_.Name.ToString()  
        $DT.Columns.Add($Col)       }  
      if ($_.value -eq $null) {  
        $DR.Item($_.Name) = "[empty]"  
      }  
      ElseIf ($_.IsArray) {  
        $DR.Item($_.Name) =[string]::Join($_.value ,";")  
      }  
      Else {  
        $DR.Item($_.Name) = $_.value  
      }  
    }  
    $DT.Rows.Add($DR)  
    $First = $false  
  } #End DataTable section  

$ds = new-object System.Data.dataSet 
$ds.merge($dt)
$dsaProvider = new-object ReportExporters.Common.Adapters.DataSetAdapterProvider $ds
$dsa = $dsaProvider.GetAdapters()
$reportExporter = new-object ReportExporters.WinForms.WinFormsReportExporter $dsa

switch ($fileType)
{
    'XLS'   { $content =$reportExporter.ExportToXls() }
    'PDF'   { $content = $reportExporter.ExportToPdf() }
    'IMAGE' { $deviceInfo = New-ImageDeviceInfo $imageType $height $width; $content =  $reportExporter.ExportToImage($deviceInfo) }
}

[System.IO.File]::WriteAllBytes($fileName,$content.ToArray())