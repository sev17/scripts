#Change these settings as needed
$filepath = 'C:\Users\u00\Documents\backupset.xlsx'
#Comment/Uncomment connection string based on version
#Connection String for Excel 2007:
$connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"
#Connection String for Excel 2003:
#$connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=`"$filepath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";"
$qry = 'select * from [backupset$]'
$sqlserver = 'Z002\SQLEXPRESS'
$dbname = 'SQLPSX'
#Create a table in destination database with the with referenced columns and table name.
$tblname = 'ExcelData_fill'
 
#######################
function Get-ExcelData
{
 
    param($connString, $qry='select * from [sheet1$]')
 
    $conn = new-object System.Data.OleDb.OleDbConnection($connString)
    $conn.open()
    $cmd = new-object System.Data.OleDb.OleDbCommand($qry,$conn) 
    $da = new-object System.Data.OleDb.OleDbDataAdapter($cmd) 
    $dt = new-object System.Data.dataTable 
    [void]$da.fill($dt)
    $conn.close()
    $dt
 
} #Get-ExcelData
 
#######################
function Write-DataTableToDatabase
{ 
    param($dt,$destServer,$destDb,$destTbl)

    $connectionString = "Data Source=$destServer;Integrated Security=true;Initial Catalog=$destdb;"
    $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
    $bulkCopy.DestinationTableName = "$destTbl"
    $bulkCopy.WriteToServer($dt)
 
}# Write-DataTableToDatabase

#######################
$dt = Get-ExcelData $connString $qry
Write-DataTableToDatabase $dt $sqlserver $dbname $tblname