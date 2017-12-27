#####################
#Forums > Using PowerShell > SQL Server
#SQL Server to Excel export
#Last Post 17 Sep 2012 02:16 PM by Ranjit. 3 Replies.
#AuthorMessages
#Naveen J V
#New Member
#
#Posts:1
#03 Aug 2012 05:04 AM
#Hi Experts,
#I am a novice to PowerShell programming.
#Can any one give example of writing code for fetching data from a SQL Server table and writing onto a Excel?
#Thanks & Regards,
#Naveen J V
#Chad Miller
#Basic Member
#
#Posts:198
#03 Aug 2012 06:27 AM
#Powershell has a built-in export-csv cmdlet you could output directly to CSV of some other delimited file 
#If you have SQL 2008 or higher there's an invoke-sqlcmd cmdlet: 
#invoke-sqlcmd -ServerInstance MySQLServerName -Database pubs -Query "SELECT * FROM authors" | export-csv -NoTypeInfo -path ./authors.csv 
#Of course if its easier to just the classic sqlcmd.exe also which supports outputting queries to a delimited file. 
#Ranjit
#New Member
#
#Posts:2
#17 Sep 2012 02:15 PM
#Hi, I have powershell script which can capture sql server disk space and store it into a table but it is capturing only user databases, I could not find the way how to capture system databases also, can you help me on that. 
#If you are ok can you send me your email address, so that I can send my code. 
#Thanks in advance.
#Ranjit
#New Member
#
#Posts:2
#17 Sep 2012 02:16 PM
#Hi, I have powershell script which can capture sql server disk space and store it into a table but it is capturing only user databases, I could not find the way how to capture system databases also, can you help me on that. If you are ok can you send me your email address, so that I can send my code. Thanks in advance.
#Forums > Using PowerShell > SQL Server
#Active Forums 4.3
#####################
#Forums > Using PowerShell > SQL Server
#Multiple SQL Queries
#Last Post 23 Aug 2012 03:33 AM by umplebyc. 12 Replies.
#AuthorMessages
#umplebyc
#New Member
#
#Posts:10
#01 Aug 2012 11:33 PM
#I am looking for a Powershell script to run SQL Queries from a particular folder (Could be upto 70 queries in the folder) in order by name, record the execuction and if any error stop the script so none of the other queries execute.  I have tried to make an attempt at this but it only records one of the errors and doesnt stop the script from runnning.  I am using sql 2005 hence why im calling sqlcmd:-
ForEach ($S In Gci -Path "C:\Temp\Scripts\" -Filter *.sql | Sort-Object Name) 
{
 try 
{ SqlCmd -b -S Server -i $S.FullName } 
catch 
{ $_ | Out-File C:\Temp\Scripts\sqllogging.txt} 
} 
#Help would be gratefully received on this.
#Thanks 
#Chris
#Chad Miller
#Basic Member
#
#Posts:198
#02 Aug 2012 06:23 AM
#A couple of things. First calling exes in Powershell doesn't behave the same way as calling cmdlets when it comes to error handling. Exe's often rely on exit codes and not writing to standard error. So, you'll need to check the $LASTEXITCODE variable. This variable is set on calls to exe's, bat files, etc. Second since you want to stop execution you'll need to set the $ERRORACTIONPERFERENCE to stop. Here's a re-worked script: 
$ErrorActionPreference = "Stop"
ForEach ($S In Gci -Path "C:\Temp\Scripts\" -Filter *.sql | Sort-Object Name) {
    try { 
    $result = SqlCmd -b -S Server -i $S.FullName
    $result = $result -join "`n"
    if ($LASTEXITCODE -ne 0) {
        throw "$S.FullName : $lastexitcode : $result"
    } 
    catch {
        $_ | Out-File C:\Temp\Scripts\sqllogging.txt
    } 
}
#umplebyc
#New Member
#
#Posts:10
#03 Aug 2012 01:39 AM
#Thanks for the response Chad, worked a treat after i added an additionl } before catch. Another addition i had to add to run it in name order was -desecending at the end of the sort-object section, without this is was starting at the bottom and working up so if i had the following file 001, 002, 003, 998, 999, it was starting at 999, with the -descending in it now starts at 001. One last question would be, is there a way to output the success of the query before it moves onto the next query, like the statuts you get when you ruyn the query within SQL at the bottom of the screen (Query Executed successfully)? 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#03 Aug 2012 03:36 AM
#You've the $result variable which contains any output return from the query. You could use: $result | out-file or write-output $result to display on screen.
#umplebyc
#New Member
#
#Posts:10
#03 Aug 2012 05:52 AM
#Thanks Chad, looks like im going backwards with this now. The scripts are not running in any order now, the SQL Scripts named 001, 002 and 003 run regardless of error, it will stop at 998 if errors before running 999. As mentioned we could have 60 to 70 individual sql scripts that we need to run in name order, report the status of the script run, if an error report the error with the script filename that errored. Sorry to be a pain, but im new to advanced powershell scripting. within 001, 002 and 003 all im doing is creating a Test Stored Procedure on a testdb, in 998 and 999 im running a sql script to connect to a Databases that doesnt exist on the server, hence causing an error. Thanks for your help so far.
#Chad Miller
#Basic Member
#
#Posts:198
#03 Aug 2012 11:00 AM
#You say the scripts are not running in an order, does this command by itself return the expected results? 
Gci -Path "C:\Temp\Scripts\" -Filter *.sql | Sort-Object Name)
#umplebyc
#New Member
#
#Posts:10
#09 Aug 2012 12:43 AM
#The command does return the expected results:- 
Directory: C:\Temp\Scripts 
Mode LastWriteTime Length Name 
---- ------------- ------ ---- 
-a--- 03/08/2012 10:34 76 001 SP_A .sql 
-a--- 01/08/2012 15:17 127 002 KERNEL Version.sql 
-a--- 01/08/2012 14:14 76 004 SP_B.sql 
-a--- 13/07/2012 16:10 125 998 KERNEL Version.sql 
-a--- 01/08/2012 14:15 76 999 SP_C.sql 
#However 001, 004 and 999 run even if a failure occurs in 002, what i am looking for is 001 to run if ok output filename and job statuts ok and continue to next file, 002 if fail output failure with the filename and stop processing, 004 will not run at all. 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#09 Aug 2012 03:26 AM
#I did a quick test and noticed you need to rethrow the error after logging it. Change you catch block to this: 
catch {
        $_ | Out-File C:\Temp\Scripts\sqllogging.txt
        throw
    }

#umplebyc
#New Member
#
#Posts:10
#15 Aug 2012 12:44 AM
#Thanks Chad, SQL Scripts are still runing even if a failure happens. The log is still only picking up error and not success and it is not recording the file that run's. An example of the log is:- 
Changed database context to 'TESTDB'. 
Msg 911, Level 16, State 1, Server YK-P-LAP-0006, Line 1 
Database 'KERNELDB' does not exist. Make sure that the name is entered correctly. 
Changed database context to 'TESTDB'. 
Msg 911, Level 16, State 1, Server YK-P-LAP-0006, Line 1 
Database 'KERNEL' does not exist. Make sure that the name is entered correctly. 
Changed database context to 'TESTDB'. 
The KERNELDB Error is from file 002 KERNEL Version.sql file 
The KERNEL Error is from file 998 KERNEL Version.sql file 
The following are still running regardless of error 
001 SP_A.sql 
004 SP_B.sql 
999 SP_C.sql 
#Thanks for your help on this. 
#umplebyc
#New Member
#
#Posts:10
#15 Aug 2012 04:37 AM
#Hi Chad, just to let you know the logging is working to an extent, it is recording the file and the result of the Query, but not the Success section, ive removed the lastexitcode section so all i have at the moment is $S and $Result passing into the log file, is their a variable to use to extract the Message from SQL you get when you run in a query window "Command(s) completed successfully." Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#19 Aug 2012 10:08 AM
#I can create a simple case which does causes execution of additional scripts to stop. I'm not sure what you're doing wrong, but take a look at my test script. Notice script 3 isn't being run and the output to the log shows the following: 
Success: C:\Temp\Scripts\1.sql : 
------ 
Good 1 
(1 rows affected) 
Failed: 2.sql.FullName : 1 : Msg 208, Level 16, State 1,... 
echo "select 'Good 1'" > C:\temp\scripts\1.sql
echo "select * from missingTable" > C:\temp\scripts\2.sql
echo "Select 'Good 3'" > C:\temp\scripts\3.sql
$ErrorActionPreference = "Stop"
ForEach ($S In Gci -Path "C:\Temp\Scripts\" -Filter *.sql | Sort-Object Name) {
try { 
    $result = SqlCmd -b -S $env:computername\sql1 -i $S.FullName
    $result = $result -join "`n"
    if ($LASTEXITCODE -ne 0) {
        throw "$S.FullName : $lastexitcode : $result"
    } else {
        write-output "Success: $($s.fullname) : $result" | Out-File C:\Temp\Scripts\sqllogging.txt -Append
    } 
    }
catch {
    write-output "Failed: $_ " | Out-File C:\Temp\Scripts\sqllogging.txt -Append
    throw
}
#Chad Miller
#Basic Member
#
#Posts:198
#19 Aug 2012 10:11 AM
#The code editor in this forum is horrible. Here's the code posted again. 
echo "select 'Good 1'" > C:\temp\scripts\1.sql
echo "select * from missingTable" > C:\temp\scripts\2.sql
echo "Select 'Good 3'" > C:\temp\scripts\3.sql
$ErrorActionPreference = "Stop"
ForEach ($S In Gci -Path "C:\Temp\Scripts\" -Filter *.sql | Sort-Object Name) {
    try { 
        $result = SqlCmd -b -S $env:computername\sql1 -i $S.FullName
        $result = $result -join "`n"
        if ($LASTEXITCODE -ne 0) {
            throw "$S.FullName : $lastexitcode : $result"
        }
        else {
            write-output "Success: $($s.fullname) : $result" | Out-File C:\Temp\Scripts\sqllogging.txt -Append
        }
    }
    catch {
        write-output "Failed: $_ " | Out-File C:\Temp\Scripts\sqllogging.txt -Append
        throw
    } 
}
#umplebyc
#New Member
#
#Posts:10
#23 Aug 2012 03:33 AM
#Thanks So much Chad, it's working a treat now, it is now failing where it should be and not continuing. Appreciate your help with this.
#Forums > Using PowerShell > SQL Server
#Active Forums 4.3
#####################
#Forums > Using PowerShell > SQL Server
#Using SQLConnection object
#Last Post 25 Jul 2012 12:42 PM by mg48. 3 Replies.
#AuthorMessages
#gbritton
#New Member
#
#Posts:2
#25 Jul 2012 05:45 AM
#I want to use the SQLConnection object as I would from vb, for example.  I'd like to do this:
#e.g.
$conn = New-Object system.data.sqlclient.sqlconnectionstringbuilder
$conn.DataSource = 'myserver'
but this fails:
Keyword not supported: 'DataSource'.
At line:1 char:4
+ $conn. <<<< DataSource = 'myserver'
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : PropertyAssignmentException
#even though:
PS C:\WINDOWS\system32\WindowsPowerShell> $conn|Get-Member *sour*
   TypeName: System.Data.SqlClient.SqlConnectionStringBuilder
Name       MemberType Definition
----       ---------- ----------
DataSource Property   System.String DataSource {get;set;}
My Powershell version:
PS C:\WINDOWS\system32\WindowsPowerShell> $PSVersionTable
Name                           Value
----                           -----
CLRVersion                     2.0.50727.3634
BuildVersion                   6.0.6002.18111
PSVersion                      2.0
WSManStackVersion              2.0
PSCompatibleVersions           {1.0, 2.0}
SerializationVersion           1.1.0.1
PSRemotingProtocolVersion      2.1
#What is causing the error message?
#mg48
#New Member
#
#Posts:26
#25 Jul 2012 06:00 AM
$conn["Data Source"] = "myserver"
#gbritton
#New Member
#
#Posts:2
#25 Jul 2012 07:56 AM
#Yes, I know that works. I want to know why it fails the other way. FWIW, this works: 
$conn.database = 'mydb' 
#(and sets the property 'InitialCatalog') 
#and this fails 
$conn.initialcatalog = 'mydb' 
#even though: 
PS C:\WINDOWS\system32\WindowsPowerShell> $b|Get-Member initialcatalog 
TypeName: System.Data.SqlClient.SqlConnectionStringBuilder 
Name MemberType Definition 
---- ---------- ---------- 
InitialCatalog Property System.String InitialCatalog {get;set;} 
#What I'm confused about is why I can set the "database" property even though it's not in the member list, but I cannot set the properties in the member list, even though PS says that they are set-able.
#mg48
#New Member
#
#Posts:26
#25 Jul 2012 12:42 PM
#I believe that this is a known bug and and has been reported and acknowleded in Connect. It has't been fixed yet. 
http://connect.microsoft.com/PowerS...ingbuilder 
#Forums > Using PowerShell > SQL Server
#Active Forums 4.3
#####################
#Forums > Using PowerShell > SQL Server
#How to handle Binary and xml columns in powershell
#Last Post 24 Jul 2012 04:41 AM by Chad Miller. 5 Replies.
#AuthorMessages
#PrakashHeda
#New Member
#
#Posts:3
#18 Jul 2012 04:51 PM
#After 2 days of googling and trying various method nothing works, thus I am here to ask THE EXPERTS....Please help...
#Issue: I am trying to extract binary and XML data from sql server DMVs and saving it into xml using 
#Export-Clixml cmdlets, import export from xml seems working fine though issue is when I am trying to upload that binary and xml data to sql server its giving error , I tried using out-DataTable function but no help, this fuction is not designed to handle these data types....
#I found cdata is the way to handle binary characters in XML but couldnt make it work 
#To try this scenario, create below table and execute below script... 
#-- Load table schema 
CREATE TABLE tempdb.[dbo].[tbltest22]( 
[dbid] [smallint] NULL, 
[sql_handle] [varbinary](64) NOT NULL, 
[query_plan] [xml] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY] 
GO
CLS
Function
out-DataTable 
{
$dt = new-object Data.datatable 
$First = $true 
foreach ( $item in $input ){ 
$DR = $DT .NewRow() 
$Item .PsObject.get_properties() | foreach { 
if ( $first ) { 
$Col = new-object Data.DataColumn 
$Col .ColumnName = $_ .Name.ToString() 
$Col .DataType = $_ .TypeNameOfValue
$DT .Columns.Add( $Col ) 
} 
if ( $_ .value -eq $null ) { 
$DR .Item( $_ .Name) = "[empty]" 
} 
elseif ( $_ .IsArray) { 
$DR .Item( $_ .Name) =[ string ]:: Join ( $_ .value , ";" ) 
} 
else { 
$DR .Item( $_ .Name) = $_ .value 
} 
} 
$DT .Rows.Add( $DR ) 
$First = $false 
} 
return @(,( $dt ))
}
Import-Module
'sqlps' –DisableNameChecking 
$MainScript
= $MyInvocation
$ScriptDir
= split-path -parent $MainScript . MyCommand .Path 
set-location
$ScriptDir -PassThru 
$DBServer
= gc env:computername 
$ScriptNameWithoutExt
=[ system.io.path ]:: GetFilenameWithoutExtension ( $MainScript . MyCommand .Path) 
$Query
= 
"
SELECT top 1 deqp.dbid ,
sql_handle
,deqp.query_plan
FROM sys.dm_exec_query_stats deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
where query_plan is not null
"
$CheckBackupMaster
= Invoke-Sqlcmd -ServerInstance $DBServer -Database "master" -Query $Query
$CheckBackupMaster
| Export-Clixml $ScriptDir \ $ScriptNameWithoutExt .xml 
$CheckBackupMasterLoaded
= Import-CliXML $ScriptDir \ $ScriptNameWithoutExt .xml 
$CheckBackupMasterLoaded
| out-DataTable 
$connectionString
= "Data Source=$DBServer;Integrated Security=true;Initial Catalog=master;" ; 
$bulkCopy
= new-object ( "Data.SqlClient.SqlBulkCopy" ) $connectionString ; 
$bulkCopy
. DestinationTableName = "tempdb..tbltest22" ; 
$bulkCopy
. WriteToServer ( $CheckBackupMasterLoaded );
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jul 2012 04:17 AM
#Is there a reason you need to export to CLIXML? If not you could simplify your script as follows: 
#Edited: To address XML truncation. By default invoke-sqlcmd only returns 4,000 characters. You need to set the MaxCharLength 
import-module sqlps -DisableNameChecking -Force
$ServerInstance = "$env:computername\sql1"
$Database = "tempdb"
$Query = @"
CREATE TABLE tempdb.[dbo].[tbltest22]( 
[dbid] [smallint] NULL, 
[sql_handle] [varbinary](max) NOT NULL,
[query_plan] [xml] NULL
)
"@
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "tempdb" -Query $Query
$Query = @"
SELECT top 1 deqp.dbid, sql_handle, deqp.query_plan
FROM sys.dm_exec_query_stats deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
where query_plan is not null
"@
$dt = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "master" -Query $Query -MaxCharLength 65000
$connectionString = "Server={0};Database={1};Integrated Security=True" -f $ServerInstance,$Database
$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
$bulkCopy.DestinationTableName = "tbltest22" 
$bulkCopy.WriteToServer($dt)
#PrakashHeda
#New Member
#
#Posts:3
#19 Jul 2012 10:15 AM
#I send scripts to my client and ask them to run and send me the output, which i import in db to analyze 
#Based on my reserch there are no straightforard way to store binary and xml data (excel,csv,export wizard failed), only way is to store in a new db and send it over (which is not a good way as it require a production ticket to create a new db) 
#so idea is to use powershell to collect this data and send it over for me to analyze 
#I need help here as only option left is to ask them to create a database and store multiple outputs in them (and i prefer if data is stored in xml or some other generic format)
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jul 2012 02:36 PM
#After bit of digging I came up with a solution to use BCP to generate a file and bulk insert to load into a SQL table: 
import-module sqlps -DisableNameChecking -Force
$ServerInstance = "$env:computername\sql1"
$Database = "tempdb"
$Query = @"
CREATE TABLE tempdb.[dbo].[tbltest22]( 
[dbid] [smallint] NULL, 
[sql_handle] [varbinary](64) NOT NULL,
[query_plan] [xml] NULL
)
"@
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "tempdb" -Query $Query
$Query = "SELECT top 1 deqp.dbid, sql_handle, deqp.query_plan FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp where query_plan is not null"
bcp "$query" queryout C:\Users\Public\bin\qplan.dat -N -S $ServerInstance -T
$query = @"
BULK INSERT tbltest22 
    FROM 'C:\Users\Public\bin\qplan.dat' 
   WITH (DATAFILETYPE='widenative'); 
"@
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "tempdb" -Query $Query
#PrakashHeda
#New Member
#
#Posts:3
#23 Jul 2012 03:00 PM
#Posted By Chad Miller on 19 Jul 2012 03:36 PM 
#After bit of digging I came up with a solution to use BCP to generate a file and bulk insert to load into a SQL table: 
#Chad Miller.....you are the man:) solution works like a magic 
#Can believe on this issue I spend 16 productive hours searching debugging, never knew bcp has capability to manage these data types:)
#Though one day i would like to rely completely on XML (using cdata in xml to manage these)
#Chad Miller
#Basic Member
#
#Posts:198
#24 Jul 2012 04:41 AM
#We're welcome that was an interesting problem.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Working with Record Set with Powershell
#Last Post 10 Jul 2012 02:27 AM by ChesterLee. 4 Replies.
#AuthorMessages
#andrew_g
#New Member
#
#Posts:2
#05 Jun 2012 11:02 PM
#Hi Everyone,
#I'm sure someone can help me here... I'm a relative newbie to powershell...
#Got the below powershell script to query one of our databases to check the “LastUpdated” field from the first record in “tblSetupData”. I want to make sure that it’s equal to “$Today”, you can get the rest from below.. ? I’m certain that I haven’t got the "if ( $objRecords -eq $Today )" record set part right… Someone point me in the right direction? Thanks guys! 
#------------------------------- 
$strConnectionString = "Driver={SQL Server};Server=%SQLServerName%;Database=%DB_Name%; UID=%user%; PWD=%password%" 
$objConn = new-object -comobject ADODB.Connection 
$objRecords = new-object -comobject ADODB.Recordset 
$Today = Get-Date -format dd/MM/yyyy 
trap [Exception] 
{ 
$res = "UNCERTAIN: " + $_.Exception.Message echo 
$res 
# exit 
} 
$objConn.Open($strConnectionString) 
$strQuery = "SELECT TOP 1 [LastUpdated] FROM [tblSetupData]" 
$objRecords.Open($strQuery,$objConn) 
if ( $objRecords -eq $Today ) 
{ 
$res = "SUCCESS: Criteria matched Required field value of [" + $Today + "]" 
echo $res 
$objConn.Close() 
# exit 
} 
#------------------------------- 
#Andrew
#Chad Miller
#Basic Member
#
#Posts:198
#06 Jun 2012 05:16 AM
#You're using old style COM-based ADO instead of ADO.NET also you're error handling is using the old style trap Powershell V1 instead of try/catch/finally. Here's a rewritten and tested example: 
$Today = Get-Date -format dd/MM/yyyy
$ServerInstance = 'Win7boot\sql1'
$Database = 'tempdb'
$Username = 'sa'
$Password = '****'
$Query = @"
SELECT TOP 1 [LastUpdated] FROM [tblSetupData]
WHERE [Lastupdated] = '$Today'
"@
    try
    {
        $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False" -f $ServerInstance,$Database,$Username,$Password
        $connection = New-Object System.Data.SqlClient.SQLConnection($connectionString)
        
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandType = [System.Data.CommandType]::Text
        $command.CommandText = $Query
        
        $dataSet = New-Object System.Data.DataSet
        $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        [void]$dataAdapter.Fill($dataSet)
        
        if ($dataSet.Tables[0] -ne $null)
        { "SUCCESS: Criteria matched Required field value of [" + $Today + "]" }
        else
        { "FAILURE: Criteria not matched Required field value of [" + $Today + "]" }
    }
   catch {
    throw "UNCERTAIN: $($_.Exception.Message)"
   }
    finally
    {
      $connection.Dispose()
    }
#andrew_g
#New Member
#
#Posts:2
#06 Jun 2012 03:47 PM
#Hi Chad, 
#Thats great, thanks very much.. One last question, with the above code, the dataset that's returned isn't just the date, it also includes the column header, whats the best way of just returning the date string itself? 
#Thanks again, 
#Andrew
#Chad Miller
#Basic Member
#
#Posts:198
#07 Jun 2012 04:06 AM
$date = $dataSet.Tables[0] | select -expandproperty Lastupdated
##or
$date = $dataSet.Tables[0] | foreach { $_.Lastupdated }
#ChesterLee
#New Member
#
#Posts:2
#10 Jul 2012 02:27 AM
#The worried citizen doesn't always have time to get a camera out if they want to record an encounter with law enforcement. The American Civil Liberties Union, however, would like to make it simpler, as there are two ACLU police recording apps accessible for Android smart phone consumers. Get car loan financing for your new car. A lot of cops that have been doing something illegal are not being caught by the authorities because they cannot present any evidence to prove some claims. So if you ever caught some these cops on cam, you might as well present it to the authorities so that they will be able to do something about it.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Using Log Parser with CSVs
#Last Post 23 Jun 2012 05:53 AM by djh53. 2 Replies.
#AuthorMessages
#djh53
#New Member
#
#Posts:31
#23 Jun 2012 12:50 AM
#Thought I’d experiment with Log Parser to read some census CSVs released by the Australian Bureau of Statistics a couple of days ago.  The code is based on an example by Chad Miller:  http://blogs.technet.com/b/heyscrip...shell.aspx
$logQuery = new-object -ComObject "MSUtil.LogQuery"
  
$inputFormat = new-object -comobject "MSUtil.LogQuery.CSVInputFormat"
  
$outputFormat = new-object -comobject "MSUtil.LogQuery.SQLOutputFormat"
  
$outputFormat.server = "HOMEPC/SQLEXPRESS"
  
$outputFormat.database = "WA2012"
  
$outputFormat.driver = "SQL Server"
  
$outputFormat.createTable = $true
  
$query = "SELECT region_id,Tot_P_M,Tot_P_F,Tot_P_P,
Age_0_4_yr_M,Age_0_4_yr_F,Age_0_4_yr_P,Age_5_14_yr_M,Age_5_14_yr_F,Age_5_14_yr_P,Age_15_19_yr_M,Age_15_19_yr_F,Age_15_19_yr_P,Age_20_24_yr_M,Age_20_24_yr_F,Age_20_24_yr_P,Age_25_34_yr_M,Age_25_34_yr_F,Age_25_34_yr_P,Age_35_44_yr_M,Age_35_44_yr_F,
Age_35_44_yr_P,Age_45_54_yr_M,Age_45_54_yr_F,Age_45_54_yr_P,Age_55_64_yr_M,Age_55_64_yr_F,Age_55_64_yr_P,Age_65_74_yr_M,Age_65_74_yr_F,Age_65_74_yr_P,Age_75_84_yr_M,Age_75_84_yr_F,Age_75_84_yr_P,Age_85ov_M,Age_85ov_F,Age_85ov_P,
Counted_Census_Night_home_M,Counted_Census_Night_home_F,Counted_Census_Night_home_P,[Count_Census_Nt_Ewhere_Aust_M],[Count_Census_Nt_Ewhere_Aust_F],[Count_Census_Nt_Ewhere_Aust_P],
Indigenous_psns_Aboriginal_M,Indigenous_psns_Aboriginal_F,Indigenous_psns_Aboriginal_P,Indig_psns_Torres_Strait_Is_M,Indig_psns_Torres_Strait_Is_F,Indig_psns_Torres_Strait_Is_P,Indig_Bth_Abor_Torres_St_Is_M,Indig_Bth_Abor_Torres_St_Is_F,
Indig_Bth_Abor_Torres_St_Is_P,Indigenous_P_Tot_M,Indigenous_P_Tot_F,Indigenous_P_Tot_P,Birthplace_Australia_M,Birthplace_Australia_F,Birthplace_Australia_P,Birthplace_Elsewhere_M,Birthplace_Elsewhere_F,Birthplace_Elsewhere_P,
Lang_spoken_home_Eng_only_M,Lang_spoken_home_Eng_only_F,Lang_spoken_home_Eng_only_P,Lang_spoken_home_Oth_Lang_M,Lang_spoken_home_Oth_Lang_F,Lang_spoken_home_Oth_Lang_P,
Australian_citizen_M,Australian_citizen_F,Australian_citizen_P,Age_psns_att_educ_inst_0_4_M,Age_psns_att_educ_inst_0_4_F,Age_psns_att_educ_inst_0_4_P,Age_psns_att_educ_inst_5_14_M,Age_psns_att_educ_inst_5_14_F,Age_psns_att_educ_inst_5_14_P,
Age_psns_att_edu_inst_15_19_M,Age_psns_att_edu_inst_15_19_F,Age_psns_att_edu_inst_15_19_P,Age_psns_att_edu_inst_20_24_M,Age_psns_att_edu_inst_20_24_F,Age_psns_att_edu_inst_20_24_P,Age_psns_att_edu_inst_25_ov_M,Age_psns_att_edu_inst_25_ov_F,
Age_psns_att_edu_inst_25_ov_P,High_yr_schl_comp_Yr_12_eq_M,High_yr_schl_comp_Yr_12_eq_F,High_yr_schl_comp_Yr_12_eq_P,High_yr_schl_comp_Yr_11_eq_M,High_yr_schl_comp_Yr_11_eq_F,High_yr_schl_comp_Yr_11_eq_P,
High_yr_schl_comp_Yr_10_eq_M,High_yr_schl_comp_Yr_10_eq_F,High_yr_schl_comp_Yr_10_eq_P,High_yr_schl_comp_Yr_9_eq_M,High_yr_schl_comp_Yr_9_eq_F,High_yr_schl_comp_Yr_9_eq_P,High_yr_schl_comp_Yr_8_belw_M,High_yr_schl_comp_Yr_8_belw_F,
High_yr_schl_comp_Yr_8_belw_P,High_yr_schl_comp_D_n_g_sch_M,High_yr_schl_comp_D_n_g_sch_F,High_yr_schl_comp_D_n_g_sch_P,[Count_psns_occ_priv_dwgs_M],[Count_psns_occ_priv_dwgs_F],[Count_psns_occ_priv_dwgs_P],
[Count_Persons_other_dwgs_M],[Count_Persons_other_dwgs_F],[Count_Persons_other_dwgs_P]
 INTO diskspaceLPCOM FROM C:\Users\Dave\Documents\_Census2012\WA\2011Sample_B01_WA_STE_short.csv"
 $null = $logQuery.ExecuteBatch($query,$inputFormat,$outputFormat)
#The code errors out as follows:
Exception calling "ExecuteBatch" with "3" argument(s): "Error executing query: Error connecting to ODBC Server
SQL State:     08001
Native Error:  17
Error Message: [Microsoft][ODBC SQL Server Driver][DBNETLIB]SQL Server does not exist or access denied.
 [Unknown Error]"
At C:\Users\Dave\Documents\POSH\SQL\ImportCSVs\LogParser COM Demo.ps1:34 char:31
+ $null = $logQuery.ExecuteBatch <<<< ($query,$inputFormat,$outputFormat)
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : ComMethodTargetInvocation
  
#As one who is old enough to recall walking around to individual PCs to set ODBC DSNs, I now try to avoid ODBC wherever possible.  Hence, there is no SQL ODBC DSN on my PC.
#I realise Log Parser is ancient history, and this is not urgent. I sorted the problem with a Word macro that reads in the metadata I need.  However, I’m curious.  Is there a way to use Log Parser with SQL 08 R2 Express without using ODBC?
#Jonathan
#Basic Member
#
#Posts:175
#23 Jun 2012 04:11 AM
#try HOMEPC\SQLEXPRESS (change the direction of your slash)
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#djh53
#New Member
#
#Posts:31
#23 Jun 2012 05:53 AM
#Chuckle!  That's all it was.
#TY!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL Server Backups status
#Last Post 22 Jun 2012 05:19 PM by Chad Miller. 2 Replies.
#AuthorMessages
#swamy
#New Member
#
#Posts:9
#22 Jun 2012 06:40 AM
#I am looking for all sql instances backup status script whether backup was successfully done or not need to verify for all sql instances.
#If any body has written this please share me
#swamy
#New Member
#
#Posts:9
#22 Jun 2012 09:50 AM
#Given list of instances.txt, I would like to verify the daily backups on these instances. Whether the database backup has been successfull/failed. 
#I am new to Powershell scripting, if any body has readily available script please share me other wise please give me out line for this. 
#Thanks!
#Chad Miller
#Basic Member
#
#Posts:198
#22 Jun 2012 05:19 PM
#I implemented something like this which mainly uses T-SQL and Powershell for collection. Here's a wrote about it: 
#http://www.sqlservercentral.com/art...ell/68011/
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Sending mail using Powershell
#Last Post 21 Jun 2012 08:56 AM by Jonathan. 1 Replies.
#AuthorMessages
#swamy
#New Member
#
#Posts:9
#21 Jun 2012 07:04 AM
#I would like to send mail respective group id's for my jobs informations
#Please help me how to write PS script for below
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null; $today = (Get-Date).ToShortDateString() $a = "" $a = $a + "BODY{background-color:peachpuff;}" $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}" $a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}" $a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}" $a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}" $a = $a + "" 
#Get-Content "D:\instance.txt" | foreach { $sqlserver = $_; $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver; $srv.Jobserver.Jobs } | where { $_.IsEnabled -and $_.LastRunDate -and (New-TimeSpan $_.LastRunDate $today).Days -le 1 -and $_.LastRunOutcome -eq "Succeeded" } | select @{n='SERVER';e={$sqlserver}}, Name, LastRunOutcome, LastRunDate | ConvertTo-Html -head $a| Out-File c:\joboutput_new.htm
#Jonathan
#Basic Member
#
#Posts:175
#21 Jun 2012 08:56 AM
#Hi Swamy, 
#Assuming that the code you have provided here works, you can use the Send-MailMessage cmdlet to send the files as attachments. Once you get your files saved, you can then enumerate through the created files and add them as attachments to whomever you wish. Additionally, you could do it inline by passing the data into the -Body parameter of the Send-MailMessage along with the -BodyAsHTML parameter with it. If you need the information saved on the server for reference later, then I would go with the first option (save and send the attachments), but if that doesn't matter, you can create the reports and send out as you create them. 
#To find full information on the Send-MailMessage cmdlet, you can look locally on your Powershell console: 
#help Send-MailMessage -detailed 
#or you can go online and get the information: 
#help Send-MailMessage -online 
#Hope that helps.
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell convert to HTML
#Last Post 06 Jun 2012 10:16 AM by Chad Miller. 6 Replies.
#AuthorMessages
#swamy
#New Member
#
#Posts:9
#01 Jun 2012 06:23 AM
#Hi all,
#How to convert query result to HTML in powershell?
#Swamy
#Chad Miller
#Basic Member
#
#Posts:198
#01 Jun 2012 08:08 AM
#Powershell has a built-in cmdlet, convertto-html. See the help for this cmdlet by running 
#help convertto-html -full 
#Now if you're using the SQL Server Powershell cmdlet invoke-sqlcmd you can pipe the output to convertto-html then its output to a file: 
#Invoke-Sqlcmd -ServerInstance Z001\sql1 -Database pubs -Query "select * from authors" | select au_lname, au_fname | ConvertTo-Html | out-file -FilePath ./test.html
#swamy
#New Member
#
#Posts:9
#05 Jun 2012 06:05 AM
#Chad thanks for the response! I am new to Powershell, below is my script it will list the succeeded sql jobs in the query result. 
#Now I am planning to get the information into html file in D:\output.html, I tried directly convertto-html but it is not working. 
#Can you suggest me how to modify the script. 
#Very much appreciated your help!!! 
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null; 
##let's get our list of servers. For this, create a .txt files with all the server names you want to check. 
#$sqlservers = Get-Content "D:\instance.txt"; 
##we'll get the long date and toss that in a variable 
#$datefull = Get-Date 
##and shorten it 
#$today = $datefull.ToShortDateString() 
##let's set up the email stuff 
#$msg = new-object Net.Mail.MailMessage 
#$msg.Body = “Here is a list of failed SQL Jobs for $today (the last 24 hours)” 
##here, we will begin with a foreach loop. We'll be checking all servers in the .txt referenced above. 
#foreach($sqlserver in $sqlservers) 
#{ 
##here we need to set which server we are going to check in this loop 
#$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver; 
##$msg.body= "here is first instance hello", $srv 
##now let's loop through all the jobs 
#foreach ($job in $srv.Jobserver.Jobs) 
#{ 
##now we are going to set up some variables. 
##These values come from the information in $srv.Jobserver.Jobs 
#$jobName = $job.Name; 
#$jobEnabled = $job.IsEnabled; 
#$jobLastRunOutcome = $job.LastRunOutcome; 
#$jobLastRun = $job.LastRunDate; 
##we are only concerned about jobs that are enabled and have run before. 
#if($jobEnabled = "true" -and $jobLastRun) 
#{ 
## we need to find out how many days ago that job ran 
#$datediff = New-TimeSpan $jobLastRun $today 
##now we need to take the value of days in $datediff 
#$days = $datediff.days 
##$msg.body= "here is first instance Hiii" 
##gotta check to make sure the job ran in the last 24 hours 
#if($days -le 1 ) 
#{ 
##and make sure the job failed 
#IF($jobLastRunOutcome -eq "Succeeded") 
#{ 
##now we add the job info to our email body. use `n for a new line 
#$msg.body = $msg.body + "`n `n FAILED JOB INFO is: 
#SERVER = $sqlserver 
#JOB = $jobName 
#LASTRUN = $jobLastRunOutcome 
#LASTRUNDATE = $jobLastRun" 
##$msg.body= "here is first instance Hiaaaaaaaaaa" 
#} 
#} 
#} 
#} 
#} 
##Out-File = SERVER,JOB,LASTRUN,LASTRUNDATE | ConvertTo-Html | Set-Content c:\joboutput.htm 
##once all that loops through and builds our $msg.body, we are read to send 
##printing the body 
#$msg.Body 
##who is this coming from 
##$msg.From = “siri@siri.com” 
##and going to 
##$msg.To.Add(”siri@siri.com") 
##and a nice pretty title 
##$msg.Subject = “FAILED SQL Jobs for $today” 
##HAPPY FAILURE! 
##$smtp.Send($msg) 
#Chad Miller
#Basic Member
#
#Posts:198
#06 Jun 2012 04:47 AM
#You got a lot going on in your script other than outputting HTML. Just looking at the HTML portion we can rewrite like this: 
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null; 
#$today = (Get-Date).ToShortDateString() 
#Get-Content "D:\instance.txt" | foreach { $sqlserver = $_; $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver; $srv.Jobserver.Jobs } |
#    where { $_.IsEnabled -and $_.LastRunDate -and (New-TimeSpan $_.LastRunDate $today).Days -le 1 -and $_.LastRunOutcome -eq "Succeeded" } |
#        select @{n='SERVER';e={$sqlserver}}, Name, LastRunOutcome, LastRunDate | ConvertTo-Html | Out-File c:\joboutput.htm 
#swamy
#New Member
#
#Posts:9
#06 Jun 2012 06:59 AM
#I am new to Powershell, trying to implement PS for generating reports to HTML. I'm getting below unexpected token error coming. Please help me.
# [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null; $today = (Get-Date).ToShortDateString() Get-Content "D:\instance.txt" | foreach { $sqlserver = $_; $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver; $srv.Jobserver.Jobs } | where { $_.IsEnabled -and $_.LastRunDate -and (New-TimeSpan $_.LastRunDate $today).Days -le 1 -and $_.LastRunOutcome -eq "Succeeded" } | select @{n='SERVER';e={$sqlserver}}, Name, LastRunOutcome, LastRunDate | ConvertTo-Html | Out-File c:\joboutput.htm 
# 
#Unexpected token 'Get-Content' in expression or statement. At line:1 char:137 Unexpected token 'D:\instance.txt' in expression or statement. At line:1 char:149 An empty pipe element is not allowed. At line:1 char:167 Missing statement after '=' in hash literal. At line:1 char:465
#Thanks!
#Swamy
# 
# 
# 
# 
#swamy
#New Member
#
#Posts:9
#06 Jun 2012 07:02 AM
#ignore previous error. Below error I'm getting when i execute ps script
#The term 'System.Reflection.Assembly]::LoadWithPartialName' is not recognized a s the name of a cmdlet, function, script file, or operable program. Check the s pelling of the name, or if a path was included, verify that the path is correct and try again. At line:1 char:49 + System.Reflection.Assembly]::LoadWithPartialName <<<< ("Microsoft.SqlServer.S MO") | out-null; + CategoryInfo : ObjectNotFound: (System.Reflecti...WithPartialNa me:String) [], CommandNotFoundException + FullyQualifiedErrorId : CommandNotFoundException
#Chad Miller
#Basic Member
#
#Posts:198
#06 Jun 2012 10:16 AM
#Why is your code all on one line? 
#It looks like your missing a beginning opening bracket i.e. 'System.Reflection.Assembly]::LoadWithPartialName instead of [System.Reflection.Assembly]::LoadWithPartialName.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL Server 2012 snapins
#Last Post 05 Jun 2012 07:50 AM by pnelsonsr. 16 Replies.
#AuthorMessages
#pnelsonsr
#New Member
#
#Posts:9
#25 Apr 2012 02:16 PM
#I have the following environment:
#Windows 7 64 bit
#SQL Server 2012 RC0 64 bit
#When I start up PowerShell It always shows:
#---snip---
#Windows PowerShell
#Copyright (C) 2009 Microsoft Corporation. All rights reserved. 
#Errors occurred while importing the modules. To view the errors, type "$error".
#PS C:\Users\pjn>
#---snip---
#If I print out $error" it shows:
#---snip---
#PS C:\Users\pjn> $error
#Add-PSSnapin : Cannot load Windows PowerShell snap-in SqlServerProviderSnapin100 because of the following error: Could not load file or assembly 'file:///c:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\Microsoft.SqlServer.Management.PSProvider.dll' or one of its dependencies. The system cannot find the file specified.
#At line:14 char:29
#+ Add-PSSnapin <<<< $_ -ErrorAction SilentlyContinue
#+ CategoryInfo : InvalidArgument: (SqlServerProviderSnapin100:String) [Add-PSSnapin], PSSnapInException
#+ FullyQualifiedErrorId : AddPSSnapInRead,Microsoft.PowerShell.Commands.AddPSSnapinCommand 
#Add-PSSnapin : Cannot load Windows PowerShell snap-in SqlServerCmdletSnapin100 because of the following error: Could not load file or assembly 'file:///c:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\Microsoft.SqlServer.Management.PSSnapins.dll' or one of its dependencies. The system cannot find the file specified.
#At line:14 char:29
#+ Add-PSSnapin <<<< $_ -ErrorAction SilentlyContinue
#+ CategoryInfo : InvalidArgument: (SqlServerCmdletSnapin100:String) [Add-PSSnapin], PSSnapInException
#+ FullyQualifiedErrorId : AddPSSnapInRead,Microsoft.PowerShell.Commands.AddPSSnapinCommand
#---snip---
#I looked all over and found the dlls in "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS" so my question is how to I uninstall the old one and have it point towards to new one? 
#Chad Miller
#Basic Member
#
#Posts:198
#26 Apr 2012 03:41 AM
#Are you running Add-PSSnapin in one of your Powershell profiles?
#mg48
#New Member
#
#Posts:26
#26 Apr 2012 04:43 AM
#It looks like your profile has the Add-PSSnapin syntax in it. SQL 2012 doesn't use that. It needs Import-Module SqlServer so replace the Add-PSSnapins with that.  JIC - an easy way to edit your profile --> notepad $profile. 
#Hope this does it for you.
#pnelsonsr
#New Member
#
#Posts:9
#26 Apr 2012 07:47 AM
#I looked at my $profile and all that is listed is: 
#---snip--- 
#set-alias ep "C:\Program Files\EditPlus 3\editplus.exe" 
#---snip--- 
#Is there another profile that I might look in for the Add-PSSnapin? 
#pnelsonsr
#New Member
#
#Posts:9
#26 Apr 2012 08:23 AM
#OK of the four types of profiles: 
#1 %windir%\system32\WindowsPowerShell\v1.0\profile.ps1 -> applies to all users and all shells. 
#2 %windir%\system32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1 -> applies to all users, but only to the Microsoft.PowerShell shell. 
#3 %UserProfile%\My Documents\WindowsPowerShell\profile.ps1 -> applies only to the current user, but affects all shells. 
#4 %UserProfile%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -> applies only to the current user and the Microsoft.PowerShell shell. 
#I have only #4 and I listed that above. So where else would the Add-PSSnapin be loading from? 
#mg48
#New Member
#
#Posts:26
#26 Apr 2012 08:54 AM
#Is the error coming from the SQLPS in SQL Server (SSMS)?
#pnelsonsr
#New Member
#
#Posts:9
#26 Apr 2012 09:39 AM
#I think its coming form PS (as I listed in my first post) as could not find assembly. I guess I could try to move the SqlServerProviderSnapin100 & the SqlServerCmdletSnapin100 directories over to the modules dir and try to import them but how do I turn off the App-PSSnapin from happening to begin with?
#mg48
#New Member
#
#Posts:26
#26 Apr 2012 09:46 AM
#I'm sorry but at this point I don't know. I do know that the module "SQLServer" is installed with SQL Server 2012 and it needs to be imported into a Powershell session. Do you have an version of SQL Server installed on the same machine?
#pnelsonsr
#New Member
#
#Posts:9
#26 Apr 2012 02:28 PM
#Yes SQL Server 2012 RC0 64bit Express is installed and working. 
#pnelsonsr
#New Member
#
#Posts:9
#26 Apr 2012 02:36 PM
#Oh I found some entries in registry hive: 
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\SqlServerCmdletSnapin100 
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\SqlServerProviderSnapin100 
#So I backed (exported) them and removed them and started ps and I no longer have the error. OK great. But... 
#So I know where the ps modules for sql 2012 are installed which is: 
#C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLASCMDLETS 
#with the following dll assemblies: 
#Microsoft.AnalysisServices.PowerShell.Cmdlets.dll 
#C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS 
#with the following dll assemblies: 
#Microsoft.AnalysisServices.PowerShell.Provider.dll 
#Microsoft.SqlServer.Management.PSProvider.dll 
#Microsoft.SqlServer.Management.PSSnapins.dll 
#How do I go about installing them? I've not installed modules before!
#Chad Miller
#Basic Member
#
#Posts:198
#27 Apr 2012 06:48 AM
#SQL Server 2012 uses modules instead snapins. Once you install SQL Server 2012 the installer modifies the $env:PSModulePath to look to the new sqlps module in those directories. You should be able to just run import-module sqlps or import-moduel sqlascmdlets from any Powershell prompt. Take a look at $env:PSModulePath also You should be able to run remove-pssnapin instead of messing with registry keys.
#pnelsonsr
#New Member
#
#Posts:9
#27 Apr 2012 08:15 AM
#Ah yes the $env:PSModulePath does include the correct path to the modules (C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\) 
#But when I run the import-module command I get an error; 
#---snip--- 
#Windows PowerShell 
#Copyright (C) 2009 Microsoft Corporation. All rights reserved. 
#PS C:\Users\pjn> import-module SQLPS 
#WARNING: Some imported command names include unapproved verbs which might make them less discoverable. Use the Verbose 
#parameter for more detail or type Get-Verb to see the list of approved verbs. 
#PS SQLSERVER:\> 
#---snip--- 
#How do I fix this?
#mg48
#New Member
#
#Posts:26
#27 Apr 2012 08:17 AM
#Import-Module -DisableNameChecking
#pnelsonsr
#New Member
#
#Posts:9
#27 Apr 2012 01:30 PM
#OK that worked... Looks like I've got PS functional again!
#jain86
#New Member
#
#Posts:2
#05 Jun 2012 06:38 AM
#Hi,
#Good and informative discussion about SQL. Acutally i am also facing the same problems. I tried the way you guide but i am facing errors in importing the modules. Can you please guide me ? I want to convert my pages bridal lehenga and sarees to SQL. So i need your assistance. Thanks!
#mg48
#New Member
#
#Posts:26
#05 Jun 2012 06:50 AM
#Sorry - I can't help with web pages. I don't know anything about web dev 
#pnelsonsr
#New Member
#
#Posts:9
#05 Jun 2012 07:50 AM
#jain86 -> Not sure how you're using PS with your web pages as I've never used PS with a website. But, I suggest you be very specific about your setup and what you're having problems with and what is happening.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#compare sql output with an array
#Last Post 23 May 2012 10:35 AM by Chad Miller. 1 Replies.
#AuthorMessages
#unix
#New Member
#
#Posts:3
#23 May 2012 12:47 AM
#Hi,
#i want to import username into a sql table and need to know if they exist already. Is there a possibility to compare these outputs?? I tried  to use if requests with -contains and -eq option but it wont work.
#What i do is getting the username and guid from ads and trying to import it in sql if it don't exist else to update it.
#$domain=[System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain()
#$PDCe=$domain.PdcRoleOwner.Name
#$Group=[ADSI]"LDAP://dn"
#$guid = $group.member | foreach{   
#   $gmember=[ADSI]"LDAP://$PDCe/$_"
#    "$($gmember.guid)"
#}
#$user = $group.member | foreach{   
#   $gmember=[ADSI]"LDAP://$PDCe/$_"
#    "$($gmember.SamAccountName)" 
#}
#The sql data i get with:
#$SqlServer = "ServerName"
#$SqlInstance = "InstanceName"
#$SqlServer = "$SqlServer\$SqlInstance"
#$SqlDatabase = 'DBName'
#$SqlTable = New-Object System.Data.DataTable
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection("Data Source=$SqlServer;Initial Catalog=$SqlDatabase;Integrated Security=True")
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter("Select * from dbo.users",$SqlConnection)
#$SqlAdapter.Fill($SqlTable)
#$SqlTable
#Now i tried to compare the sqlOutput with my ps array but it wont work:
#$SqlTable | foreach-object{if($($_.username) -contains $user){write-host "IM AVAILABLE"}else{write-host "IM NOT"}}
#Maybe you know how to compare these outputs or do i have to use another way of requesting the sql data??
#Im happy about your help :D many many thanks
#greetings
#unix
#Chad Miller
#Basic Member
#
#Posts:198
#23 May 2012 10:35 AM
#I setup test on my machine and this works fine for me: 
#$SqlServer = "$env:computername"
#$SqlInstance = "SQL1"
#$SqlServer = "$SqlServer\$SqlInstance"
#$SqlDatabase = 'tempdb'
#$SqlTable = New-Object System.Data.DataTable
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection("Data Source=$SqlServer;Initial Catalog=$SqlDatabase;Integrated Security=True")
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter("SELECT * FROM (VALUES ('user1'),('user2'),('user3')) AS v (username)",$SqlConnection)
#$SqlAdapter.Fill($SqlTable) | out-null
##$SqlTable
#$user = @('user1','user3')
#$SqlTable | where-object{$user -contains $_.username }
#username 
#-------- 
#user1 
#user3 
#Notice how I put the array on left side of the -contains operator, that appears to be your issue.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Formatting question;
#Last Post 23 May 2012 09:23 AM by Chad Miller. 1 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#22 May 2012 12:53 PM
#I am trying to get status of sql service ,agent service etc on some clusters  and I would like to add space when priting output
#Used this as reference from Chad Miller's Website to get this info
#http://sev17.com/2010/12/windows-cl...owershell/
#$a=Get-WmiObject -Namespace "root\mscluster" -Class MSCluster_Resource -ComputerName xxxx | Where-Object {$_.Type -like "*SQL*"} | select Name 
##get active nodes for sql cluster 
#foreach ($Service in $a) {
#$Node=gwmi -namespace "root\mscluster" -computerName xxxxx  -query "ASSOCIATORS OF {MSCluster_Resource.Name='$($Service.Name)'} WHERE AssocClass = MSCluster_NodeToActiveResource" | select Name 
#Write-Host " The Service is : " $Service.Name "Active On Node " $Node.Name | format-table length -autosize 
#Write-Host "" 
#Write-Host " The Status of the Service " $Service.Name " on Machine is" $Node.Name 
#Get-Service -ComputerName $Node.Name -Name $Service.Name | select Status Write-Host ""
#}
#Its printing output like this
#The Service is : SQL Server Agent (xxxx) Active On Node xxxx
#The Status of the Service SQL Server Agent (xxxx) on Machine is xxxx                                                                                                                Running
#I was hoping to get output formatted like this
#The 
#The Service is:                     SQL Server Agent (xxxx)          Active On Node     xxxxxx
#The status of the Service    SQL Server Agent (xxx)                                        Running
#Any way to get that? 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#23 May 2012 09:23 AM
#The format-* cmdlets may be of some help,however your desired output is kind of a blend of list and table. Here's an example of formatting the results of get-service as a list: 
#Get-Service -ComputerName $env:computername -Name Server |
# format-list @{l='The Service is';e={"$($_.Name)"}}, @{l='Active On Node';e={"$($env:computername)"}},
# @{l='The Status of the Service';e={"$($_.Name)"}}, @{l='on Machine is';e={"$($_.Status)"}}
#The Service is : LanmanServer 
#Active On Node : Z001 
#The Status of the Service : LanmanServer 
#on Machine is : Running
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Kan cmd og PowerShell arbejde i baggrunden?
#Last Post 21 May 2012 06:17 PM by Ludwiga. 0 Replies.
#AuthorMessages
#Ludwiga
#New Member
#
#Posts:1
#21 May 2012 06:17 PM
#Jeg skrev et PowerShell script, der genstarter et program, hvis dets lukning, og en batchfil, der genstarter PowerShell scriptet efter lukkede. Problemet er, at jeg ikke kan bruge programmet, fordi PowerShell og cmd holde poping op. Hvordan kan jeg stoppe det sker? Cheap Toms Shoes
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL Server Multiple Database Restore
#Last Post 15 May 2012 10:07 AM by Chad Miller. 4 Replies.
#AuthorMessages
#fabkhush
#New Member
#
#Posts:3
#15 May 2012 02:34 AM
#Recently a task is assigned to me to create a script which restores mutiple databases  on SQL Server 2008 R2 server. Powershell was asked to be used..\
#The daily backkups are stored at share location from where robocopy is done to one of SQL Server. The data files and log files sit a predefined location on other than C drive.
#Would like to know if anyone has a ready script that does the multiple db restore, reads the db name from backup header, which uses with move and replace option of db backup command and preferably also sends an email in event of db restore failure.
#Thanks in Advance
#Chad Miller
#Basic Member
#
#Posts:198
#15 May 2012 03:24 AM
#I don't have a complete example, but I do have an example of using Powershell to restore databases here: http://sev17.com/2011/03/restore-an...owershell/ 
#Also SQL 2012 has a backup-sqldatabase cmdlet you could use if you load SQL 2012 SSMS.
#fabkhush
#New Member
#
#Posts:3
#15 May 2012 03:45 AM
#Unfortunately, we will dont want to use SQL 2012.
#I already have a script that does the single db restore which uses SMO RestoreDb
#The problem im looking for recursive script that does the restore...
#fabkhush
#New Member
#
#Posts:3
#15 May 2012 03:47 AM
#Posted By Chad Miller on 15 May 2012 04:24 AM 
#I don't have a complete example, but I do have an example of using Powershell to restore databases here: http://sev17.com/2011/03/restore-an...owershell/ 
#Also SQL 2012 has a backup-sqldatabase cmdlet you could use if you load SQL 2012 SSMS. 
#For the script on the link , I get an error -
#Invoke-SqlRestore' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.\
#also tried running it with .\Invoke... but no luck. why the error?
#Chad Miller
#Basic Member
#
#Posts:198
#15 May 2012 10:07 AM
#Invoke-SqlRestore is part of SQLPSX http://sqlpsx.codeplex.com/. The sqlserver module contains the invoke-sqlrestore function. The function is just wrapper around SMO restore. Even if you don't use the function and instead choose to use your own SMO code you can read the function definition to see how I implemented move and restore filelist only. 
#The recursive you mentioned, why not just use get-childitem to get a list of backup files from the file system? You could then pass the fullname property to the invoke-sqlrestore function. If you need to recurse through a directory and all subdirectories use the -Recurse switch i.e. get-childitem -Recurse 
#The script would look something like this: 
#import-module sqlserver -force
# 
#$server = get-sqlserver $sqlserver
# 
#$filepath = Resolve-Path $filepath | select -ExpandProperty Path
#$dbname = Get-ChildItem $filePath | select -ExpandProperty basename
# 
#$dataPath = Get-SqlDefaultDir -sqlserver $server -dirtype Data
#$logPath = Get-SqlDefaultDir -sqlserver $server -dirtype Log
#get-childitem . -include *.bak -Recurse | foreach {
#$relocateFiles = @{}
#Invoke-SqlRestore -sqlserver $server  -filepath $_.FullName -fileListOnly | 
#  foreach {
#    if ($_.Type -eq 'L')
#    { $physicalName = "$logPath\{0}" -f [system.io.path]::GetFileName("$($_.PhysicalName)") }
#    else
#    { $physicalName = "$dataPath\{0}" -f [system.io.path]::GetFileName("$($_.PhysicalName)") }
#    $relocateFiles.Add("$($_.LogicalName)", "$physicalName")
#}
#Invoke-SqlRestore -sqlserver $server -dbname $dbname -filepath $filepath -relocatefiles $relocateFiles -Verbose -force
#}
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Insert Into SQL Table
#Last Post 15 May 2012 03:21 AM by Chad Miller. 1 Replies.
#AuthorMessages
#sqlspy
#New Member
#
#Posts:3
#15 May 2012 01:00 AM
#Hey
#I'm looking for advise on the best way to insert data from my powershell session into SQL Server. Specifically I want to load all the Win32_OperatingSystem properties into a new row in my SQL table. I want to do this on a regular basis (every 5 mins) and do some work such that if the value hasnt changed, a null is inserted instead (I will be using sparse columns for most of these).
#Not asking for a solution but just some high level suggestions on a good method. So far I've been populating a datatable object and then bulkloading this into my SQL table, which works okay but doesn't allow me to do the manipulation I want for the null values.
#Many Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#15 May 2012 03:21 AM
#You could still use your DataTable with a TVP. Then inside of your stored procedure create logic for inserting null values. Here's an example of a TVP parameter stored procedure with Powershell from my blog: http://sev17.com/2012/04/appending-...rows-only/
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#sql query converts binnary to numbers
#Last Post 15 May 2012 03:11 AM by Chad Miller. 4 Replies.
#AuthorMessages
#nbritton
#New Member
#
#Posts:55
#10 May 2012 12:05 PM
#I am doing a sql query and one of the fields is a binary type.  How can i stop the conversion.
#Data in the field looks like : 0xB2D3F86F840CFA428B1061F73B64951D
#powershell displays it as : 178 211 248 111 132 12 250 66 139 16 97 247 59 100 149 29
#script: 
## Parameters
# $PROVIDER = "System.Data.SqlClient" 
#$connstring = "Data Source=server\instance;Initial catalog=database;Integrated Security=True;" 
#$SQL = "SELECT usp_contact.contact_uuid, c_cm_id1, c_cm_id2, c_cm_id3, c_cm_id4, ca_contact.last_name FROM ca_contact INNER JOIN usp_contact ON ca_contact.contact_uuid = usp_contact.contact_uuid WHERE ca_contact.inactive = 0 AND ca_contact.contact_type = '2308' AND (usp_contact.c_cm_id2 '30427950' or usp_contact.c_cm_id2 is null ) and usp_contact.contact_uuid not in (0x096A060435922A428B357F4DB03A6B99,0x136FDC787B472C43998F95D66EA434F0,0xF0C6F9375754C347B09AB19E4FB656A7)" 
## Create Factory:
#$provider = [System.Data.Common.DbProviderFactories] GetFactory($PROVIDER) 
## Create Connection Object: 
#$conn = $provider.CreateConnection() 
#$conn.ConnectionString = $connstring 
##Open Database: 
#"Open the database..." 
## $conn = New-Object System.Data.SqlClient.SqlConnection($Connstring) 
#$conn.Open() 
#"Status of Database: " + $conn.State 
##Command 1: 
#$cmd = $provider.CreateCommand() 
#$cmd.CommandText = $SQL 
#$cmd.Connection = $conn 
##Execute Command: 
#$reader = $cmd.ExecuteReader() 
##Loop over all data rows while($reader.Read()) 
#{
# $reader.Item("contact_uuid") + " " + $reader.Item("c_cm_id1") + " " + $reader.Item("c_cm_id2") 
#}
# #Close Database:
# $Conn.Close() 
#"Status of Database: " + $conn.State
#Chad Miller
#Basic Member
#
#Posts:198
#11 May 2012 10:29 AM
#You could convert the byte array to hexadecimal string representation by doing something like: 
#'0x' + [System.BitConverter]::ToString($bArray).replace('-','') 
#nbritton
#New Member
#
#Posts:55
#14 May 2012 11:12 AM
#how would that look in the code above. I am not sure where to stick that or how that would replace the value in the array.
#nbritton
#New Member
#
#Posts:55
#14 May 2012 01:10 PM
#The other thought would be, is there a way to convert the byte array to a string? Then i could do a format switch with that.
#Chad Miller
#Basic Member
#
#Posts:198
#15 May 2012 03:11 AM
#Since I don't have your database or understand your schema here's an example of taking your byte array and converting to a hexadecimal string representation:
# [Byte[]] $bArray = 178,211,248,111,132,12,250,66,139,16,97,247,59,100,149,29
#'0x' + [System.BitConverter]::ToString($bArray).replace('-','') 
#You would need to substitute whatever your byte array field/hexadecimal field is for $bArray.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Get Difference between two tables data;
#Last Post 03 May 2012 04:45 PM by Chad Miller. 8 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#01 May 2012 06:43 PM
#hi I have two tables (tableA,TableB) TableA(x int,y int) TableB(x int ,y int), they have some data something like this.
#TableA has 
#x     y
#19   20
#10   30
#20   15
#TableB has
#x    y
#10  20
#10  30
#20  19
#I need to get the difference between data as output(tableC), Also tableA and TableB has same number of rows all the time
#TableC 
#x   y
#-9  0
#0   0
#0   4
#Any information will help
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#02 May 2012 04:38 AM
#This seems like more of a SQL problem than Powershell or at least its a lot easier to solve in SQL. Your example is missing a primary key. You need some way of joining table A and B. Then you can do subtraction in a set based manner as follows: 
#--Setup test tables. These tables should already exist in your case.
#SELECT ROW_NUMBER() OVER(ORDER BY x,y DESC)AS id, *  into #tableA FROM (
#    VALUES (19,20),(10,30),(20,15)
#) AS TableA (x,y)
#SELECT ROW_NUMBER() OVER(ORDER BY x,y DESC)AS id, * into #tableb FROM (
#    VALUES (10,20),(10,30),(20,19)
#) AS TableB (x,y)
#--Here's the example code.
#SELECT a.x - b.x AS x, a.y -b.y AS y
#FROM #tableA a
#JOIN #tableb b
#ON a.id = b.id
#JR81
#New Member
#
#Posts:23
#02 May 2012 08:36 AM
#Thanks Chad,Reason i wanted to do in powershell was it was a busy sql server , and the table can get real large,  and  since we have separate machine to run powershell i can offload process, from sql server. So way to do it using powershell is compare datasets? and get difference then?
#Thanks
#mg48
#New Member
#
#Posts:26
#02 May 2012 09:54 AM
#I have no idea if this is fit or not,but you could try Compare-Object. Here is an example that compares services on servers: 
#$pc1 = Get-Service -ComputerName server1
#$pc2 = Get-Service -ComputerName server2 
#Compare-Object $pc1 $pc2 -Property Name, Status -PassThru |
#    Sort-Object -Property Name  |
#    Select-Object -Property MachineName, Name, Status
# 
#Replace the Get-Service with an invoke-sqcmd. You will need to do a bit of tweaking and be sure your tables are ordered so you are comparing apples to apples. As Chad said, a Primary Key is needed.
#Chad Miller
#Basic Member
#
#Posts:198
#02 May 2012 02:21 PM
#Summing two columns in Powershell instead of T-SQL doesn't really offload anything from SQL Server. 
#For example if we take at look at the query plans for these two SQL statements (see attachment):
#--Sum in SQL
#SELECT a.x - b.x AS x, a.y -b.y AS y
#FROM #tableA a
#JOIN #tableb b
#ON a.id = b.id
#--Retrieve Data without Summing
#SELECT a.x AS xa, b.x AS xb, a.y as ya, b.y AS yb
#FROM #tableA a
#JOIN #tableb b
#ON a.id = b.id
#We see they are nearly identical with the only difference being the compute scalar expression. The expression i.e. summing has a zero cost in SQL Server. The main "cost" in SQL is retrieving the data and you pay the cost either way.
#Chad Miller
#Basic Member
#
#Posts:198
#02 May 2012 02:24 PM
#Looks like attachments didn't go through here's links: 
#https://docs.google.com/open?id=0B0jZ_IPvd-dXQ0dmLTJrclNNZ00 
#https://docs.google.com/open?id=0B0jZ_IPvd-dXUVNseEo2Q1JucFU
#JR81
#New Member
#
#Posts:23
#02 May 2012 05:54 PM
#Thanks Chad and mg48,that's very much appreciated. Unfortunately i am not sure how to mark the question as answered...
#mg48
#New Member
#
#Posts:26
#03 May 2012 11:18 AM
#Unfortunately i am not sure how to mark the question as answered 
#I've asked this question myself and haven't gotten an answer. I also searched through the site looking for an FAQ or some instruction but it was fruitless. Oh well, the saving grace is that the assistance is good
#Chad Miller
#Basic Member
#
#Posts:198
#03 May 2012 04:45 PM
#Me too. I like the specificity of these forums i.e. Powershell + SQL Server, but the format, inability to mark questions as answered, lack of moderators and general feeling of being a forum format from 5+ years ago when compared to SF and even technet/msdn is annoying.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Capture results from powershell;
#Last Post 01 May 2012 06:10 AM by JR81. 4 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#30 Apr 2012 12:27 PM
#hi I have a stored procedure thats returning about 100-200 rows,sometimes more than 1k, I need to call that stored procedure  on Server A( using powershell on Server B) capture select results, then call a stored procedure in another server(Server C) and insert the data.
#I tested opening and closing connections etc,but i am not able to find how to store select results into a vaiable?
#Any information will help. 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#30 Apr 2012 03:50 PM
#You could use the invoke-sqlcmd cmdlet which is part of SQL Server 2008 and higher or use this invoke-sqlcmd2 function: 
#Download the function. 
#http://poshcode.org/2279 
#. ./invoke-sqlcmd2.ps1
#$dt = invoke-sqlcmd2 -ServerInstance mysqlserverA -Database mydatabaseA -Query "EXEC mystoredprocedureA"
#$dt | foreach {invoke-sqlcmd2 -ServerInstance mysqlserverC -Database myDatabaseC -Query "EXEC mystoredprocedureC $($_.ColumnFromSotredProcedureA)" }
#JR81
#New Member
#
#Posts:23
#30 Apr 2012 07:11 PM
#Thanks Chad, that's very helpful.But for some reason i am not able to output results from that variable? any reason for this?
#This doesn't print the variable's(a.ID) results?
#$a=sqlcmd -E -S xxxx -Q "SELECT DB_ID() as ID" $a | foreach { write-host $a.ID}
#But this works?
#$a=sqlcmd -E -S xxxx  -Q "SELECT DB_ID() as ID" $a | foreach { write-host $a}
#This prints $a
#Chad Miller
#Basic Member
#
#Posts:198
#01 May 2012 03:19 AM
#It looks like you are using the command-line sqlcmd.exe. This utility doesn't output objects, just plain text. It will not work for what you want to do. Either download Invoke-Sqlcmd2 or use invoke-sqlcmd. In SQL Server 2008/2008 R2 you can run sqlps. Start > Run > sqlps 
#JR81
#New Member
#
#Posts:23
#01 May 2012 06:10 AM
#Thanks Chad, i wasn't able to download on that machine,hence using sqlcmd.exe, will see what i can do thanks though
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#ErrorActionPreference has no effect in sql job
#Last Post 26 Apr 2012 06:03 AM by suneg. 1 Replies.
#AuthorMessages
#suneg
#New Member
#
#Posts:6
#26 Apr 2012 05:32 AM
#hi all,
#i have some code which checks if a file is already open by another process. the code will try and open the file and if it cannot and error is thrown and the code will then copy the file instead.
#this all works fine within the cmd prompt but when i dump into a sql agent job the job fails with the very error that i want to use.
#i've set $ErrorActionPreference to "SilentlyContinue" and "Continue" but neither stop the job failing.
#what can i do to get this to work?
#code below:-
#$fullfilepath = "C:\Test.txt"
##if file is in use then copy the file and upload the copy
# $logfile = New-Object -TypeName System.IO.FileInfo -ArgumentList $fullfilepath
# $ErrorActionPreference = "SilentlyContinue"
# [System.IO.FileStream] $fs = $logfile.OpenWrite(); 
##### Agent job fails here before getting to the below with the error (Exception calling "OpenWrite" with "0" argument(s): "The process cannot access the file 'C:\Test.txt' because it is being used #### by another process)###
# if (!$?) {
#  #file is in use so copy it and use the copied name... 
#  $copyfullfilepath = $fullfilepath.replace(".log", "_copy.log")
#  copy-item $fullfilepath $copy_fullfilepath
#  $fullfilepath = $copyfullfilepath
#  $fullfilepath
# }
# else {
#  $fs.Dispose()
#  #carry on below
# }
#suneg
#New Member
#
#Posts:6
#26 Apr 2012 06:03 AM
#Apologies for answering my own question but if i replace the IF with TRY/CATCH then Agent Job continues.
#Thanks anyway!
#S
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell - query server for instance names & ports used - configure firewall?
#Last Post 24 Apr 2012 11:16 PM by Manish. 1 Replies.
#AuthorMessages
#jakes
#New Member
#
#Posts:15
#24 Apr 2012 10:38 PM
#I need to use powershell if possible to query a server or list of servers that could be in a text file and the query should return the instance name on the server, then the powers being used for inbound connections, such as 1433.  
#I've searched an haven't found anything yet, it's SQL2012 Express and 2012 Standard.
#Thanks!
#Manish
#New Member
#
#Posts:1
#24 Apr 2012 11:16 PM
#Jakes, 
#1. As you said that, you will have the list of servers that could be in a text file, hence first create a .txt file as I did for my environment. 
#I create ALLSERVERS.txt file and the following are the contents 
#MSSQLSERVER 
#MSSQLSERVER\SQL2012 
#2. Now create another PS1 file which will read this file and provide you other information. I created getversion.ps1 with the following contents. 
#foreach ($svr in get-content "C:\Users\manish\Desktop\AllServers.txt") 
#{ 
#$con = "server=$svr;database=master;Integrated Security=sspi" 
#$cmd = "SELECT @@servername ServerName,SERVERPROPERTY('ProductVersion') AS Version, SERVERPROPERTY('ProductLevel') as SP" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.DataTable 
#$da.fill($dt) | out-null 
#$svr 
#$dt | Format-Table -autosize 
#} 
#Hope this helps. 
#Thanks 
#Manish
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#access to files through sql agent job
#Last Post 19 Apr 2012 07:58 PM by Riley103. 3 Replies.
#AuthorMessages
#suneg
#New Member
#
#Posts:6
#16 Jan 2012 01:04 AM
#Hi all,
#What i'm trying to do is a simple testpath on a file. when i run the code from the command prompt the testpath returns true however when the exact same code run from an agent job the testpath is false.
#I have added the username to the output and of course the sql agent job is running under the SQL Agent Account name rather that using my login name from the command prompt.
#The Sql agent job has full control permissions over this folder.
#I have the exact same thing running on another server with no problems at all.
#There is obviously some difference in the logins. Would anyone be able to give me a clue on where the look?
#code:
##set variables 
#$pathto = "C:\\test.txt" 
#$creds = [environment]::UserName 
#$testpath = Test-Path $pathto 
#if ($testpath -eq $true) 
#{ 
#$out = "I can see the file - With username = " 
#$out = $out + $creds $out | Out-File c:\out.txt } 
#else { 
#$out = "I cannot see the file - With username = " 
#$out = $out + $creds $out | Out-File c:\out.txt 
#} 
#Cheers
#S
#mg48
#New Member
#
#Posts:26
#16 Jan 2012 04:55 AM
#Use a Try/Catch to capture the exception. See this article: 
#http://blogs.technet.com/b/heyscrip...-2010.aspx
#Chad Miller
#Basic Member
#
#Posts:198
#16 Jan 2012 09:18 AM
#Have you tried running a regular Powershell console as the SQL Server Agent account and testing your code?
#Riley103
#New Member
#
#Posts:2
#19 Apr 2012 07:58 PM
#Posted By Chad Miller on 16 Jan 2012 10:18 AM 
#Have you tried running a regular Powershell console as the SQL Server Agent account and testing your code? 
#I don't understand question
#__________________
#Watch Lockout Online Free
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell to save object to file
#Last Post 17 Apr 2012 02:19 PM by Chad Miller. 1 Replies.
#AuthorMessages
#Garry Bargsley
#New Member
#
#Posts:1
#17 Apr 2012 05:10 AM
#I would like to create a powershell script that I can run to backup objects to file before updating them. My goal is to backup objects before changing them in case something breaks. I would like to pass in parameters to run like the following:
#backupobjects.ps1 -servername -databasename -schemaname -objectname -outputdirectory
#So if I call this powershell script and pass in parameters the script will connect to the database and find the object and save the CREATE script and save the object to the outputdirectory passed in and put BEFORE_objectname.sql as the filename.
#I am just starting in powershell so accepting parameters I have not learned yet.
#Any guidance or suggestions would be helpful.
#Chad Miller
#Basic Member
#
#Posts:198
#17 Apr 2012 02:19 PM
#This problem is difficult to approach if you're not familiar with SMO, so I can understand why haven't made much progress. I went ahead and created a complete solution and posted it on my blog: 
#http://sev17.com/2012/04/backup-dat...se-object/ 
#I noticed the same question on StackOverFlow. I'll post my answer there also.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Invoke-Sqlcmd issue with variable substitution
#Last Post 09 Apr 2012 05:31 PM by Chad Miller. 3 Replies.
#AuthorMessages
#agent86
#New Member
#
#Posts:2
#06 Apr 2012 03:56 PM
#I am running into an issue where it appears that Invoke-Sqlcmd is interpreting the value of a substituted string when passing it through to a query and its then getting confused about the var=value list.
#I am using a stored proc and I want to pass a long string into it... the string will be wikimarkup plain text.  In reality I would substitute many more parameters, but this is the smallest example I can show the issue.
#Here are 2 ways to reproduce this... 
#Invoke-Sqlcmd -ServerInstance "MyServerName" -Database MyDB -Query "EXEC dbo.[spTestProc] @Content=`$(MyVar)" -Variable "MyVar='==SomeText=='" -verbose
#Also like so using the normal approach for substitutions:
#$Article = "==AnyText=="
#$ProcVars = "MyVar='${Article}'"
#Invoke-Sqlcmd -ServerInstance "MyServerName" -Database MyDB -Query "EXEC dbo.[spTestProc] @Content=`$(MyVar)" -Variable $ProcVars -verbose
#Both of these examples give the same error:
#Invoke-Sqlcmd : The format used to define the new variable for Invoke-Sqlcmd cmdlet is invalid. Please use the "var=value" format for defining a new variable.
#If you run the exact same thing and only change the content of the variables, then there is no error
#Invoke-Sqlcmd -ServerInstance "MyServerName" -Database MyDB -Query "EXEC dbo.[spTestProc] @Content=`$(MyVar)" -Variable "MyVar='SomeText'" -verbose
#or this:
#$Article = "AnyText"
#$ProcVars = "MyVar='${Article}'"
#Invoke-Sqlcmd -ServerInstance "MyServerName" -Database MyDB -Query "EXEC dbo.[spTestProc] @Content=`$(MyVar)" -Variable $ProcVars -verbose
#I have tried all kinds of things to escape the equal signs inside my string, but I haven't found one that works... but really the biggest issue to me is that I don't understand why powershell is trying to parse or interpret the value of the variable I am substituting.  IMO it should not do this.
#I must have those equal signs in the string... they are kind of critical in wiki markup.
#Chad Miller
#Basic Member
#
#Posts:198
#07 Apr 2012 12:10 PM
#Its not really invoke-sqlcmd as much as it is the arcane sqlcmd style variable substitution. I ran few tests and I get same result. If a variable has an equal sign this messes up the sqlcmd-style variable substitution. Personally I don't use or like the variable substitution built into invoke-sqlcmd. Instead I'll use Powershell variable within a here-string as listed in workaround #2: 
##Fails
#$Article = "==AnyText=="
#$ProcVars = "MyVar='${Article}'"
#Invoke-Sqlcmd -ServerInstance "$env:computername\sql1" -Database tempdb -Query "Select `$(MyVar) As Var1" -Variable $ProcVars
##Work around #1 avoid passing in == instead hard code == in your query/proc
#$Article = "AnyText"
#$ProcVars =,"MyVar='${Article}'"
#Invoke-Sqlcmd -ServerInstance "$env:computername\sql1" -Database tempdb -Query "Select '==' + `$(MyVar) + '==' As Var1" -Variable $ProcVars
##Work around #2 instead of using old sqlcmd sytle variable substitution use Powershell:
#$MyVar = "==AnyText=="
#$query = @"
#Select '$MyVar' As Var1
#"@
#Invoke-Sqlcmd -ServerInstance "$env:computername\sql1" -Database tempdb -Query $query
##Work around #3 use ADO.NET params instead of invoke-sqlcmd:
#$serverName= "$env:computername\sql1"
#$databaseName='tempdb' 
#$MyVar = "==AnyText=="
#$query="select '@MyVar' As Var1" 
#$connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;" 
#$conn = new-object System.Data.SqlClient.SqlConnection $connString 
#$conn.Open() 
#$cmd = new-object System.Data.SqlClient.SqlCommand("$query", $conn) 
#$null = $cmd.Parameters.AddWithValue("@MyVar", $MyVar)
#$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter            
#$dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)            
#$dt = New-Object System.Data.DataTable            
#$null = $dataAdapter.fill($dt) 
#$conn.Close()
#$dt
#agent86
#New Member
#
#Posts:2
#09 Apr 2012 02:53 PM
#Thank you for taking the time to look at this.
#Hard code was right out for me.  The sample I provided was the smallest unit I could show to illustrate the issue.  I am attempting to use powershell to slurp up large strings of wiki markup and inject them into a wiki engine database.  My function uses far more variables than my sample here.
#One thing I did just attempt was to use Invoke-Sqlcmd2 instead... and lo and behold, this issue for variable substitution does not exist:
#$MyVar = "==SomeText=="
#$SomeOtherVar = "My recent change"
#Invoke-Sqlcmd2 -ServerInstance "MyServerName" -Database MyDB -Query "EXEC dbo.[spTestProc] @Content='$MyVar', @Description='$SomeOtherVar'" -verbose
#The only other thing I have to do is double all the single quotes that are in the $MyVar to escape them so they pass into SQL without making a mess, and as you can see I wrap these vars in single quotes since they are strings and need to go into sql as such.
#After smashing my head against this... Invoke-Sqlcmd2 solves it cleanly and simply... and read-ably.
#Chad Miller
#Basic Member
#
#Posts:198
#09 Apr 2012 05:31 PM
#Ah, yes invoke-sqlcmd2 I tend to use that over invoke-sqlcmd also :)
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Eventhandler Question;
#Last Post 12 Mar 2012 08:31 AM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#08 Mar 2012 01:00 PM
#I added the event handler in my powershell script to capture Print to capture print and raiseerror messages.
#http://powershellcommunity.org/Foru...fault.aspx
#But when i am running this against multiple servers in a for each loop, Its printing multiple lines of same PRINT message say if i run this against 2 servers, for 2nd server I am seeing 2 lines of print statements for 3 server 3 lines of print statements so on.. 
#I wanted to see how it just outputs the print statement only once for each server? 
#I am guessing it has to do with the Eventhandler being set in my command window and when it runs against multiple server its getting incremented each time, I wanted to see if there is a remove event handler method which i can call after each server?
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#09 Mar 2012 08:58 AM
#I'm having trouble reproducing your issue. I've implemented event handlers in my invoke-sqlcmd2 function http://poshcode.org/2279 with the only difference being write-verbose instead of write-host. 
#If I pipe serverinstance names I get back the expect two lines: 
#. .\invoke-sqlcmd2.ps1
#echo "$env:computername\sqlexpress" "$env:computername\sql1" | foreach { Invoke-Sqlcmd2 -ServerInstance $_ -Database 'master' -Query 'PRINT @@SERVERNAME' -Verbose }
#echo "$env:computername\sqlexpress" "$env:computername\sql1" | foreach { Invoke-Sqlcmd2 -ServerInstance $_ -Database 'master' -Query 'PRINT @@SERVERNAME' -Verbose } 
#VERBOSE: Z002\SQLEXPRESS 
#VERBOSE: Z002\SQL1
#JR81
#New Member
#
#Posts:23
#12 Mar 2012 08:31 AM
#Thanks Chad, I was able to overcome the issue by adding remove_InfoMessage after completing run on each server, for some reason it was printing multiple lines for print statemetns.
#Also attached the script
#003_002_001_Script.ps1
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Capture Results from dmv;
#Last Post 07 Mar 2012 07:07 PM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#07 Mar 2012 07:31 AM
#Hi I would like to capture sql server wait stats periodically , I wanted to see how I can store output of something like sys.dm_os_wait_Stats into array?
#Once i store it in array i will be retrieving previous capture from existing table and doing a diff between current time and previous time to calculate deltas. 
#Need to implement something like this in powershell
#http://blogs.msdn.com/b/mhouse/arch...cript.aspx
#Because i can offload this processing to another server and don't have to do it inside my sql server.
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#07 Mar 2012 01:06 PM
#If you want to simply capture the output of the DMV every 5 minutes you run the query, convert the output to CSV and skip the header line and append the information to a CSV file as follows: 
#Note: You'll need to grab invoke-sqlcmd2 from here http://poshcode.org/2279 or use the invoke-sqlcmd cmdlet which is part of sqlps. 
#. ./invoke-sqlcmd2.ps1
#while ($true) {
#    invoke-sqlcmd2 -ServerInstance yoursqlserver\yourinstance -Database master -query "select getdate() AS snapshot_time, * FROM sys.dm_os_wait_stats" |
#    ConvertTo-Csv -NoTypeInformation | Foreach-Object  -begin { $start=$true }  -process { if ($start) { $start=$false } else { $_ }  } |
#    out-file -FilePath ./waitstats.csv -Append
#    Start-Sleep -Seconds 300 
#} 
#This will run continuously until you ctrl+c. You would then need to import the CSV file into SQL Server and run the query shown in the blog post from the link you provide. 
#You could use SSIS to import CSV files into a SQL table or here's Scripting Guy article which describes Powershell-based approaches: http://blogs.technet.com/b/heyscrip...shell.aspx
#JR81
#New Member
#
#Posts:23
#07 Mar 2012 07:07 PM
#Thanks Chad will try it.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Writeoutput of PRINT commands to text file;
#Last Post 07 Mar 2012 07:18 AM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#06 Mar 2012 12:46 PM
#Hi  I am calling a stored procedure from powershell I added event handler to capture print messages
#as mentioned here
#http://sqlskills.com/blogs/jonathan...Shell.aspx 
#But need to write the print messages to text file? Currently i am seeing it on powershell window.
#$cmd = new-object "System.Data.SqlClient.SqlCommand" ($Proc, $objSQLConnection) 
#$cmd.CommandType = [System.Data.CommandType]"StoredProcedure" 
#$cmd.Parameters.Add("@Database", [System.Data.SqlDbType]"varChar", 1000) | out-null 
#$cmd.Parameters["@Database"].Value = $db 
#$cmd.Parameters.Add("@Report", [System.Data.SqlDbType]"Char", 1) | out-null 
#$cmd.Parameters["@Report"].Value = $Report
#$cmd.CommandTimeOut = 60000 
#$cmd.ExecuteReader() | out-null ---Need to write this output to file(output is in the format)
#--The Database :XXXX Has This Logical FileName "xxxx" Whose Growth Set in Percent 
#--Generating Command to Set File Growth to Specific Size 
#ALTER DATABASE xxxxx MODIFY FILE( Name =N'xxxx', FileGrowth =1024 MB) ;
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#06 Mar 2012 02:22 PM
#If you move your code into a script file it would be as simple as this to redirect to a text file: 
#./set-database.ps1 | out-file ./set-database.txt
#JR81
#New Member
#
#Posts:23
#07 Mar 2012 07:18 AM
#ah...Thanks Chad, that's very helpful.
#Jay
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Creating a batch file for sqlcmd commands
#Last Post 08 Feb 2012 01:30 PM by sting7282. 5 Replies.
#AuthorMessages
#sting7282
#New Member
#
#Posts:8
#01 Feb 2012 01:37 PM
#I am running a script in powershell that pulls in some variables and script names from a file and then runs them against a database from a batch file. The idea is to create the batch to be run at a later date. When I test out my batch file though I get an error like there is an invalid character before sqlcmd command. If I copy and paste line by line it works though, and if I type it manually into a batch file and run the batch file there is no error. So I think the issue is that my powershell script is adding in an invalid space before sqlcmd. Below is the section of my script that generates the sqlcmd commands. Can anyone see a reason why that would occur?
#$c=Get-Content fileList.txt
#foreach ($x in $c)
#{
#"sqlcmd" + " -S " + $server + " -d " + $database + " -U " + $user + " -P " + $password + " -i " + """" +  $x + """"+ " -o " +$database+"output.txt" | Out-File "upgrade.bat" -append
#}
#Error I receive:
#'¦s' is not recognized as an internal or external command,
#operable program or batch file.
#Chad Miller
#Basic Member
#
#Posts:198
#01 Feb 2012 02:23 PM
#I ran quick test and I'm unable reproduce errors. Here's my test: 
#echo $env:computername\sql1 | out-file filelist.txt; echo $env:computername\sql1 | out-file filelist.txt -Append
#$server = "$env:computername\sql1"
#$database = 'tempdb'
#$user = 'sa'
#$password = 'himom'
#$c=Get-Content fileList.txt
#foreach ($x in $c)
#{
#"sqlcmd" + " -S " + $server + " -d " + $database + " -U " + $user + " -P " + $password + " -i " + """" +  $x + """"+ " -o " +$database+"output.txt" | Out-File "upgrade.bat" -append
#}
##Ran fine and produced the following output: 
#sqlcmd -S Z109943W\sql1 -d tempdb -U sa -P himom -i "z001\sql1" -o tempdboutput.txt 
#sqlcmd -S Z109943W\sql1 -d tempdb -U sa -P himom -i "Z001\sql1" -o tempdboutput.txt 
#I imagine the named instances will be a problem for the output file generate when run in a bat file, but the generating bat file seems to work fine.
#sting7282
#New Member
#
#Posts:8
#03 Feb 2012 01:14 PM
#Yea, my problem is it looks fine in the.bat file but when I go to run the .bat file I receive that error. If I type in the lines into a .bat manually it is fine. So I feel like the Powershell script is generating the file with some invalid character in it. It is odd because I never had this issue with other scripts that do things like moving files etc. Only sqlcmd. I am going to try sending it to a .txt file then renaming it to .bat and see if it runs. It should just output as text regardless of the file extension though, right?
#Chad Miller
#Basic Member
#
#Posts:198
#04 Feb 2012 04:59 AM
#Powershell ISE does use BigEndianUnicode by default. You could try saving your script to notepad to change the encoding.
#mg48
#New Member
#
#Posts:26
#06 Feb 2012 04:13 AM
#You might try 
#OUT-FILE "upgrade.bat" -append -endcoding "default"
#"Default" uses the encoding of the system's current ANSI code page. 
#http://technet.microsoft.com/en-us/...15303.aspx 
#sting7282
#New Member
#
#Posts:8
#08 Feb 2012 01:30 PM
#This worked. Thanks a lot!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Creating a batch file for sqlcmd commands
#Last Post 01 Feb 2012 01:49 PM by sting7282. 1 Replies.
#AuthorMessages
#sting7282
#New Member
#
#Posts:8
#01 Feb 2012 01:37 PM
#I am running a script in powershell that pulls in some variables and script names from a file and then runs them against a database from a batch file. The idea is to create the batch to be run at a later date. When I test out my batch file though I get an error like there is an invalid character before sqlcmd command. If I copy and paste line by line it works though, and if I type it manually into a batch file and run the batch file there is no error. So I think the issue is that my powershell script is adding in an invalid space before sqlcmd. Below is the section of my script that generates the sqlcmd commands. Can anyone see a reason why that would occur?
#$c=Get-Content fileList.txt
#foreach ($x in $c)
#{
#"sqlcmd" + " -S " + $server + " -d " + $database + " -U " + $user + " -P " + $password + " -i " + """" +  $x + """"+ " -o " +$database+"output.txt" | Out-File "upgrade.bat" -append
#}
#Error I receive:
#'¦s' is not recognized as an internal or external command,
#operable program or batch file.
#sting7282
#New Member
#
#Posts:8
#01 Feb 2012 01:49 PM
#Sorry, sometimes duplicates are created because of my proxy
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#ExecuteNonQuery not returning errors
#Last Post 30 Jan 2012 04:03 PM by Chad Miller. 1 Replies.
#AuthorMessages
#jcbunn
#New Member
#
#Posts:1
#30 Jan 2012 08:41 AM
#Hello.  I have a question
#Consider
## Open Connection to Server # 
#$conn = New-Object System.Data.SqlClient.SqlConnection "Server=$s;Database=$d;Integrated Security=SSPI;"; 
#   $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message }; 
#   $conn.add_InfoMessage($handler); 
#   $conn.FireInfoMessageEventOnUserErrors = $true; 
#$conn.Open(); 
## Invoke Stored Procedrue # 
#$cmd = $conn.CreateCommand(); 
#$cmd.CommandText = "execute TestProc  DatabaseThatDoesNotExist"; 
#$res = $cmd.ExecuteNonQuery(); 
#$conn.Close();
#All of that is in a try...catch.  
#If I run it as is, forcing an error, I see the error text returned to the client, but control is not transferred to the catch block.  If I remove the $handler lines  (indented), then the error fires, but I don't see the text of the SQL Server error message in the transcript.  Is it possible to both see the error text, and have control pass to the catch block?
#Thank you.
#Chad Miller
#Basic Member
#
#Posts:198
#30 Jan 2012 04:03 PM
#Have you set your $ErrorActionPreference to stop?
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Invoke-Sqlcmd doesn't output all server error messages
#Last Post 25 Jan 2012 03:41 PM by Chad Miller. 1 Replies.
#AuthorMessages
#Chancha
#New Member
#
#Posts:1
#25 Jan 2012 01:34 AM
#When I execute sql script in file I get error message in execution.
#try
#{
#Invoke-Sqlcmd -InputFile $fileInfo.FullName -ServerInstance $db.server -Username $db.user -Password $db.password -Database $db.database -AbortOnError -OutputSqlErrors $True -QueryTimeout 600
#}
#catch [Exception]
#{
#Handle-Error $_
#}
#Error message: Invalid object name 'dbo.UserDetails'.
#When I execute this script on server using Management Studio I get two errors:
#Msg 208, Level 16, State 1, Procedure tr_ins_aspnet_Users, Line 9
#Invalid object name 'dbo.UserDetails'.
#How can I execute Invoke-Sqlcmd to get all server error messages in output?
#Thanks.
# 
#Chad Miller
#Basic Member
#
#Posts:198
#25 Jan 2012 03:41 PM
#Try adding the -verbose parameter. The invoke-sqlcmd cmdlet uses the verbose switch to control whether RAISERROR and PRINT messages are output.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Get SQL Version via Powershell and WMI
#Last Post 25 Jan 2012 03:39 PM by Chad Miller. 3 Replies.
#AuthorMessages
#debian01
#New Member
#
#Posts:1
#24 Jan 2012 06:31 PM
#I am trying to figure out how to get the SKUVersion out of this query.
#SQLExpress: Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement10" -Class SqlServiceAdvancedProperty -ComputerName SERVERNAME | Format-Table ServiceName, PropertyName, PropertyNumValue, PropertyStrValue -AutoSize
#When I run one of the above depending on the server I get second output below. How do I just pull the SKUName property and Version like directly below?
#ServiceName         PropertyName      PropertyNumValue PropertyStrValue                                                                                                                                                           
#-----------         ------------      ---------------- ----------------                                         
#MSSQL$SQLEXPRESS    VERSION                            10.51.2500.0                       
#MSSQL$SQLEXPRESS    SKUNAME                            Express Edition with Advanced Services (64-bit)    
#ServiceName         PropertyName      PropertyNumValue PropertyStrValue                                                                                                                                                           
#-----------         ------------      ---------------- ----------------                                                                                                                                                           
#MSSQL$SQLEXPRESS    SQLSTATES                     2053                                                                                                                                                                            
#MSSQL$SQLEXPRESS    VERSION                            10.51.2500.0                                                                                                                                                               
#MSSQL$SQLEXPRESS    SPLEVEL                          1                                                                                                                                                                            
#MSSQL$SQLEXPRESS    CLUSTERED                        0                                                                                                                                                                            
#MSSQL$SQLEXPRESS    INSTALLPATH                        c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL                                                                                                          
#MSSQL$SQLEXPRESS    DATAPATH                           c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL                                                                                                          
#MSSQL$SQLEXPRESS    LANGUAGE                      1033                                                                                                                                                                            
#MSSQL$SQLEXPRESS    FILEVERSION                        2009.100.2500.0                                                                                                                                                            
#MSSQL$SQLEXPRESS    VSNAME                                                                                                                                                                                                        
#MSSQL$SQLEXPRESS    REGROOT                            Software\Microsoft\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS                                                                                                              
#MSSQL$SQLEXPRESS    SKU                     4161255391                                                                                                                                                                            
#MSSQL$SQLEXPRESS    SKUNAME                            Express Edition with Advanced Services (64-bit)                                                                                                                            
#MSSQL$SQLEXPRESS    INSTANCEID                         MSSQL10_50.SQLEXPRESS                                                                                                                                                      
#MSSQL$SQLEXPRESS    STARTUPPARAMETERS                  -dc:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\master.mdf;-ec:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\Log\ERRORLOG;-lc...
#MSSQL$SQLEXPRESS    ERRORREPORTING                   0                                                                                                                                                                            
#MSSQL$SQLEXPRESS    DUMPDIR                            c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\LOG\                                                                                                     
#MSSQL$SQLEXPRESS    SQMREPORTING                     0                                                                                                                                                                            
#MSSQL$SQLEXPRESS    ISWOW64                          0                                                                                                                                                                            
#SQLAgent$SQLEXPRESS ERRORREPORTING                   0                                                                                                                                                                            
#SQLAgent$SQLEXPRESS DUMPDIR                            c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\LOG\                                                                                                     
#SQLAgent$SQLEXPRESS SQMREPORTING                     0                                                                                                                                                                            
#SQLAgent$SQLEXPRESS INSTANCEID                         MSSQL10_50.SQLEXPRESS                                                                                                                                                      
#SQLAgent$SQLEXPRESS CLUSTERED                        0                                                                                                                                                                            
#SQLAgent$SQLEXPRESS VSNAME                                                                                                                                                                                                        
#SQLAgent$SQLEXPRESS ISWOW64                          0                                                                                                                                                                            
#SQLBrowser          INSTANCEID                         MSSQL10_50.SQLEXPRESS                                                                                                                                                      
#SQLBrowser          CLUSTERED                        0                                                                                                                                                                            
#SQLBrowser          ERRORREPORTING                   0                                                                                                                                                                            
#SQLBrowser          DUMPDIR                            c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\LOG\                                                                                                     
#SQLBrowser          SQMREPORTING                     0                                                                                                                                                                            
#SQLBrowser          BROWSER                          1                                                                                                                                                                            
#SQLBrowser          ISWOW64                          0                                                                                                                                                                            
#mg48
#New Member
#
#Posts:26
#25 Jan 2012 04:28 AM
#This should help you get started. Not quite sure how to filter for the 2 properties. Sorry
#Get-WmiObject sqlserviceadvancedproperty -namespace "root\Microsoft\SqlServer\ComputerManagement10" -computername SERVERNAME | Select -Property PropertyName, PropertyNumValue | Where {$_.PropertyName -eq "SKU"}
#mg48
#New Member
#
#Posts:26
#25 Jan 2012 06:25 AM
#Okay - this is a bit rough and sure someone can come up with better method, but it will get you what you want: 
#$a = Get-WmiObject sqlserviceadvancedproperty -namespace "root\Microsoft\SqlServer\ComputerManagement10" -computername d00036882 | Select -Property PropertyName, PropertyNumValue, PropertyStrValue 
#foreach ($b in $a) 
#{ 
#if ($b.PropertyName -eq 'VERSION') {Write-Host $b.PropertyStrValue} 
#if ($b.PropertyName -eq 'SKU') {Write-Host $b.PropertyNumValue} 
#}
#Chad Miller
#Basic Member
#
#Posts:198
#25 Jan 2012 03:39 PM
#Here's another way: 
# 
#Get-WmiObject sqlserviceadvancedproperty -namespace "root\Microsoft\SqlServer\ComputerManagement10" -computername $env:computername |  Where {@("SKUNAME","VERSION") -contains $_.PropertyName } | SELECT __SERVER, PropertyStrValue
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Supress Printing Input Parameter information when calling stored procedure;
#Last Post 20 Jan 2012 11:02 AM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#19 Jan 2012 02:27 PM
#hi I have a powershell script that calls a stored procedure, whenever I call that procedure  from powershell.ext manualyy, Its printing input parameter  and Return parameter information 
#Is there any way to supress printing it? 
#Stored procedure returns a 0 or 1 based on db being online(NO Raise error in Proc) Inputs is @Database_Name
#This is the powershell script.
# try { NewBackupSqlDB "ServerName" "DBName" 
#            } 
#      catch { 
#      "Backup process failed"; $error[0] return 
#      } 
#Need to Supress the information below:
#CompareInfo : None XmlSchemaCollectionDatabase : XmlSchemaCollectionOwningSchema : XmlSchemaCollectionName : DbType : AnsiString LocaleId : 0 ParameterName : @database_name Precision : 0 Scale : 0 SqlDbType : VarChar SqlValue : UdtTypeName : TypeName : Value : Direction : Input IsNullable : False Offset : 0 Size : 500 SourceColumn : SourceColumnNullMapping : False SourceVersion : Current CompareInfo : None XmlSchemaCollectionDatabase : XmlSchemaCollectionOwningSchema : XmlSchemaCollectionName : DbType : Int32 LocaleId : 0 ParameterName : @rtn Precision : 0 Scale : 0 SqlDbType : Int SqlValue : UdtTypeName : TypeName : Value : Direction : Input IsNullable : False Offset : 0 Size : 0 SourceColumn : SourceColumnNullMapping : False SourceVersion : Current 
#This is the Function that's called from Powershell script
#function global:NewBackupSQLDB 
#( [string]$p_sqlServerName = ${throw "Missing sql server name "}, [string]$p_db = ${throw "Missing parameter database name"}, [string]$Query = ${throw "Missing Query"}, [string]$p_userName, [string]$p_password, [string]$ConnTimeout ) 
#{ 
#   write-Output("Running Backup on {0}" -f $p_db) 
#   Write-host "The Server Name is : "$p_sqlServerName 
#   Write-Output("ServerName: {0}" -f $p_sqlServerName) 
#   $InitialCatalog = "Master" 
#   $tsqlCmd = "DbOnlineCheck" 
#   $con = $null 
#   
#   if ( $p_userName -ne $null -and $p_userName.length -gt 0 ) 
#   
#{
#   $con = "Data Source={0};Initial Catalog={1};User ID={2};Password={3}" -f $p_sqlServerName, $initalCatalog, $p_userName, $p_password 
#   
#} 
#else { # Use Windows log on credential $con = "Data Source=TCP:{0};Integrated Security=SSPI;Persist Security Info=True;Initial Catalog={1}" -f $p_sqlServerName, $initalCatalog } 
#$cn = new-object System.Data.SqlClient.SqlConnection ($con) 
#$cn.Open() 
#$cmd2 = new-object "System.Data.SqlClient.SqlCommand" ("$tsqlCmd", $cn)
#$cmd2.CommandType = [System.Data.CommandType]"StoredProcedure" 
#$cmd2.Parameters.Add("@database_name", [System.Data.SqlDbType]"varChar", 500) 
#$cmd2.Parameters["@database_name"].Value = $p_db 
#$cmd2.Parameters.Add("@rtn",[System.Data.SqlDbType]"Int") 
#$cmd2.Parameters["@rtn"].Direction = [System.Data.ParameterDirection]"ReturnValue" 
#$cmd2.CommandTimeOut = 60000 
#$cmd2.ExecuteNonQuery() 
#$cn.Close() $DBOnline = $cmd2.Parameters['@rtn'].value 
#$DBOnline = $cmd2.Parameters['@rtn'].value
#If($DBOnline -eq 0) { write-Output "Database Offline Not Procceding" } If($DBOnline -eq 1) { write-output "DB Online Proceeding" } 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jan 2012 05:08 PM
#My guess is this it do some method call. Try piping the Add() method calls to out-null: 
#$cmd2.Parameters.Add("@rtn",[System.Data.SqlDbType]"Int") | out-null
#JR81
#New Member
#
#Posts:23
#20 Jan 2012 11:02 AM
#Thanks Chad, That seem to fix the issue, appreciated.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Invoke-sqlcmd Error;
#Last Post 19 Jan 2012 12:13 PM by Chad Miller. 6 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#18 Jan 2012 03:45 PM
#Hi I am using foreach loop and using invoke-sqlcmd to run a query against each database like this,
#foreach($db in $smosvr.Databases)
#{
# invoke-sqlcmd -Query "select * from sys.database_files" -ServerInstance instanceName -Database $db -Username sa -Password somepassword
#}
#checking profiler trace shows invoke-sqlcmd is passing my windows authentication credential even though i specify sa and password. Any way to force invoke-sqlcmd to use sql authentication?
#Thanks
#Jay
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jan 2012 03:59 AM
#When I run the following I see I make a SQL auth connection: 
#invoke-sqlcmd -Query 'select loginame from sysprocesses where spid = @@spid' -ServerInstance Win7boot\sql1 -database master -Username sa -password "mypassword"
#Results: 
#loginame 
#-------- 
#sa 
#How are you creating your $smosvr connection? Perhaps this is where you're seeing a Windows auth connection.
#JR81
#New Member
#
#Posts:23
#19 Jan 2012 07:07 AM
#Thanks Chad, I ran  your query and it returns, 'sa' but I am still getting the login failed error even after using sql authentication to connect to server
#note: I am able to connect using the same sa account using management studio ,query databases etc
#Any ideas?
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | out-null
#foreach ($svr in get-content "C:\Documents and Settings\xxxx\Desktop\AllServers.txt") 
#{
#    $mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection 
#    $mySrvConn.ServerInstance=$svr
#    $mySrvConn.LoginSecure = $false 
#    $mySrvConn.Login = "sa" 
#    $mySrvConn.Password = "SOMEPASSWORD"
#   
# $smosvr = new-object Microsoft.SqlServer.Management.SMO.Server($mySrvConn)
# write-host $smosvr.Name
# foreach ($db in $smosvr.databases | where-object {$_.Status -eq "Normal"} ) 
# {
#   Invoke-Sqlcmd -Query "select loginame from sysprocesses where spid=@@spid" -serverInstance $smosvr.Name -Database $db -Username sa -Password         "SOMEPASSWORD" 
#     }
#  
# }
#And the error i get is 
#Invoke-Sqlcmd : Cannot open database "[DATABASENAME]" requested by the login. 
#The login failed. Login failed for user 'sa'. At C:\Documents and Settings\xxxxx\Desktop\ListDatabases.ps1:36 char:23 
#+ Invoke-Sqlcmd <<<< -Query "select loginame from sysprocesses where spid=@@spid" -serverInstance $smosvr.Name -Database $db -Username sa -Password +"SOMEPASSWORD" 
#+ CategoryInfo : InvalidOperation: (:) [Invoke-Sqlcmd], SqlException + FullyQualifiedErrorId : SqlExectionError,Microsoft.SqlServer.Management.PowerShell.GetScriptCommand
#mg48
#New Member
#
#Posts:26
#19 Jan 2012 07:13 AM
#I may be wrong but your $db is the complete database object so try changing it to $db.Name.
#JR81
#New Member
#
#Posts:23
#19 Jan 2012 10:28 AM
#Thanks I totally missed it, that works now Thanks again. I am not sure how to mark this answered?
#mg48
#New Member
#
#Posts:26
#19 Jan 2012 10:29 AM
#You're welcome - as for marking it answered, I don't know either
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jan 2012 12:13 PM
#@mg48 $db.name -- good catch!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell speaks!
#Last Post 15 Jan 2012 11:48 AM by Drack69. 1 Replies.
#AuthorMessages
#Jason
#New Member
#
#Posts:1
#13 Jan 2012 03:12 PM
#I am needing help with using powershell to queary information from the SQL database. I need a user interface witch allows users to search for information, and then look in tables within a database and then either say it is there and read the information or if it is not there I need it to say that the information does not exist. I am only using one table in the database and only need to search for last names. I know it is simple, but i need help. Thanks.
#P.s. I need to use either mike or anna voices.
#Drack69
#New Member
#
#Posts:28
#15 Jan 2012 11:48 AM
#How about this? 
#I have a cmdlet I pass info off to that speaks for me. This is the core of the code. Maybe you can tweek it to do what you need 
######################## 
#$voice.Rate = -5 
##$voice.Volume = $Volume 
#$voice.Volume = 70 
#[Void]$voice.Speak("hat the information does not exist") 
###################################### 
#Here is my complete cmdlet 
#Function Invoke-Voice 
#{ 
#<# 
#.Synopsis 
#Speek a phrase 
#.Description 
#Speek a phrase supplied by the pipeline or command 
#.Parameter Text 
#The text you want spoken 
#.Parameter Rate 
#The rate you want it to speek 
#default is -5 
#.Parameter Volume 
#The volume (1-100) that you want it to speek at 
#Default is 50 
#.Example 
#"Test" | Invoke-Voice 
#Description 
#------------------- 
#Speeks the work "Test" 
#.Example 
#Invoke-Voice -Text "Test" -rate -5 -vomume 75 
#Description 
#------------------- 
#Speeks the word test at a volume level of 75% and a rate of -5 
#.Example 
#get-Content Names.txt 
#Description 
#------------------- 
#Reads the contents of the names.txt file 
#.Link 
#.Notes 
#Author: Johnny Leuthard 
##> 
#[cmdletbinding(SupportsShouldProcess=$true)] 
#Param 
#( 
#[Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)] 
#$Text, 
#[Parameter(ValueFromPipeline=$false,Position=1,Mandatory=$false)] 
#$Rate = -5, 
#[Parameter(ValueFromPipeline=$false,Position=2,Mandatory=$false)] 
#$Volume = 50 
#) 
#Begin 
#{ 
#write-host 
#$voice = New-Object -ComObject SAPI.SPVoice 
#} 
#Process 
#{ 
###Speak the latest error message 
##$error | % { (New-Object -ComObject SAPI.SPVoice).Speak($_.Message) } 
#$voice.Rate = $Rate 
##$voice.Volume = $Volume 
#$voice.Volume = $Volume 
#[Void]$voice.Speak($Text) 
#} 
#End 
#{ 
#Write-Host 
#} 
#}#End Function 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#problem looking at database information on a cluster through powershell
#Last Post 11 Jan 2012 05:48 AM by jspatz. 2 Replies.
#AuthorMessages
#jspatz
#New Member
#
#Posts:3
#04 Jan 2012 10:52 AM
#We have a sql server cluster and the instance name of the server   is   sql-spoint\sharepoint  however when you go into powershell on one of the two nodes that is currently hosting the active partition   if you do a change directory to    SQLSERVER\SQL  the machine name down the line is the name of the server  sql-node01 .. so the problem is
#I CAN do a 
#cd sqlserver\sql\sql-node01\sharepoint     and when I do a dir  I see the databases childitem but I can't change to that folder it tells me it doesn't exist... but I also can't cd to sqlserver\sql\sql-spoint\sharepoint    
#I CAN use the SMO using the cluster name and can query against the databases that way .. but I was hoping to be able to work the other way as well.  Is this a simple fix am I missing something?
#(on my single node servers like development I have no problem as the instance names are the same as the server names)
#Chad Miller
#Basic Member
#
#Posts:198
#04 Jan 2012 06:29 PM
#You should be using the cluster virtual name. Just as you can't connect to phyiscalnode\sqlinstance in SQL Server Management Studio you can't connect to physicalnode\sqlinstance in SMO or sqlps. 
#On my clustered servers I can use: 
#CD SQLSERVER:\SQL\VIRTUALName\SQLINSTANCE just fine.
#jspatz
#New Member
#
#Posts:3
#11 Jan 2012 05:48 AM
#And there was my Uh-Duh moment .. thank you for showing me the error of my ways ..  :-)
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Invoke-PolcyEvaluation always returns false
#Last Post 15 Dec 2011 08:30 AM by Chad Miller. 14 Replies.
#AuthorMessages
#mg48
#New Member
#
#Posts:26
#05 Dec 2011 06:25 AM
#I am trying to figure out what is wrong with this piece of code. I have a condition that checks the data space used against the max size. The policy looks for data that stays below 90% of max. If it is reaches 90% or more this policy should return a Result of False. The problem I am having is that every database I try returns False whether or not the policy is violated. Evaluating the Policy in SSMS works just fine as does TargetServer but I need to find the individual databases that have issues.
#If anyone has any ideas, I would really appreciate it. 
#$db=gi sqlserver:\sql\D000XXX\default\databases\Northwind
#gci -path SQLSERVER:\SQLPolicy\D000XXX\default\Policies |
#where {$_.Name -eq 'MaxSizeDataFile'} |
#Invoke-PolicyEvaluation -TargetObjects $db |
#ft Result -autosize
#Chad Miller
#Basic Member
#
#Posts:198
#05 Dec 2011 08:41 AM
#What results do you get back for this? 
#Invoke-PolicyEvaluation -TargetObjects $db |foreach-object {$_.ConnectionEvaluationHistories} | foreach-Object {$_.EvaluationDetails} | select TargetQueryExpression, Result, Exception
#mg48
#New Member
#
#Posts:26
#05 Dec 2011 09:06 AM
#Result - False
#Exception:
#Microsoft.SqlServer.Management.Dmf.PolicyEvaluationException: Exception encountered while executing policy 'MaxSizeDataFile'.  ---
#> Microsoft.SqlServer.Management.Dmf.MissingTypeFacetAssociationException: There is no association between type 'Database' and facet 'DataFile'. 
#at Microsoft.SqlServer.Management.Facets.FacetRepository.VerifyAssociation(Type target, Type facet)                            
#at Microsoft.SqlServer.Management.Facets.FacetRepository.GetAdapterObject(Object target, Type facet)                           
#at Microsoft.SqlServer.Management.Facets.FacetEvaluationContext.GetFacetEvaluationContext(String facetName, Object target)     
#at Microsoft.SqlServer.Management.Dmf.Condition.Evaluate(Object target, AdHocPolicyEvaluationModeevaluationMode)              
#                                                               --- End of inner exception stack trace ---
#Chad Miller
#Basic Member
#
#Posts:198
#07 Dec 2011 05:06 PM
#Hmm, this is hard to troubleshoot without the policy, but I wonder if you need to provide a filegroup or file to as input. What facet is your policy attached to? 
#If you need to get to the file you would use this: 
#$file=gi sqlserver:\sql\D000XXX\default\databases\Northwind | %{$_.FileGroups} | %{$_.Files}
#$file | foreach {Invoke-PolicyEvaluation -TargetObjects $_ .....} 
#mg48
#New Member
#
#Posts:26
#08 Dec 2011 05:51 AM
#The facet it is attached to is DataFile and I created a condition using the MaxSize and UsedSpace properties - Multiply(Divide(@UsedSpace, @MaxSize), 100) < 90
#mg48
#New Member
#
#Posts:26
#08 Dec 2011 06:20 AM
#Posted By mg48 on 08 Dec 2011 06:51 AM 
#The facet it is attached to is DataFile and I created a condition using the MaxSize and UsedSpace properties - Multiply(Divide(@UsedSpace, @MaxSize), 100) < 90 
#your last line has -TargetObjects $_.....   What are the dots for?
#Chad Miller
#Basic Member
#
#Posts:198
#08 Dec 2011 12:18 PM
#umm, Its a ellipsis representing the rest of your code: 
#$file | foreach {Invoke-PolicyEvaluation -TargetObjects $_ } | foreach-object {$_.ConnectionEvaluationHistories} | foreach-Object {$_.EvaluationDetails} | select TargetQueryExpression, Result, Exception
#mg48
#New Member
#
#Posts:26
#09 Dec 2011 05:27 AM
#Duh - sorry - bad day yesterday. I set location to the Policy store and added the policy name. Now I am getting a different error. 
#Invoke-PolicyEvaluation : Cannot find the path specified in 'MaxSizeDataFile' in the FileSystem. 
#At line:1 char:41 
#+ $file | foreach {Invoke-PolicyEvaluation <<<< -Policy MaxSizeDataFile -TargetObjects $_ } | foreach-object {$_.Conne 
#ctionEvaluationHistories} | foreach-Object {$_.EvaluationDetails} | select TargetQueryExpression, Result, Exception 
#+ CategoryInfo : InvalidArgument: (:) [Invoke-PolicyEvaluation], SqlPowerShellIn...nitionException 
#+ FullyQualifiedErrorId : PolicyEvaluationError,Microsoft.SqlServer.Management.PowerShell.InvokePolicyEvaluationCo 
#mmand 
#Chad Miller
#Basic Member
#
#Posts:198
#09 Dec 2011 05:35 PM
#Can you attached the policy file? Add Reply screen has an attachments button. I'm not sure if the type of files are restricted.
#mg48
#New Member
#
#Posts:26
#12 Dec 2011 04:25 AM
#looks like it accepted the xml file.
#MaxSizeDataFile.xml
#Chad Miller
#Basic Member
#
#Posts:198
#12 Dec 2011 10:46 AM
#I imported your policy and ran it successfully in SSMS and Powershell. Here's the syntax I used to execute from sqlps: 
#SQLSERVER:\SQLPolicy\Z109943W\SQL1\Policies>$policy = get-item MaxSizeDataFile
#SQLSERVER:\SQLPolicy\Z109943W\SQL1\Policies>invoke-policyevaluation -Policy $policy -TargetServerName
#$env:computername\sql1
#   ID Policy Name                    Result Start Date         End Date           Messages
#   -- -----------                    ------ ----------         --------           --------
#    1 MaxSizeDataFile                True   12/12/2011 2:39 PM 12/12/2011 2:39 PM
#Using the code I originally to see detailed execution results which includes the database and files: 
#SQLSERVER:\SQLPolicy\Z109943W\SQL1\Policies>invoke-policyevaluation -Policy $policy -TargetServerName $env:computername\sql1 |foreach-object {$_.ConnectionEvaluationHistories} | foreach-Object {$_.EvaluationDetails} | select TargetQueryExpression, Result, Exception | ft -auto
#WARNING: column "Exception" does not fit into the display and was removed.
#TargetQueryExpression                                                                                              Resu
#                                                                                                                     lt
#---------------------                                                                                              ----
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorks\FileGroups\PRIMARY\Files\AdventureWorks_Data                 True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorks_dbss\FileGroups\PRIMARY\Files\AdventureWorks_Data            True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorksDW\FileGroups\PRIMARY\Files\AdventureWorksDW_Data             True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorksDW2008R2\FileGroups\PRIMARY\Files\AdventureWorksDW2008R2_Data True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorksLT\FileGroups\PRIMARY\Files\AdventureWorksLT_Data             True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\AdventureWorksLT2008R2\FileGroups\PRIMARY\Files\AdventureWorksLT2008R2_Data True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\backupdw\FileGroups\PRIMARY\Files\backupdw                                  True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\dbautility\FileGroups\PRIMARY\Files\dbautility                              True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\master\FileGroups\PRIMARY\Files\master                                      True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\model\FileGroups\PRIMARY\Files\modeldev                                     True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\msdb\FileGroups\PRIMARY\Files\MSDBData                                      True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\ReportServer$SQL1\FileGroups\PRIMARY\Files\ReportServer$SQL1                True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\ReportServer$SQL1TempDB\FileGroups\PRIMARY\Files\ReportServer$SQL1TempDB    True
#SQLSERVER:\SQL\Z109943W\SQL1\Databases\tempdb\FileGroups\PRIMARY\Files\tempdev                                     True
#Seems to work fine.
#mg48
#New Member
#
#Posts:26
#12 Dec 2011 11:51 AM
#I have no idea why it didn't work last week, but the script with the foreach file works. Nothing else does. I find it strange that MSDN documentation for the cmdlet isn't correct. Oh well I thank you for you help. I subscribe to your blog and I have found it to extremely helpful!
#Chad Miller
#Basic Member
#
#Posts:198
#12 Dec 2011 12:12 PM
#You're welcome. BTW -- I also have a PBM module as part of sqlpsx CodePlex project. http://sqlpsx.codeplex.com. Even if you don't use the module, checking out the code in the module can helpful--in fact I pulled some of the code for this forum post from the PBM module.
#mg48
#New Member
#
#Posts:26
#15 Dec 2011 06:49 AM
#I don't see a way to mark a questioned as answered. Is there a way? It would be helpful when searching the forums.
#Chad Miller
#Basic Member
#
#Posts:198
#15 Dec 2011 08:30 AM
#I'm not sure. The forum software and lack of moderators are an issue. There is suggestion/feedback area. You can post you general questions on how to use the forums there. I asked for several changes 8 months including adding moderators, but nothing has been done: 
#http://www.powershellcommunity.org/...fault.aspx
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Return Value from Stored Proc;
#Last Post 15 Dec 2011 01:37 AM by djh53. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#14 Dec 2011 10:29 AM
#Have a stored proc that's returning a value (0/1) but everytime i call that proc from Powershell I seem to be getting 0(when it should be 1) Same query executed from SSMS returns correct results. 
#This is the structure of proc 
#CREATE PROC usp_DBExists 
#@DBName varchar(500) ='model' 
#as 
#BEGIN 
#IF NOT EXISTS(select 1 from sys.databases where name =@DBName) 
#Return 0 
#ELSE 
#Return 1 
#END 
#I call this proc from a function and followed the thread here to capture return value, but still getting 0 when i pass a existing DBName as input
# 
#http://www.powershellcommunity.org/...fault.aspx 
#Snippet of function 
#function global:DBCheck 
#( [string]$p_sqlServerName = ${throw "Missing sql server name "}
#, [string]$p_db = ${throw "Missing parameter database name"}
#, [string]$p_userName
#, [string]$p_password
#, [string]$ConnTimeout )
#$InitialCatalog = "Master" $tsqlCmd = "EXEC master.dbo.usp_DBExists '{0}';" -f $p_db
#$cn = new-object System.Data.SqlClient.SqlConnection ($con) 
#$con = "Data Source={0};Initial Catalog={1};User ID={2};Password={3}" -f $p_sqlServerName, $initalCatalog, $p_userName, $p_password 
#$cn.Open() 
#$cmd2 = new-object "System.Data.SqlClient.SqlCommand" ($tsqlCmd, $cn) 
#$cmd2.Parameters.Add("@Status", [System.Data.SqlDbType]"Int") 
#$cmd2.Parameters["@Status"].Direction = [System.Data.ParameterDirection]"ReturnValue" 
#$cmd2.CommandTimeOut = 10 
#$cmd2.ExecuteNonQuery() 
#$cmd2.Parameters["@Status"].Value ------PRINTING 0 always
#$cn.Close()
#Chad Miller
#Basic Member
#
#Posts:198
#14 Dec 2011 03:37 PM
#This works for me: 
#$serverName='Win7boot\SQL1' 
#$databaseName='tempdb' 
#$query='usp_DBExists' 
#$DBName='model' 
#$connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;" 
#$conn = new-object System.Data.SqlClient.SqlConnection $connString 
#$conn.Open() 
#$cmd = new-object System.Data.SqlClient.SqlCommand("$query", $conn) 
#$cmd.CommandType = [System.Data.CommandType]"StoredProcedure" 
#$cmd.Parameters.Add("@Status", [System.Data.SqlDbType]"Int") 
#$cmd.Parameters["@Status"].Direction = [System.Data.ParameterDirection]"ReturnValue" 
##$cmd.Parameters.Add("@DBName", [System.Data.SqlDbType]"VarChar", 500) 
##$cmd.Parameters["@DBName"].Value = $DBName 
#$cmd.ExecuteNonQuery() | out-null
#$conn.Close() 
#$cmd.Parameters["@Status"].Value 
#djh53
#New Member
#
#Posts:31
#15 Dec 2011 01:37 AM
#Chad's code works for me, with two changes:
#$serverName - yours
#$databaseName - given your function, should be master
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Error calling Invoke-sqlcmd;
#Last Post 12 Dec 2011 01:13 PM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#12 Dec 2011 11:16 AM
#I tried using invoke-sqlcmd, so I tried adding that snap-in unfortunately getting this error
#"PS C:\Users\DBAUser> Add-PSSnapin SqlServerCmdletSnapin100 Add-PSSnapin :The Windows PowerShell snap-in 'SqlServerCmdletSnapin100' is not installed on this machine."
#Any way to add the SQL Server snapin?
#Chad Miller
#Basic Member
#
#Posts:198
#12 Dec 2011 12:16 PM
#A couple of ways. First do you have SQL Server 2008 or higher SQL Server Management Studio installed? If you don't it might easier just to use simply function rather than install. Here's function called invoke-sqlcmd2: 
#Download the code and source the function: 
#http://poshcode.org/2279 
#. ./invoke-sqlcmd2 
#Note that's dot space dot forward slash.
#JR81
#New Member
#
#Posts:23
#12 Dec 2011 01:13 PM
#Thanks Chad, that's very much appreciated.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Passing XML from PowerShell Function to Stored Procedure
#Last Post 12 Dec 2011 05:46 AM by JR81. 2 Replies.
#AuthorMessages
#JR81
#New Member
#
#Posts:23
#08 Dec 2011 08:33 PM
#Hi, I am calling a Powershell Function passing various parameters , One of the parameter is an XML datatype(also input parameter to stored procedure). The Function Executes a stored proc. But when pass a xml data type I am getting this error. When I exclude the xml parameter function works.
#Maint process failed
#xmlTest : Cannot process argument transformation on parameter 'p_path'. Cannot convert value "'" to type "System.Xml.XmlDo
#cument". Error: "Data at the root level is invalid. Line 1, position 1."
# CategoryInfo          : InvalidData: (:) [xmlTest], ParameterBindin...mationException
# FullyQualifiedErrorId : ParameterArgumentTransformationError,xmlTest
#When I try omitting the xml parameter it works. This is the format of the XML Parameter
#I escape the double quote using backtick `
#When I execute the stored procedure form SQL Server Management studio i don't get any errors passing same parameter? Please help.
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#10 Dec 2011 05:59 AM
#This is a little difficult to troubleshoot without any supporting code, but I'll try. I ran a quick test using the sample Northwind database and I'm not having any issues: 
#Stored procedure from http://weblogs.asp.net/jgalloway/ar...eters.aspx 
#CREATE PROCEDURE SelectByIdList(@productIds xml) AS
#DECLARE @Products TABLE (ID int) 
#INSERT INTO @Products (ID) SELECT ParamValues.ID.value('.','VARCHAR(20)')
#FROM @productIds.nodes('/Products/id') as ParamValues(ID) 
#SELECT * FROM 
#    Products
#INNER JOIN 
#    @Products p
#ON    Products.ProductID = p.ID
#--EXEC SelectByIdList @productIds='<Products><id>3</id><id>6</id><id>15</id></Products>'
#Executing in Powershell using Invoke-sqlcmd: 
#invoke-sqlcmd -ServerInstance Win7boot\sql1 -Database Northwind -Query "EXEC SelectByIdList @productIds='<Products><id>3</id><id>6</id><id>15</id></Products>'"
#Results: 
#ProductID : 3 
#ProductName : Aniseed Syrup 
#SupplierID : 1 
#CategoryID : 2 
#QuantityPerUnit : 12 - 550 ml bottles 
#UnitPrice : 10.0000 
#UnitsInStock : 13 
#UnitsOnOrder : 70 
#ReorderLevel : 25 
#Discontinued : False 
#ID : 3 
#....
#JR81
#New Member
#
#Posts:23
#12 Dec 2011 05:46 AM
#Thanks Chad, I wasn't using invoke-sqlcmd, i will use that.
#Jay
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#sqlcmd password with special characters
#Last Post 08 Dec 2011 12:27 PM by Chad Miller. 1 Replies.
#AuthorMessages
#jpmorgan
#New Member
#
#Posts:1
#08 Dec 2011 11:47 AM
#So the password param has the ")" in it and powershell is throwing an unexpected token error. 
#Help! :)
#Param ( [string] $ServerName, [string] $UserName, [string] $Password, [string] $DatabaseName, [string] $OutputDir)
#$expr = "sqlcmd" 
#$expr = $expr + " -U " + $UserName 
#$expr = $expr + " -P " + $Password 
#$expr = $expr + " -S " + $ServerName 
#$expr = $expr + " -d " + $DatabaseName 
#$expr = $expr + " -Q ""SET NOCOUNT ON SELECT DISTINCT * FROM Foo """ 
#$expr = $expr + " -o " + $TempFileName 
#$expr = $expr + " -s ""|""" 
#$expr = $expr + " -W" 
#$expr = $expr + " -h -1" 
#$expr = $expr + " -u" 
## Invoke SqlCmd. This will output the result to the temporary file.
# invoke-expression -command $expr
#Chad Miller
#Basic Member
#
#Posts:198
#08 Dec 2011 12:27 PM
#start-process -NoNewWindow -FilePath sqlcmd -ArgumentList @"
#-U $UserName  -P $Password  -S $ServerName -d $DatabaseName -Q "SET NOCOUNT ON SELECT DISTINCT * FROM Foo" -o $TempFileName -s "|" -W -h -1 -u
#"@
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Build String for Columns on a Table
#Last Post 08 Dec 2011 07:59 AM by Tea. 2 Replies.
#AuthorMessages
#Tea
#New Member
#
#Posts:6
#07 Dec 2011 01:52 PM
#Hello, I am trying to build a string variable that contains a comma delimited list of all of the columns on a particular table. However my final output string is only displaying the first column. Im sure my issue is very minor, but i have not been able to figure it out yet. If someone could help me it would be greatly appreciated. My current location is under the Columns SMO structure. Below is my code. 
#[array]$ColumnArray = get-childitem | select name 
#$ArrayCount = 1 
#$ColumnString = $ColumnArray[0] 
#while (($ColumnArray[$ArrayCount]) -eq $True) 
#   { 
#   $ColumnString = ($ColumnString + ", " + ($ColumnArray[$ArrayCount])) 
#   $ArrayCount = ($ArrayCount + 1) 
#   }
#Chad Miller
#Basic Member
#
#Posts:198
#07 Dec 2011 05:22 PMAccepted Answer 
#Powershell has a -join operator so you could rewritten your code as this: 
#$columnArray = get-childitem | select name 
#($columArray | select -expandproperty name) -join ","
#Tea
#New Member
#
#Posts:6
#08 Dec 2011 07:59 AM
#Thanks a lot!!! Thats exactly what i needed!!!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How Process Data from Invoke-SqlCmd
#Last Post 30 Nov 2011 12:57 PM by Tea. 3 Replies.
#AuthorMessages
#Tea
#New Member
#
#Posts:6
#29 Nov 2011 12:29 PM
#Hello, i have a powershell script that is designed to find all of the Schemabound views and functions that are referencing a specific table and then script those out. However after running the invoke-sqlcmd the data is returned as a datarow. I also sometimes recieve the following error message: Method invocation failed because [System.Object[]] doesn't contain a method named 'script'.
#Can anyone tell me what i am doing wrong?? It works fine if the sql query only returns one object, but if returns 2 or more it errors out.  Here is my powershell code. 
#$SchemaBoundObjects = (Invoke-SqlCmd "SELECT Distinct Schema_name(o.schema_id) as [Schema], o.name as ObjectName, Type = CASE o.type WHEN 'V' Then 'Views' ELSE 'UserDefinedFunctions' END, ed.referenced_schema_name as Ref_Schema, ed.referenced_entity_name as Ref_Table FROM sys.sql_expression_dependencies ed join sys.objects o on o.object_id = ed.referencing_id where ed.referenced_schema_name = 'dbo' and ed.referenced_entity_name = 'TestTable' and ed.is_schema_bound_reference = 1 and o.type in ('V', 'FN', 'IF', 'TF', 'FS', 'FT')") 
#Foreach ($row in $SchemaBoundObjects) 
#{ 
#$Sch = $SchemaBoundObjects.Schema 
#$Name = $SchemaBoundObjects.ObjectName 
#$Type = $SchemaBoundObjects.Type 
#set-location "sqlserver:\SQL\servername\instancename\Databases\DatabaseName\$Type" 
#$ScriptObject = gci | where {$_.schema -eq $Sch -and $_.Name -eq $Name} 
#$ScriptObject.script() 
#}
#Tea
#New Member
#
#Posts:6
#29 Nov 2011 01:39 PM
#The issue seems to be that my $Sch, $Name, and $Type variables are not being assigned the correct values for each of the rows returned from the Invoke-SqlCmd....but i have no idea how to fix this....
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2011 05:54 PMAccepted Answer 
#Based on your code, you should use: 
#$Sch = $row.Schema 
#$Name = $row.ObjectName 
#$Type = $row.Type
#Tea
#New Member
#
#Posts:6
#30 Nov 2011 12:57 PM
#Thanks Chad!!! This solved my problem. I appreciate your help!!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Howto insert into table
#Last Post 29 Nov 2011 08:34 PM by sunihd. 7 Replies.
#AuthorMessages
#trebboR
#New Member
#
#Posts:8
#23 Aug 2011 02:17 PM
#Hello Community,
#I wanna make a script:
#**NO CODE >insert into table2 (Directoriesfound,LastWriteTime) from Get-Item C:\Windows | Where {$_.psIsContainer -eq $true}**,
#i wanna do this every night so i have a SQL Table like this: (Id, Name, LastWriteTime) where i can search for directorie names from a website (asp)
#How do i start?, 
#i have something like this
#One DB: 
#db1,
#2 tabels: 
#table1(Id,Directories2search,ONOFF) with 2 datarows: [1,C:\Windows,ON],[2,C:\Test,ON],
#table2(Id,Directoriesfound,LastWriteTime) with a lot of datarows: [1, C:\Windows\dir1, 2011-08-24 23:59:01],[2, C:\Windows\dir2, 2011-08-22 22:59:01],Enz
#$IDAutoNumber = 1000000
#$serverName = "Server1"            
#$databaseName = "DB1"
#$Connection = New-Object System.Data.SQLClient.SQLConnection
#$Connection.ConnectionString ="Server=$serverName;Database=$databaseName;trusted_connection=true;"
#$Connection.Open() 
#$Command = New-Object System.Data.SQLClient.SQLCommand
#$Command.Connection = $Connection 
#$DIRROOT = "C:\Windows\*"
#$DT = Get-Item $DIRROOT | Where {$_.psIsContainer -eq $true} |  select -exp Name
#$DT2 = Get-Item $DIRROOT | Where {$_.psIsContainer -eq $true} |  select -exp LastWriteTime 
#foreach ($Namexx in $DTRR.Name) {
#$IDAutoNumber = $IDAutoNumber+1
#$Command.CommandText ="INSERT INTO table2 (ID,Name,LastWriteTime) VALUES ('$IDAutoNumber','$DT','$DT2')"
#} 
#$Command.ExecuteNonQuery() 
#$Connection.Close()
#When i run this i can only run it against a directorie with one subdir, with more than one i get error's.
#trebboR
#Chad Miller
#Basic Member
#
#Posts:198
#23 Aug 2011 03:50 PM
#A few problems, first you're not looping through your output. Notice you assign values to your $DT and $DT2 variable outside your foreach block i.e. foreach { }. The other thing I would suggest is since you're creating a T-SQL insert statement make sure the generated statement is correct. And lastly SQL Server has something called and Identity column so you don't have to calculate an autonumber. Here's a completed script I've tested on my machine: 
# 
##Create a table in SQL Server Management Studio with an Identity (autonumber) column as follows:
#CREATE TABLE [dbo].[table2](
#    [ID] [int] IDENTITY(1,1) NOT NULL,
#    [Name] [varchar](255) NULL,
#    [LastWriteTime] [datetime] NULL
#)
#$serverName = "Server1"           
#$databaseName = "DB1"
#$Connection = New-Object System.Data.SQLClient.SQLConnection
#$Connection.ConnectionString ="Server=$serverName;Database=$databaseName;trusted_connection=true;"
#$Connection.Open()
#$Command = New-Object System.Data.SQLClient.SQLCommand
#$Command.Connection = $Connection
#$DIRROOT = "C:\Windows\*"
#Get-Item $DIRROOT | Where {$_.psIsContainer -eq $true} | foreach {
#    #write-host "INSERT INTO table2 (Name,LastWriteTime) VALUES ('$($_.Name)','$($_.LastWriteTime)')"
#    $Command.CommandText = "INSERT INTO table2 (Name,LastWriteTime) VALUES ('$($_.Name)','$($_.LastWriteTime)')"
#    $Command.ExecuteNonQuery() | out-null
#   
#}
# $Connection.Close()
#trebboR
#New Member
#
#Posts:8
#31 Aug 2011 12:12 PM
#@Chad, 
#thanks for pointing out to me the autonumbering in the SQL table, 
#With your help i managed to get it working, like i wanted. 
#Can you help me with how to put a jpg into the sql bd table ? 
#Do you have a little example? 
#-=[Respect]=-
#Chad Miller
#Basic Member
#
#Posts:198
#31 Aug 2011 01:10 PM
#I've done a blog post about importing and exporting blobs (binary files) http://sev17.com/2010/05/t-sql-tues...owershell/ 
#The post details various methods.The easiest method is to use OPENROWSET: 
#USE AdventureWorks2008;
#INSERT INTO Production.ProductPhoto2 (ThumbNailPhoto, ThumbnailPhotoFileName)
#   SELECT *, 'hotrodbike_black_small.gif' AS ThumbnailPhotoFileName
#    FROM OPENROWSET(BULK N'C:\Users\u00\hotrodbike_black_small.gif', SINGLE_BLOB) AS ProductPhoto
#GO
#trebboR
#New Member
#
#Posts:8
#01 Sep 2011 12:23 PM
#Oke that's nice, Great blog !
#I have got it working on sql 2005 now without the AdventureWorks2008 DB. 
#Works: Bulk retrive binary from table to file with same name. 
#Works: Single Picture to Table. 
#Works: on bulk file 2 binary into table: Made it as a function. var the filename's. 
#no-go: get html/asp to show binary from table as picture: 
#Microsoft VBScript runtime error '800a000d' Type mismatch
#Searching ..... 
#PS: Do you have written something about index's ? 
#I think i will need some table tunning when i am done. ;) 
#Thanks Chad. 
#-=[Respect]=- 
#Chad Miller
#Basic Member
#
#Posts:198
#01 Sep 2011 12:42 PM
#Thanks 
#So displaying the images in ASP, that's no longer a Powershell solution, but fellow Powershell MVP, Max Trinidad has a blog post where he includes an ASP.NET page for viewing images stored in SQL Server 
#http://www.maxtblog.com/2011/06/pow...lob-table/ 
#hirecrishecom
#New Member
#
#Posts:3
#28 Nov 2011 01:44 AM
#First of all create table & then Create a Store Procedure ... like below(this is example of insert into Admin User table ) 
#Create PROCEDURE [dbo].[InsertAdminUser] ( 
#@UserId BIGINT OUTPUT, 
#@UserName NVARCHAR(64), 
#@Password NVARCHAR(64), 
#@IsDeleted BIT 
#) AS 
#BEGIN 
#INSERT INTO [AdminUser] ( 
#[UserName], 
#[Password], 
#[IsDeleted] 
#) 
#VALUES ( 
#@UserName, 
#@Password, 
#@IsDeleted 
#) 
#SELECT @UserId = SCOPE_IDENTITY() 
#RETURN 0; 
#END
#ecommerce-development company , Sharepoint Development Company , ASP.Net Development Company , PHP Development Company 
#sunihd
#New Member
#
#Posts:2
#29 Nov 2011 08:34 PM
#good example for insert values in sql server using powershell
#International Hotel Development , hotel consultancy , International Hotel Development services , Hotel Reservation System , Hospitality Education , Hotel Franchising and Management , hotel franchises , international hotel investment , hotel management services , hotel reservation services 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Stored Procedures through ODBC
#Last Post 28 Nov 2011 01:39 AM by hirecrishecom. 5 Replies.
#AuthorMessages
#wifeaggro
#New Member
#
#Posts:6
#30 Jul 2011 05:43 AM
#Same question I had earlier this year, but I'm going to use the correct terminology this time around.
#I'm having difficulty calling stored procedures through PowerShell with an ODBC driver.  Connection isn't an issue, but I don't receive any results after running the stored procedure.  I do however know that the query does run and performs whatever I'm calling
#Example below:
#$query="sp_locklogin $userid, unlock"
#$cmd=new-object System.Data.OdbcCommand($query, $connection)
#$cmd.CommandTimeout=30
#$ds=New-Object system.Data.DataSet
#$da=New-Object system.Data.odbc.odbcDataAdapter($cmd)
#$da.fill($ds)
#$ds.Tables[0]
#When unlocking or resetting a user's account, this isn't an issue.  Because I can output my own message when it's successful.  This is an issue when I want to display an account's information with "sp_displaylogin".  In the example above, $ds.Tables is empty.  The $ds variable contains information, but the Table property is empty.  Any suggestions would be greatly appreciated.  Please let me know if any additional information is needed.
#Chad Miller
#Basic Member
#
#Posts:198
#01 Aug 2011 05:50 PM
#Is it just sp_displaylogin that doesn't return a datatable? For instance is you used $query = "select 'Hello World'"
#Are you getting a dataset and datatable?
#wifeaggro
#New Member
#
#Posts:6
#02 Aug 2011 04:05 AM
#I do receivea valid return with that query. 
#Column1 
#------- 
#Hello World
#Chad Miller
#Basic Member
#
#Posts:198
#02 Aug 2011 05:47 AM
#As I said last year my guess is that Sybase uses PRINT or DBCC output to return data on certain commands including sp_displaylogin and if this is the case you'll need to attach an event handler to your connection object. Try this: 
#$connection = new-object ....< you did not post the full code listing, so after this statement add the event handler before calling open method on
#Register-ObjectEvent -InputObject $connection -EventName InfoMessage -Action { Write-Host "$($Event.SourceEventArgs)" } -SupportEvent
#$connection.Open()
#wifeaggro
#New Member
#
#Posts:6
#02 Aug 2011 06:51 AM
#I revisited my last post a couple of times and I must've been missing it, but that works perfectly. Ty sir.
#hirecrishecom
#New Member
#
#Posts:3
#28 Nov 2011 01:39 AM
#Dim ws As Worksheet 
#Dim qs As QueryTable 
#For Each ws In ThisWorkbook.Worksheets 
#For Each qs In ws.QueryTables 
#qs.Refresh BackgroundQuery:=True ' explicitly set background on 
#Next qs 
#Next ws
#ecommerce-development company , Sharepoint Development Company , ASP.Net Development Company , PHP Development Company 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Get SSAS Database Properties with PowerShell, AMO and SQLPSX
#Last Post 12 Nov 2011 05:21 AM by Chad Miller. 1 Replies.
#AuthorMessages
#kwi77
#New Member
#
#Posts:2
#07 Nov 2011 04:50 AM
#Hi,
#I'm using a script from Vidas Matelis as a base for collecting OLAP Data. I would like to get the servernames from a table which I'd like to read with Get-SQLData (from SQLPSX).
#As I'm still kind of a newbie, could someone help me to get this to work?
#Thanks lots.
##
## This script will list all SSAS databases and info about them (cubes and measure groups) from one instance
##
### Add the AMO namespace
#$loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
#$server = New-Object Microsoft.AnalysisServices.Server
#$server.connect(Get-SqlData 'N2648022\Instance' DBName "SELECT Name FROM tbl_Server_SQL_OLAP_2008")
#if ($server.name -eq $null) {
#Write-Output ("Server '{0}' not found" -f $ServerName)
#break
#}
#foreach ($d in $server.Databases )
#{
#Write-Output ( "Database: {0}; Status: {1}; Size: {2}MB" -f $d.Name, $d.State, ($d.EstimatedSize/1024/1024).ToString("#,##0") )
#foreach ($cube in $d.Cubes) {
#  Write-Output ( " Cube: {0}" -f $Cube.Name )
#  foreach ($mg in $cube.MeasureGroups) {
#   Write-Output ( "  MG: {0}; Status: {1}; Size: {2}MB"   -f $mg.Name.PadRight(25), $mg.State, ($mg.EstimatedSize/1024/1024).Tostring("#,##0"))
## Uncomment following 3 lines if you want to show partition info  
#  foreach ($part in $mg.Partitions) {
#   Write-Output ( "   Partition: {0}; Status: {1}; Size: {2}MB" -f $part.Name.PadRight(35), $part.State, ($part.EstimatedSize/1024/1024).ToString("#,##0") )
#  } # Partition
#} # Measure group
## Uncomment following 3 lines if you want to show dimension info
#foreach ($dim in $d.Dimensions) {
#  Write-Output ( "Dimension: {0}" -f $dim.Name)
#} # Dimensions
#} # Cube
#} # Databases
#Chad Miller
#Basic Member
#
#Posts:198
#12 Nov 2011 05:21 AM
#I noticed no one has responded to this question. I would say SQL Server Analysis Services is such niche topic. I never really used it and neither has most of the DBAs I know. The only thing Powershell related I've seen in this space is http://powerssas.codeplex.com/. You may want to post your question to an SSAS forum.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#DMX Query wrapped in PowerShell Code
#Last Post 12 Nov 2011 05:19 AM by Chad Miller. 1 Replies.
#AuthorMessages
#kwi77
#New Member
#
#Posts:2
#07 Nov 2011 10:22 AM
#Hi,
#Is it possible to wrap a DMX Query like
#select * from $system.discover_connections
#in a PowerShell Statement?
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#12 Nov 2011 05:19 AM
#I noticed no one has responded to this question. I would say SQL Server Analysis Services is such niche topic. I never really used it and neither has most of the DBAs I know. The only thing Powershell related I've seen in this space is http://powerssas.codeplex.com/. You may want to post your question to an SSAS forum.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Test if sql query returned rows - Invoke-Sqlcmd2
#Last Post 07 Nov 2011 08:50 PM by ashily. 2 Replies.
#AuthorMessages
#Rob Burgess
#New Member
#
#Posts:44
#30 Aug 2011 03:27 PM
#Hi
#What is the best way to test if an SQL query run using the Invoke-Sqlcmd2 function returned any rows?
#Chad Miller
#Basic Member
#
#Posts:198
#31 Aug 2011 08:59 AM
#One simple way is to assign the output variable and check if the variable is null. if ($dt) is a short way of saying if ($dt -ne $null) Here's example to test the no results use where 1 = 2: 
#$ServerInstance = "$env:computername\sql1"
#$dt = invoke-sqlcmd2 -ServerInstance $ServerInstance -Database master -Query "select 1 where 1 = 1"
#If ($dt)
#{ 
#    write-host 'hi'
#    #Do something
# }
# 
#ashily
#New Member
#
#Posts:3
#07 Nov 2011 08:50 PM
#Thanks for your reply. 
#_________________________________ 
#carte r4 
#carte r4 
#carte r4 
#r4 ds 
#r4 ds
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How do I Convert SQL Server Job Token to String?
#Last Post 03 Nov 2011 10:58 AM by Chad Miller. 1 Replies.
#AuthorMessages
#Steve
#New Member
#
#Posts:1
#03 Nov 2011 09:36 AM
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
#$a = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions 
#$a.ServerName = $(ESCAPE_SQUOTE(SRVR))
#In the above coding I get an error:  The error information returned by PowerShell is: 'The term Server\Instance' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.  '.  Process Exit Code -1.  The step failed.
#I tried to convert the string using tostring() that doesn't seem to work.  I don't know what to do I'm stuck now.  I really need to convert the token to a string.  Any help would be greatly appreciated.
#Chad Miller
#Basic Member
#
#Posts:198
#03 Nov 2011 10:58 AM
#ScriptingOptions doesn't have property called ServerName. I would suggest verifying the code works outside of SQL Agent first.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#exit code from job set
#Last Post 03 Nov 2011 10:44 AM by Chad Miller. 3 Replies.
#AuthorMessages
#Russell Young
#New Member
#
#Posts:4
#02 Nov 2011 01:05 PM
#I have the following script I run from a sql agent job.  I cannot get it to abend the job with it can't find one of the servers.
#FOREACH ($HOSTNAME IN GET-CONTENT "D:\CHECKSQLSERVER\SERVERLIST.TXT") { $status=get-wmiobject win32_pingstatus -Filter "Address='$hostname' " if($status.statuscode -ne 0) { "Computer $HOSTNAME not found" } exit 1 }
#Chad Miller
#Basic Member
#
#Posts:198
#02 Nov 2011 05:39 PM
#Are you using a cmdexec job step or a Powershell job step? 
#Standard a throw instead of an exit should set the errorlevel.
#Russell Young
#New Member
#
#Posts:4
#03 Nov 2011 05:27 AM
#powershell job step
#Chad Miller
#Basic Member
#
#Posts:198
#03 Nov 2011 10:44 AM
#Then I would change exit to throw or write-error and set your $ErrorActionPreference to Stop: 
#$ErrorActionPreference = 'Stop';
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Changing SQL User through SMO, WMI.
#Last Post 01 Nov 2011 12:30 AM by Basket-dan1. 2 Replies.
#AuthorMessages
#Basket-dan1
#New Member
#
#Posts:2
#27 Oct 2011 07:44 AM
#Hi there,
#I am trying to change the service user for MSSQL service, Agent Service, Analysis User etc. The following script extract should change the user and password of a Agent user.
#But I'm getting the error on a non clustered server. Message: Exception calling "SetServiceAccount" with "2" argument(s): "Set service account failed. " 
#I do have administrator rights on the server, but I can't get it to work. Can anybody help me? Thanks. 
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null 
#$SMOWmiserver = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $ComputerName 
#$ServicesAgent=$SMOWmiserver.Services | where {$_.displayname -match "Agent"} 
#$ServicesSorted2= $ServicesAgent | Sort-Object Displayname foreach ($service in $ServicesSorted2) 
#{ 
#$domain = "XY" 
#$user2= "XY" 
#$KontoMatch=$userliste | Where-Object {$_.User -eq $user2} 
#$neuesKontoPsw=$KontoMatch.Passwort 
#$domainuser2=$domain + "\" + $user2 
#$service.SetServiceAccount($domainuser2, $neuesKontoPsw) 
#}
#Chad Miller
#Basic Member
#
#Posts:198
#31 Oct 2011 03:28 AM
#I see a couple of issues with your foreach loop. I reworked your code as follows: 
#$CommputerName = "$env:computername"
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null 
#$SMOWmiserver = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $ComputerName 
#$ServicesAgent=$SMOWmiserver.Services | where {$_.displayname -match "Agent"} 
#$user2 = 'Contoso\myServiceAccount'
#$ServicesAgent | Where-Object {$_.ServiceAccount -eq $user2}  | foreach {$_.SetServiceAccount('Contoso\myServiceAccount','myPassword') }
#Basket-dan1
#New Member
#
#Posts:2
#01 Nov 2011 12:30 AM
#Hi Chad, 
#First of all, I wanted to say thank you for helping. 
#But I also have to apologize because I didn't gave you the the whole extract of my code. 
#I already did have this line in my code $CommputerName = "$env:computername" 
#and I wanted to import a csv datafile with username and password in $userliste and then try to match the new user with the list and put it on the service account. 
#I have managed to figure out that the problem was not my code. I have changed the password of the new user and then it worked. 
#So now I know that smo doesn't use Users which didn't have reseted their password for the first time. 
#Thx again, see you maybe next time! 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Email output from console
#Last Post 04 Oct 2011 04:43 PM by ET. 1 Replies.
#AuthorMessages
#tran008
#New Member
#
#Posts:8
#04 Oct 2011 11:08 AM
#Hi All,
#How can I captured the output from the script below and email as a body? 
#thanks
#foreach ($svr in get-content "C:\temp\Servers.txt"){
#    $svr
#    $dt = new-object "System.Data.DataTable"
#    $cn = new-object System.Data.SqlClient.SqlConnection "server=$svr;database=msdb;Integrated Security=sspi"
#    $cn.Open()
#    $sql = $cn.CreateCommand()
#    $sql.CommandText = "SELECT sjh.server,sj.name, CONVERT(VARCHAR(30),sjh.message) as message , sjh.run_date, sjh.run_time
#FROM msdb..sysjobhistory sjh
#JOIN msdb..sysjobs sj on sjh.job_id = sj.job_id
#JOIN (SELECT job_id, max(instance_id) maxinstanceid 
#FROM msdb..sysjobhistory 
#WHERE run_status NOT IN (1,4) 
#GROUP BY job_id) a ON sjh.job_id = a.job_id AND sjh.instance_id = a.maxinstanceid 
#WHERE    DATEDIFF(dd,CONVERT(VARCHAR(8),sjh.run_date), GETDATE()) <= 2"
#    $rdr = $sql.ExecuteReader()
#    $dt.Load($rdr)
#    $cn.Close()
#    $dt | Format-Table -autosize
#}
#ET
#New Member
#
#Posts:16
#04 Oct 2011 04:43 PM
#Good morning, 
#You would first need to send the output from the SQL statement to a text file and send the text file as an email attachment. 
#The PS script to send out an email is something like below : 
#$msg = new-object system.net.mail.MailMessage 
#$msg.From = "mailer-daemon@XXX.com" # this address can be anything 
#$msg.Subject = "Test Email sent from PowerShell version 2 " # this is the subject of the email 
#$msg.Body = "This is a test email sent from PowerShell " # this is the body of the email 
#$msg.To.add("et@XXX.com") # the next two lines are the intended recipients 
#$msg.To.add("e.oh@XXX.com") 
#$msg.Attachments.add("c:\XXX.dat") # this is the file containing the SQL results 
#$SmtpClient = new-object system.net.mail.smtpClient 
#$SmtpClient.host = "excserver@XXX.com" # this is the mail server which will relay the message 
#$SmtpClient.Send($msg) 
#Hope this helps.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#running powershell from SQL
#Last Post 29 Sep 2011 09:13 AM by Gene Hunter DBA extraordinaire. 4 Replies.
#AuthorMessages
#IT
#New Member
#
#Posts:55
#28 Jan 2009 05:14 AM
#I am trying to run a PowerShell script  from an SQL script.
#halr9000
#PowerShell MVP, Site Admin
#Advanced Member
#
#Posts:565
#28 Jan 2009 05:24 AM
#Can you run shell commands from T-SQL? I don't know it that well. I do know however that you can run PowerShell stuff from within the management studio for SQL 2008. Probably in Agent jobs as well, although I've not tried.
#Community Director, PowerShellCommunity.org
#Co-host, PowerScripting Podcast
#Author, TechProsaic
#IT
#New Member
#
#Posts:55
#28 Jan 2009 05:26 AM
#I know that you can run PowerShell from management studio, but I was seeing if anyone knew the script to do so.
#Chad Miller
#Basic Member
#
#Posts:198
#28 Jan 2009 01:23 PM
#Provided xp_cmdshell is enabled you can execute something like this. 
#xp_cmdshell 'powershell.exe -c get-service'
#Gene Hunter DBA extraordinaire
#New Member
#
#Posts:1
#29 Sep 2011 09:13 AM
#declare @svrName varchar(255) 
#declare @sql varchar(400) 
#--by default it will take the current server name, we can the set the server name as well 
#set @svrName = @@SERVERNAME 
#set @sql = 'powershell.exe -c "Get-WmiObject -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"' 
#--creating a temporary table 
#CREATE TABLE #output 
#(line varchar(255)) 
#--inserting disk name, total space and free space value in to temporary table 
#insert #output 
#EXEC xp_cmdshell @sql 
#--script to retrieve the values in GB from PS Script output 
#select @@SERVERNAME as servername ,rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drivename 
#,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1, 
#(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0) as 'capacityGB' 
#,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1, 
#(CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0)as 'freespaceGB', 
#round(100 * (round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1, 
#(CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0))/ 
#(round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1, 
#(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0)),0) as percentfree 
#from #output 
#--select * from #output 
#where line like '[A-Z][:]%' 
#order by drivename 
#--script to drop the temporary table 
#--drop table #output
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Emailing powershell error in SQL job
#Last Post 21 Sep 2011 05:41 AM by Chad Miller. 1 Replies.
#AuthorMessages
#suneg
#New Member
#
#Posts:6
#21 Sep 2011 02:39 AM
#Hello all,
#I have a script to email the last error in powershell to whoever.
#An email is sent sucessfully with the script below at the cmd and within the sql job, however the error does not appear in the body when executed through the sql job.
#Any ideas?
#S
#script:
#$emailFrom
#= "from@domain.com"
#$emailTo
#= "to@domain.com"
#$subject
#= "Powershell Job Failed"
#$body
#=$ERROR[0]
#[System.Net.Mail.SmtpClient]
#$client= New-ObjectSystem.Net.Mail.SmtpClient("smtp.smtp.com")
#$client
#.Send($emailFrom,$emailTo,$subject,$body)
#Chad Miller
#Basic Member
#
#Posts:198
#21 Sep 2011 05:41 AM
#It could be the issue is due to $ERROR[0] being of type System.Management.Automation.ErrorRecord 
#See 
#$ERROR[0] | get-member 
#Try calling its To String method or using the out-string cmdlet: 
#$body = ($error[0]).ToString() 
#OR 
#$body = $error[0] | out-string 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#insert ADS users into SQL table with QADGroupMember
#Last Post 20 Sep 2011 01:47 PM by CyberMonkey. 2 Replies.
#AuthorMessages
#CyberMonkey
#New Member
#
#Posts:2
#20 Sep 2011 08:29 AM
#Hey,
#im totally new to Powershell and i don't know how to solve following problem. It would be great if you could help me.
#I'm trying to insert users from a specific group to sql.
#For this i'm using Quest Active Directory Management Solutions and SQL Extensions for Powershell.
#With Quest i can filter the NTAccountName:
#Get-QADGroupMember | select NTAccountName
#With SQLPSX i can insert values in tables:
#Set-SqlData '' "INSERT dbo.users (username) VALUES($user)"
#If i set $user to any value like $user = 'username' it works.
#Is it possible to insert a bunch of users into this sql table?
#For example:
#$user = Get-QADGroupMember DomainUsers | select NTAccountName
#$user
# 
#NTAccountName
#--------------------
#User1
#User2
#User3
#Is it possible to insert all 3 users into the table so that every user has an own column without exporting them in csv before?
#I hope you can help, tank you.
#regards,
#CyberMonkey
#Chad Miller
#Basic Member
#
#Posts:198
#20 Sep 2011 11:42 AM
#You should be able to pipe the output of Get-QADGroupMember to Foreach-Object as follows: 
#Get-QADGroupMember DomainUsers | foreach-object {Set-SqlData "INSERT dbo.users (username) VALUES ('$($_.NTAccountName)')"}
#CyberMonkey
#New Member
#
#Posts:2
#20 Sep 2011 01:47 PM
#Thank You
#it worked great.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#syntax error in SQL Job
#Last Post 13 Sep 2011 04:14 AM by Chad Miller. 2 Replies.
#AuthorMessages
#suneg
#New Member
#
#Posts:6
#13 Sep 2011 12:47 AM
#Hi all,
#I'm a DBA and am new to powershell, i am trying to implement a script i found online to list all the sql servers in a domain and output to a .sql file. Thie code below works fine the the cmd line on the server but when run from a SQL job returns "Unable to start execution of step 1 (reason: line(3): Syntax error). The step failed."
#$SQL = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources() | ` foreach { "INSERT INTO dbo.FoundSQLServers VALUES ('$($_.ServerName)', '$($_.InstanceName)', '$($_.IsClustered)', '$($_.Version)')" ` >> C:\FTPimports\INSERTFoundSQLServers.sql } 
#I have other powershell job steps in other jobs that run fine.
#Can anyone help with this?
#S
#suneg
#New Member
#
#Posts:6
#13 Sep 2011 02:38 AM
#More info...
#The problem appears to be $($_.ServerName)
#The SQL job will not parse this. This is hinted at in Issue #6 here 
#http://blog.ashdar-partners.com/201...8-job.html
#the fix in that post is to remove the first $ and the parenthesis. This however, will not bring the data back. only the column name.
#Anyone?
#Chad Miller
#Basic Member
#
#Posts:198
#13 Sep 2011 04:14 AM
#One way to fix this woudl be to turn your command into a script and call the script from the SQL Agent job. You simply copy your command into ps1 file and call it in with c:\myscript.ps1
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SMO object returns values different from SQL drive
#Last Post 08 Sep 2011 03:23 AM by Klaas. 5 Replies.
#AuthorMessages
#Klaas
#New Member
#
#Posts:31
#06 Sep 2011 12:39 AM
#In search for the best way to check sql back ups, I tried SQL drive and SMO management objects. To my surprise I got different answers from both methods:
#PS C:\scripts> ls SQLSERVER:\SQL\servername\default\databases | where {$_.name -eq "databasename"} | select lastbackupdate
#LastBackupDate
#--------------
#4/09/2011 21:06:39
#PS C:\scripts> $srv = New-Object "microsoft.sqlserver.management.smo.server" servername
#PS C:\scripts> ($srv.databases | where {$_.name -eq "databasename"}).lastbackupdate
#maandag 5 september 2011 21:06:34
#I also checked the .bak files, the Agent Job History, the \\servername\d$\databases\MSSQL10_50.MSSQLSERVER\MSSQL\Log\DatabaseBackup_0x......txt log, and a SELECT from the msdb.dbo.backupset table. All of those report sep 5 as lastbackupdate.
#My server is SQL Server 2008R2 Standard Edition on WINDOWS Server 2008R2 Standard.
#I use Ola Hallengren's solution to take back ups, and for the 16 other db's on this server the property is equal to the SMO method.
#Why is the SQL drive lastbackupdate property different for this one database?
#Klaas
#New Member
#
#Posts:31
#06 Sep 2011 02:43 AM
#Update: 
#3 hours later all databases on the same server now give the last but one date instead of the lastbackupdate. This morning they returned the right date over and over again, and suddenly they're all wrong.
#Chad Miller
#Basic Member
#
#Posts:198
#07 Sep 2011 11:36 AM
#One thing to keep in mind is that you may be looking at cached objects in the provider or SMO object. Did you run both at the same time, starting a fresh sqlps console?
#Klaas
#New Member
#
#Posts:31
#07 Sep 2011 09:25 PM
#Hi Chad 
#that mmay have been the problem: I leave my consoles open for a week, or until ping doesn't work anymore. I never use sqlps. 
#Actually I have a script that collects this information from all SQLservers and inserts it in a database. So I presumed I should have 'new' information every day. 
#The strangest thing about this problem is that I got sep 5 as lastbackupdate from SQL provider for about 10 runs, and the 11th time it changed to sep 4. How is that possible? 
#I'm very confused now; get-childitem caches objects? Is this only for the SQLServer: drive? And I have to restart my console to refresh? 
#I've changed the script so that it uses SMO for all queries now. Seems more reliable.
#Chad Miller
#Basic Member
#
#Posts:198
#08 Sep 2011 03:06 AM
#sqlps provider behaves just like SQL Server Management Studio. For instance you've probably seen where you create a new table via T-SQL, but then to see the new table you have to refresh the tables folder in Object Explorer. Well, same concept for the drive. Here's a quick test I ran which illustrates the problem. The reason you aren't seeing the issue with straight SMO is that you are creating a refresh database object each time. 
#PS C:\> ls SQLSERVER:\SQL\WIN7BOOT\SQL1\databases | where {$_.name -eq "pubs"} | select lastbackupdate
#LastBackupDate
#--------------
#1/1/0001 12:00:00 AM
##Create a backup of pubs and see date hasn't changed
#PS C:\> ls SQLSERVER:\SQL\WIN7BOOT\SQL1\databases | where {$_.name -eq "pubs"} | select lastbackupdate
#LastBackupDate
#--------------
#1/1/0001 12:00:00 AM
##Call the refresh method and backup date is correct
#PS C:\> ls SQLSERVER:\SQL\WIN7BOOT\SQL1\databases | where {$_.name -eq "pubs"} | foreach {$_.Refresh()}
#PS C:\> ls SQLSERVER:\SQL\WIN7BOOT\SQL1\databases | where {$_.name -eq "pubs"} | select lastbackupdate
#LastBackupDate
#--------------
#9/8/2011 6:50:06 AM
#PS C:\>
#Klaas
#New Member
#
#Posts:31
#08 Sep 2011 03:23 AM
#That's a perfect explanation. Thank you for clarifying this.
#I think I like SMO more now.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#powershell and sql query times
#Last Post 31 Aug 2011 09:19 AM by Chad Miller. 3 Replies.
#AuthorMessages
#Daveyboy
#New Member
#
#Posts:55
#12 Aug 2011 09:30 AM
#Looking for a powershell command or .net assembly that deals with "query execution time". Essentially I want to connect to mssql (have this portion done) , run a query (have this portion done)  and record the query execution time as a value stored in a variable for the purpose of troubleshooting performance related issues. thoughts pls 
#Chad Miller
#Basic Member
#
#Posts:198
#12 Aug 2011 10:52 AM
#Use the built-in measure-command cmdlet. 
#Here's an example code that calls the SQL Server 2008 cmdlet, invoke-sqlcmd: 
#measure-command {invoke-sqlcmd -ServerInstance "$env:computername\sql1" -Database master -query "select * from sysdatabases"}
#Days              : 0
#Hours             : 0
#Minutes           : 0
#Seconds           : 0
#Milliseconds      : 39
#Ticks             : 398001
#TotalDays         : 4.60649305555556E-07
#TotalHours        : 1.10555833333333E-05
#TotalMinutes      : 0.000663335
#TotalSeconds      : 0.0398001
#TotalMilliseconds : 39.8001 
#Daveyboy
#New Member
#
#Posts:55
#12 Aug 2011 10:55 AM
#I saw that command, but thought perhaps this could be misleading as the measure-command is the time for powershell command execution , not sql. I suppose it would still be accurate, minus the extra little bit of overhead. Any other thoughts?
#Chad Miller
#Basic Member
#
#Posts:198
#31 Aug 2011 09:19 AM
#You could use the SET STATISTICS TIME ON just as you would with SQL Server Management Studio. I'm not sure which version of Invoke-SqlCmd2 you're using but the more recent versions http://poshcode.org/2279 have support for ADO.NET events when called with the -Verbose parameter. Here's simple example: 
#invoke-sqlcmd2 -ServerInstance $ServerInstance -Database master -Query "SET STATISTICS TIME ON; select 1 where 1 = 1" -Verbose
# Column1
#-------
#1
#VERBOSE: 
# SQL Server Execution Times:
#   CPU time = 0 ms,  elapsed time = 0 ms.
# 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Automate SQL 2008 R2 upgrade from SQL 2008
#Last Post 23 Aug 2011 02:09 PM by Chad Miller. 3 Replies.
#AuthorMessages
#raghavendra
#New Member
#
#Posts:8
#22 Aug 2011 01:37 AM
#Hi,
#I need to automate my SQL Server upgradation from SQL 2008 to SQL 2008 R2 using Powershell. Anybody have tried this before. Please share with me any idea on how we can start with this. I have the Setup files ready with me. 
#Apprecaite any idea to automate every step of installation using PS.
#Thanks.
#Chad Miller
#Basic Member
#
#Posts:198
#22 Aug 2011 07:35 AM
#The automation I've seen or done around SQL Server installations has largely revolved around using the built-in unattended install feature of the SQL Server setup.exe. You can either use the various command line switches or a better solution is to use an ini file with then various installation/ugprade options. Although you can manually create an ini file, by default with SQL Server 2008 and higher a configuration ini file is automatically created when you run an install. You could use the ini file generated from a manual install to automate your remaining installs. 
#If you want to use Powershell then you'll need to provide values for the configuration file location as well as the service accounts used for each of the SQL Server services: 
#    $command = 'setup.exe /CONFIGURATIONFILE=`"$configFile`" /SAPWD=`"$sysadminPassword`" /SQLSVCPASSWORD=`"$servicePassword`" /AGTSVCPASSWORD=`"$servicePassword`" /FTSVCPASSWORD=`"$servicePassword`" /ISSVCPASSWORD=`"$servicePassword`"'
#invoke-expression $command
# 
#raghavendra
#New Member
#
#Posts:8
#23 Aug 2011 04:48 AM
#Thanks Chad. I got it. But I am looking little bit more customized script which can handle errors & restarts. I mean suppose if installation asked for a system restart in between I want the script to restart the machine and re run the script. Can we track the SQL errors through powershell by storing SQL outputs and act accordingly?
#Chad Miller
#Basic Member
#
#Posts:198
#23 Aug 2011 02:09 PM
#You're really restricted by the functionality provided by the installer. I will say you can get very sophisticated with a Powershell-based SQL Server installer to script everything from pre-install checks (pending reboot is tricky), SQL Server installation and post installation configuration. A co-worker of mine created a CodePlex project, call sqlspade that does just this. We've used it internally for the past 9 months. 
#Check out this presentation: 
#http://powershell.sqlpass.org/Prese...chive.aspx 
#CodePlex project 
#http://sqlspade.codeplex.com/
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#get-ChildItem problem with UNC path invoked by a SQL Server job
#Last Post 17 Jul 2011 05:43 PM by AlexN. 1 Replies.
#AuthorMessages
#AlexN
#New Member
#
#Posts:2
#16 Jul 2011 12:47 PM
#Script:
#Param( [parameter(Mandatory = $true)][string]$backupDir="" ) 
#$scriptName = "sql-db-test.ps1" 
#$timeStamp = get-date -format yyyyMMddHHmm 
#$logDir = "D:\DBA\Logs\" 
#$logFile = $logDir + $scriptbasename + "-" + $timeStamp + ".log" 
#$files = get-ChildItem $backupDir | where {$_.extension -eq ".bak"} 
#$files >> $logfile 
#Powershell command line: Works regardless the content of the parameter. Backupdir=D:\TEMP\  or Backupdir=\\sql-backup-02\sql-backup\
#MSSQL Job (Powershell type of job): Works with D:\TEMP\ but doesnot work with UNC \\sql-backup-02\sql-backup\ even when I tried to map the UNC path to a drive letter.
#Any idea as to why SQL Server is confused by the UNC path. Do I need to use any escape characters? 
#Thanks in advance.
#Alex
#AlexN
#New Member
#
#Posts:2
#17 Jul 2011 05:43 PM
#Resolved using new-PSDrive cmdlet: 
#New-psdrive -name BackupDrive -psprovider filesystem -root $backupDir 
#Set-Location BackupDrive: 
#$files = get-ChildItem BackupDrive: | where {$_.extension -eq ".bak"}
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQLDBA - Dailycheck list - Help required
#Last Post 16 Jul 2011 07:21 AM by Chad Miller. 1 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#16 Jul 2011 05:01 AM
#Hi friends,
#first of all, I would like to say thanks power shell community.com, 
#here i learned lot form my power shell community friends they reply and corrected my ERRORS for till last 1 1/2 years. thank you again.
#I have created one SQL SERVER 2008 stored procedure for daily check list monitoring and send to email by automatically. But SPs is working fine at SQL environment but all output is not attached in Email body. Please tell me, what could be reason.
#USE [master]
#GO
#SET ANSI_NULLS ON
#GO
#SET QUOTED_IDENTIFIER ON
#GO
#create PROC [dbo].[sp_SQLDBA_Daily_CheckList]
#AS
#SELECT '*** Start of Daily Activity Report ***'
#--SELECT '-- Shows SQL Servers information'EXEC ('USE MASTER')
#SELECT  CONVERT(char(20), SERVERPROPERTY('MachineName')) AS 'MACHINE NAME',  CONVERT(char(20), SERVERPROPERTY('ServerName')) AS 'SQL SERVER NAME', (CASE WHEN CONVERT(char(20), SERVERPROPERTY('InstanceName')) IS NULL THEN 'Default Instance' ELSE CONVERT(char(20), SERVERPROPERTY('InstanceName')) END) AS 'INSTANCE NAME',
#CONVERT(char(20), SERVERPROPERTY('EDITION')) AS EDITION, CONVERT(char(20), SERVERPROPERTY('ProductVersion')) AS 'PRODUCT VERSION', CONVERT(char(20), SERVERPROPERTY('ProductLevel')) AS 'PRODUCT LEVL',
#(CASE WHEN CONVERT(char(20), SERVERPROPERTY('ISClustered')) = 1 THEN 'Clustered' WHEN CONVERT(char(20), SERVERPROPERTY('ISClustered')) = 0 THEN 'NOT Clustered' ELSE 'INVALID INPUT/ERROR' END) AS 'FAILOVER CLUSTERED',
#(CASE WHEN CONVERT(char(20), SERVERPROPERTY('ISIntegratedSecurityOnly')) = 1 THEN 'Integrated Security ' WHEN CONVERT(char(20), SERVERPROPERTY('ISIntegratedSecurityOnly')) = 0 THEN 'SQL Server Security ' ELSE 'INVALID INPUT/ERROR' END) AS 'SECURITY',
#(CASE WHEN CONVERT(char(20), SERVERPROPERTY('ISSingleUser')) = 1 THEN 'Single User' WHEN CONVERT(char(20), SERVERPROPERTY('ISSingleUser')) = 0 THEN 'Multi User' ELSE 'INVALID INPUT/ERROR' END) AS 'USER MODE',
#CONVERT(char(30), SERVERPROPERTY('COLLATION')) AS COLLATION
# 
#--SELECT '-- Shows top 5 high cpu used statemants'
#SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
#SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
# ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
#ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1) AS statement_text
#FROM sys.dm_exec_query_stats AS qs
#CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
#ORDER BY total_worker_time/execution_count DESC;
#SELECT '-- Shows who so logged in'
#SELECT login_name ,COUNT(session_id) AS session_count FROM sys.dm_exec_sessions GROUP BY login_name;
#SELECT '-- Shows long running cursors'EXEC ('USE master')
#SELECT creation_time ,cursor_id  ,name ,c.session_id ,login_name FROM sys.dm_exec_cursors(0) AS c JOIN sys.dm_exec_sessions AS s  ON c.session_id = s.session_id WHERE DATEDIFF(mi, c.creation_time, GETDATE()) > 5;
#SELECT '-- Shows idle sessions that have open transactions'SELECT s.* FROM sys.dm_exec_sessions AS s
#WHERE EXISTS  ( SELECT *  FROM sys.dm_tran_session_transactions AS t WHERE t.session_id = s.session_id ) AND NOT EXISTS  ( SELECT *  FROM sys.dm_exec_requests AS r WHERE r.session_id = s.session_id );
#SELECT '-- Shows free space in tempdb database'
#SELECT SUM(unallocated_extent_page_count) AS [free pages],
#(SUM(unallocated_extent_page_count)*1.0/128)
# AS [free space in MB]FROM sys.dm_db_file_space_usage;
# 
#SELECT '-- Shows total disk allocated to tempdb database'SELECT SUM(size)*1.0/128 AS [size in MB]FROM tempdb.sys.database_files
#SELECT '-- Show active jobs'SELECT DB_NAME(database_id) AS [Database], COUNT(*) AS [Active Async Jobs]FROM sys.dm_exec_background_job_queue
#WHERE in_progress = 1GROUP BY database_id;
#SELECT '--Shows clients connected'
#SELECT session_id, client_net_address, client_tcp_port
#FROM sys.dm_exec_connections;
#SELECT '--Shows running batch'SELECT * FROM sys.dm_exec_requests;
#SELECT '--Shows currently blocked requests'SELECT session_id ,status ,blocking_session_id ,wait_type ,wait_time ,wait_resource  ,transaction_id FROM sys.dm_exec_requests WHERE status = N'suspended'
#SELECT '--Shows last backup dates ' as ' 'SELECT B.name as Database_Name,  ISNULL(STR(ABS(DATEDIFF(day, GetDate(),  MAX(Backup_finish_date)))), 'NEVER')  as DaysSinceLastBackup, ISNULL(Convert(char(10),  MAX(backup_finish_date), 101), 'NEVER')  as LastBackupDate FROM master.dbo.sysdatabases B LEFT OUTER JOIN msdb.dbo.backupset A  ON A.database_name = B.name AND A.type = 'D' GROUP BY B.Name ORDER BY B.name
#SELECT '--Shows jobs that are still executing' as ' ' exec msdb.dbo.sp_get_composite_job_info NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL
#SELECT '--Shows failed MS SQL jobs report' as ' ' SELECT name FROM msdb.dbo.sysjobs A, msdb.dbo.sysjobservers B WHERE A.job_id = B.job_id AND B.last_run_outcome = 0
#SELECT '--Shows disabled jobs ' as ' ' SELECT name FROM msdb.dbo.sysjobs WHERE enabled = 0 ORDER BY name
#SELECT '--Shows avail free DB space ' as ' ' exec sp_MSForEachDB 'Use ? SELECT name AS ''Name of File'', size/128.0 -CAST(FILEPROPERTY(name, ''SpaceUsed'' ) AS int)/128.0 AS ''Available Space In MB'' FROM .SYSFILES'
#SELECT '--Shows total DB size (.MDF+.LDF)' as ' '  set nocount on declare @name sysname declare @SQL nvarchar(600) -- Use temporary table to sum up database size w/o using group by  create table #databases ( DATABASE_NAME sysname NOT NULL, size int NOT NULL) declare c1 cursor for  select name from master.dbo.sysdatabases -- where has_dbaccess(name) = 1 -- Only look at databases to which we have access open c1 fetch c1 into @name
#while @@fetch_status >= 0
#begin
# select @SQL = 'insert into #databases select N'''+ @name + ''', sum(size) from ' +
#QuoteName(@name) + '.dbo.sysfiles' -- Insert row for each database 
#execute (@SQL) fetch c1 into @name end deallocate c1
#select DATABASE_NAME, DATABASE_SIZE_MB = size*8/1000
# -- Convert from 8192 byte pages to K and then convert to MB
# from #databases order by 1 select SUM(size*8/1000)
#as '--Shows disk space used - ALL DBs - MB '
#from #databases
#drop table #databases
#SELECT '--Show hard drive space available '
#EXEC master..xp_fixeddrives
#PRINT '*** End of Report **** '
#Powers hell script - as below - as per this script, I received mail but data is not attached in email body.
# foreach ($Reslut in $body)
#{
#  $con = "server=IPaddress;database=Master;User Id=sa;Password=xxxx" 
#   $cmd="exec dbo.sp_SQLDBA_Daily_CheckList"
#  $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)
#  $dt1 = new-object System.Data.Datatable
#  $da.fill($dt1)
#  $svr
#  $Reslut1 = $dt1 | out-string
#}
#foreach ($item in $body)
#{ 
#$txt=@"
#This is an informational message from SQLSERVER 2008 Test Server, daily check list details.
#"@
#$smtp = new-object Net.Mail.SmtpClient("IPaddress") 
#$subject="TestServer-Server-Daily-CheckList-Report"  
#$from="SJMNB001@RIL.COM" 
#               $to = "ananda.murugesan@ril.com"
#               $cc = get-content "D:\Monitor\Email_List.txt"
#               $msg = New-Object system.net.mail.mailmessage
#               $msg.From = $from
#               $msg.to.add($to)
#               $msg.cc.add($cc)
#               $msg.Subject = $subject
#               $bodyText = ("$Reslut1","$txt")
#               $msg.Body = $bodyText
#               $smtp.Send($msg)
#} 
#Thanks
#ananda
#Chad Miller
#Basic Member
#
#Posts:198
#16 Jul 2011 07:21 AM
#In Powershell V2 there's a built in cmdlet for sending mail messages called send-mailmessage. I would suggest, if you can switch to this cmdlet. See help send-mailmessage -full for detailed help.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Copy of SSIS Packages
#Last Post 08 Jul 2011 12:08 PM by Werner. 1 Replies.
#AuthorMessages
#Werner
#New Member
#
#Posts:2
#08 Jul 2011 08:04 AM
#Hi, I'm new to Powershell and I'm trying to copy all my SSIS packages stored in my MSDB folder from one server to a new server.  I've located the following code but when I execute it I get the following error.  BTW - the "get-isitem" works fine.
#import-module SSIS 
##get-isitem  '\' 'PRODETL' 'PRODETL' -recurse 
#copy-isitemsqltosql -path '\' -toplevelFolder 'MSDB' -servername 'prodetl' -destination 'MSDB' -destinationserver 'etldevvh1' -recurse
#ERROR
#Package \ does not exist on server prodetl 
#At C:\Users\Wernhow\Documents\WindowsPowerShell\Modules\SSIS\SSIS.psm1:172 char:12 
#+ { throw <<<< "Package $path does not exist on server $serverName"} 
#+ CategoryInfo : OperationStopped: (Package \ does ... server prodetl:String) [], RuntimeException 
#+ FullyQualifiedErrorId : Package \ does not exist on server prodetl 
#Any help will be appreciated.
#Werner
#New Member
#
#Posts:2
#08 Jul 2011 12:08 PM
#The issue turned out to be the assembly. I was trying to pull from a 2005 server and install the packages into a 2008 R2 server. Made it a two step process, copying to a disk file then from the disk file to the 2008 server.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#get output from mysqldump
#Last Post 06 Jul 2011 12:27 AM by pitic. 1 Replies.
#AuthorMessages
#pitic
#New Member
#
#Posts:2
#05 Jul 2011 05:05 AM
#Hy,
#I'm writing a script that does a mysldump from one server to another, like this:
#- connects to a mysql server and retrieves a list of ip addresses
#- checks which address is online
#- if it's online tries the mysqldump:
#$StartInfo = new-object System.Diagnostics.ProcessStartInfo $StartInfo.UserName = $user $StartInfo.Password = $pass $StartInfo.LoadUserProfile = $true $StartInfo.UseShellExecute = $false $StartInfo.FileName = "mysqldump" $StartInfo.RedirectStandardOutput = $true; $StartInfo.RedirectStandardError = $true; $StartInfo.CreateNoWindow = $true $StartInfo.ErrorDialog = $true $StartInfo.WorkingDirectory = $env:temp
#$StartInfo.Arguments = " --add-drop-table -c --create-options -u root -h $sourceHost $sourceDatabase $sourceTable | mysql -u root -h $farmacie farmacie" $proc = [System.Diagnostics.Process]::Start($StartInfo).WaitForExit() 
#the problem is i have to run mysqldump as admin  because i use windows 7 (powershell is run as normal user). if i do a mysqldump as a normal user i get error: mysqldump: got errno 9 on write.
#I have passed the credentials for admin privileges to the process, but, because of that, it creates another shell in which it runs the mysqldump command. What i'm trying is to get the output (standard and error) of that shell and pass it to the shell in which i run the script.
#I have tried adding 2>&1 | out-file $file at the end of the $StartInfo.Arguments and read the contents of the file afterwards but it does not write anything into it. 
#I've also tried with | tee-object but no result.
#How can i get that output to see if the dump succeeded or not?
#Thanks.
#pitic
#New Member
#
#Posts:2
#06 Jul 2011 12:27 AM
#bump
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Can update sql tables
#Last Post 30 Jun 2011 02:08 PM by trebboR. 2 Replies.
#AuthorMessages
#trebboR
#New Member
#
#Posts:8
#29 Jun 2011 02:03 PM
#Hello PowershellCommunity,
#I have a script but i run into a little problem with the update command.
#I don,t wanna use invoke-sqlcmd
#The script read's the sql table i check if this server with ipadres xxx is online and wanna update the sql server table, that al.
#In this script I wanna update the hashtable and after that update they sql table, there is where i go wrong
#Here is they error and the script:
#==============Start output and error============
#Id 1 
#ONOFF ON 
#Name Server01 
#IPAdres 127.0.0.1 
#Status Online 
#Count 
#1 
#ON 
#Server01 
#$Status = "Offline" 
#Method invocation failed because [System.Data.SqlClient.SqlCommand] doesn't contain a method named 'Update'. 
#At C:\Script.ps1:93 char:18
#+ $Command.Update <<<< ($SQLUpdate) 
#+ CategoryInfo : InvalidOperation: (Update:String) [], RuntimeException 
#+ FullyQualifiedErrorId : MethodNotFound 
#127.0.0.1 
#Online 
#Id 2 
#ONOFF ON 
#Name Server02 
#IPAdres 10.10.10.10 
#Status Online 
#Count 
#2 
#ON 
#Server02 
#$Status = "Offline" 
#Method invocation failed because [System.Data.SqlClient.SqlCommand] doesn't contain a method named 'Update'. 
#At C:\Script.ps1:93 char:18 
#+ $Command.Update <<<< ($SQLUpdate) 
#+ CategoryInfo : InvalidOperation: (Update:String) [], RuntimeException 
#+ FullyQualifiedErrorId : MethodNotFound 
#10.10.10.10 
#Online
#==============End output and error=============
#============start script===========
#$Connection ="server=Server1;database=DB1;trusted_connection=true;"
#$SQLObject = ""
#$Query = "SELECT * from PCTable"
# # Prepare the ConnectionString
# $ConnString = $ConnString.TrimStart('"')
# $ConnString = $ConnString.TrimEnd('"')
# # Connect to The SQL Server
# $Connection = New-Object System.Data.SQLClient.SQLConnection
# $Connection.ConnectionString = $ConnString
# $Connection.Open()
# # Execute the Query
# $Command = New-Object System.Data.SQLClient.SQLCommand
# $Command.Connection = $Connection
# $Command.CommandText = $Query
# Write-Host ">>> " $Query 
# # Add Retrieved Data to a HashTable Array
# $Reader = $Command.ExecuteReader()
# $Counter = $Reader.FieldCount
# while ($Reader.Read()) {
#  $SQLObject = @{}
#  for ($i = 0; $i -lt $Counter; $i++) {
#   $SQLObject.Add(
#    $Reader.GetName($i),
#    $Reader.GetValue($i)
#    
#   );
#    Write-host $Reader.GetName($i) $Reader.GetValue($i);
#  }
#  # Return Information to Host
#  #$SQLObject
#  $SQLObject.Id
#  $SQLObject.ONOFF
#  $SQLObject.Name
#  if (test-connection -computername $SQLObject.IPAdres -Count 2 -Quiet) {$Status = "Online"}{$Status = "Offline"}
#  #{$SQLObject.Status = "Online" ; write-host $SQLObject.Name ": Online" }else {$SQLObject.Status = "Offline" ; write-host $SQLObject.Name ": Offline" }
#  $SQLUpdate | Where {$_.Id -eq "2"} | foreach {$_.Status = $Status}
#  $Command.Update($SQLUpdate) 
#  
#  $SQLObject.IpAdres
#  $SQLObject.Status
#  $SQLObject.Count
#  
# }
# $SQLObject
# 
# $Connection.Close()
#=================END SCRIPT============
#I hope someone can help me with this,
#Regards trebboR
#Chad Miller
#Basic Member
#
#Posts:198
#29 Jun 2011 05:59 PM
# 
##If you have table named PCTable with a primary key defined and a column for Status, this works:
##CREATE TABLE PCTable (
##    IPAdres varchar(50) NOT NULL,
##    Status varchar(10) NULL
##) 
##ALTER TABLE PCTable
##ADD CONSTRAINT PK_PCTable PRIMARY KEY CLUSTERED (IPAdres)
#       
#            
#$serverName = "$env:computername\sql1"            
#$databaseName = "dbutility"            
#$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter            
#$query = 'SELECT * from PCTable'            
#$connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"            
#$dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)            
#$commandBuilder = new-object System.Data.SqlClient.SqlCommandBuilder $dataAdapter            
#$dt = New-Object System.Data.DataTable            
#$null = $dataAdapter.fill($dt) 
#$dt  | foreach {$_.Status = if (test-connection -computername $($_.IPAdres ) -Count 2 -Quiet) {'Online'} else {'Offline'} }
#$null = $dataAdapter.Update($dt)    
#trebboR
#New Member
#
#Posts:8
#30 Jun 2011 02:08 PM
#Hello Chad Miller,
#the script is running fine. 
#Thanx for this,
#You helped me, very nice.
#-=[Respect-trebboR]=-
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Academic question: Why does returned object change type?
#Last Post 23 Jun 2011 12:32 AM by DizzyOne. 4 Replies.
#AuthorMessages
#Jonathon
#New Member
#
#Posts:4
#18 Mar 2011 08:08 AM
#Below is a function that returns a datatable queried from SQL server.  Inside the function, the line:
#write-host $dt.rows.count
#writes the number of rows returned from the query.  However, once the function has returned the datatable to the outside variable ($dt2), I can no longer get a result from .rows.count.  Can anyone tell me why?  I'm using PS 2.0.
#function Get-SqlTbl {
#Param ($server, $query, $database)
#$cn = new-object ('System.Data.SqlClient.SqlConnection')
#$cnString = "Server=$server;Integrated Security=SSPI;Database=$database"
#$cn.ConnectionString = $cnString
#$cn.Open() | out-null
#$cmd = new-Object System.Data.SqlClient.SqlCommand($query, $cn)
#$apr = New-Object System.Data.SqlClient.SqlDataAdapter
#$apr.SelectCommand = $cmd
#$dt = New-Object System.Data.DataTable
#$apr.Fill($dt) | Out-Null
#$cn.Close()
#write-host $dt.rows.count    #<-- this works!
#return $dt
#} 
#$dt2 = Get-SqlTbl "SQLSVR" "SELECT * FROM edicust" "db1"
#write-host $dt2.rows.count    #<-- this doesn't work
#Chad Miller
#Basic Member
#
#Posts:198
#20 Mar 2011 06:52 AMAccepted Answer 
#PowerShell automatically unravels collections. Most of the time this is helpful, but sometimes it isn't. Your returned object is an array of datarows. One way to "fix" this is to to return a Data table as follows: 
#[code 
#function Get-SqlTbl { 
#Param ($server, $query, $database, $As='DataTable') 
#$cn = new-object ('System.Data.SqlClient.SqlConnection') 
#$cnString = "Server=$server;Integrated Security=SSPI;Database=$database" 
#$cn.ConnectionString = $cnString 
#$cn.Open() | out-null 
#$cmd = new-Object System.Data.SqlClient.SqlCommand($query, $cn) 
#$apr = New-Object System.Data.SqlClient.SqlDataAdapter 
#$apr.SelectCommand = $cmd 
#$ds=New-Object system.Data.DataSet 
#[void]$apr.fill($ds) 
#$cn.Close() 
#switch ($As) 
#{ 
#'DataSet' { Write-Output ($ds) } 
#'DataTable' { Write-Output ($ds.Tables) } 
#'DataRow' { Write-Output ($ds.Tables[0]) } 
#} 
#} 
#$dt2 = Get-SqlTbl "$env:computername\R2" "SELECT * FROM syslogins" "master" 
#gm -in $dt2 
#$dt2 | gm 
#write-host $dt2.rows.count 
#[/code] 
#Also note unraveling occurs when you use get-member (gm). Notice the difference in object type from gm -input and $dt2 | gm
#Jonathon
#New Member
#
#Posts:4
#21 Mar 2011 01:42 PM
#Thanks, Chad.  I appreciate your help.
#It's hard for me to understand why Powershell would unravel an explicitly declared datatable into a collection of rows.  But I guess every language has its quirks.
#Best regards!
#0ptikGhost
#Basic Member
#
#Posts:369
#21 Mar 2011 02:10 PM
#PowerShell automatically unravels any object sent through the pipeline that is enumerable. This behavior allows cmdlet writers to write processing logic that can act on a single object at a time while allowing the builtin functionality to loop through collections automatically.
#When you write a function that outputs (returns) a single object that is enumerable you are effectively sending that single object through the pipeline into the calling code. PowerShell automatically unravels the enumerable object because it was sent through the output pipeline.
#For better or for worse, PowerShell also will give you different output depending on what is sent through the pipeline:
#If nothing is sent you get a $null. 
#If a single object is sent (after unravelling) you get that one single object. 
#If you send two or more objects (after unravelling) then you get an array containing the objects sent through the pipeline. 
#This inconsistency can be extremely annoying if you don't know the cardinality of the command output ahead of time.
#I use the @() operator when I want consistent output no matter how many objects are sent through the pipeline. Here's some sample usage:
#$rows = @(Get-SqlTbl "SQLSVR" "SELECT * FROM edicust" "db1")
#Now I know that the DataTable produced by Get-SqlTbl will get unravelled automatically by powershell. By using the @() operator I have guaranteed that I will always have an array in the $rows variable.
#If DataTable is empty then $rows.count -eq 0 
#If DataTable had one row then $rows.count -eq 1 
#If DataTable had two or more rows then $rows.coutn -ge 2 
#Now I can process those rows in a standard fashion.
#foreach ($row in $rows) {
#    # process each row independently
#}
#Blog - http://0ptikghost.blogspot.com 
#DizzyOne
#New Member
#
#Posts:1
#23 Jun 2011 12:32 AM
#There is an easy way to return the type you have created in your function: just put a comma in front of your return parameter. 
#So your code would have a minimal change: 
# return ,$dt
#This returns the DataTable to your calling code. 
#Hope this helps. 
#Regards, 
#Peter Elzinga
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#working with data table and variable
#Last Post 21 Jun 2011 07:59 AM by astreet. 7 Replies.
#AuthorMessages
#Nonsec
#New Member
#
#Posts:4
#28 Jul 2010 05:44 PM
#Hello everyone,
#I have a script (actually find on Poshcode) I want define if and else conditions and write output. I am having issue figure out manipulate returning data. Here is the script;
#function Get-OLEDBData { 
#param (
#[string]$server = "Server1",
#[string]$instance ="PPP"
# # [string]$port ="1527",
# # [int]$Threshold ="70" )
# $sql = "select * from dba_tablespace_usage_metrics"
# $connectstring = "password=mypass;UserID=myuser;DataSource=$instance;Provider=OraOLEDB.Oracle"
# $OLEDBConn = New-Object System.Data.OleDb.OleDbConnection($connectstring) \$OLEDBConn.open()
# $readcmd = New-Object system.Data.OleDb.OleDbCommand($sql,$OLEDBConn) $readcmd.CommandTimeout = '30'
#$da = New-Object system.Data.OleDb.OleDbDataAdapter($readcmd) 
#$dt = New-Object system.Data.datatable
# [void]$da.fill($dt)
# $OLEDBConn.close()
# return $dt } 
#this returns;
#TABLESPACE_NAME  USED_SPACE   TABLESPACE_SIZE USED_PERCENT
#---------------  ---------    --------------- ------------
#ASSRM            52543200     57647104        91.14629591800483160437686514
#PSTRMC    	 2268816      3200000         70.9005
#Now I want to manipulate this data and define if and else condition such as = if (  tablespace_name -eq etc. ) or elseif ( used_percent -gt "30") and etc. However I am running into problem.
# if($_.used_percent -gt "30") { 
#Write-host Table Space Name $Tablespacename is crossed the threshold current value is $Used_Percent and $Used_Space for the database $instance and on the server $Server
#} 
#the output i want to see for each table space for example;
#Table Space name ASSRM is crossed the threshold current value is 91.14 and used Space 52543200 for the database PPP and the server Server1
#I coud not figure to create variable for $tablespacename  $used_percent and $used_space then use for the output. 
#Any help greatly appreciated.
# Thank you.
#George Howarth
#Basic Member
#
#Posts:360
#29 Jul 2010 03:17 AM
#Try this:
#$server = "Server1"
#$instance = "PPP"
#$dataTable = Get-OLEDBData -Server $server -Instance $instance
#$dataTable.Rows | ForEach-Object {
#    if ($_["USED_PERCENT"] -gt 30)
#    {
#        Write-host 
#        ("Table Space Name {0} is crossed the threshold current value is {1} and {2} for the database {3} and on the server {4}" `
#        -f $_["TABLESPACE_NAME"], $_["USED_PERCENT"], $_["USED_SPACE"], $instance, $server)
#    }
#}
#Nonsec
#New Member
#
#Posts:4
#29 Jul 2010 09:17 PM
#GWHowarth88,
#Thank you very much for the response . It worked fine here is the result; 
#Table Space Name SYSTEM has crossed the threshold current value is 76.789999999 and used space is 53444 for the database PPP on the server Server1
#if you don`t mind replying  i have a couple of question for you too. 
#Thanks again. 
#George Howarth
#Basic Member
#
#Posts:360
#30 Jul 2010 01:48 AM
#Fire away.
#Nonsec
#New Member
#
#Posts:4
#01 Aug 2010 08:04 PM
#GWHowarth88, 
#Thank you very much.I appreciate your help.   Here are my questions;
#1- I want to put server names and database (instance) in a csv file. it will contain server name and database name. Script will go will read server name and instance name from csv file and and it will process for each data row. 
#2- My second question is I am using OLEDB components for the previous script. I am also trying to do samething with Oracle client components so far I could not manage the same output. I attached the script and output. Would you mind looking that script? 
#3- When i run the script (attached Oracle script) the below example the when i put comma after return it changes structe of the script returning data is different. What is funtion of the putting comma there? 
#$table = new-object system.data.datatable
#$table = $set.Tables[0] 
#return $table
#return, $table
#Thanks again. Please let me know if i can provide you more information on this.
#Oracleclient.txt
#George Howarth
#Basic Member
#
#Posts:360
#02 Aug 2010 02:13 AM
#1. I updated the script so that it accepts a path to a CSV file. The script assumes that the CSV file is in the format:
#Server, Instance
#someServer, someInstance
#2. I'm not exactly sure what you mean when you say "same output". If you mean that you don't want "11" being outputted, pipe $adapter.Fill() to Out-Null. I updated, the script with this assumption.
#3. I don't know what the effect is when you put a comma after the return keyword. All I know is that when you precede a variable with a comma, it wraps the variable into an array.
#param (
#    [String]$Path
#)
#function Get-OraTableSpace 
#{
#    param (
#        [String]$Server,
#        [String]$Instance,
#        [String]$Port = "1527"
#    )
#     
#    [System.Reflection.Assembly]::LoadWithPartialName("System.Data.OracleClient") | Out-Null
#    
#    $connection = New-Object System.Data.OracleClient.OracleConnection( `
#        "Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$server)(PORT=$port)) `
#        (CONNECT_DATA=(SERVICE_NAME=$instance)));User Id=myuser;Password=mypass;");
#     
#    $set = New-Object System.Data.DataSet    
#    $query = "select TABLESPACE_NAME , round ( USED_SPACE / (1024 * 1024),2) as USED_SPACE_MB , TABLESPACE_SIZE/1024 TABLESPACE_SIZE_MB , round(USED_PERCENT,2) USED_SPACE_PERCENTAGE from  dba_tablespace_usage_metrics"
#     
#    $adapter = New-Object System.Data.OracleClient.OracleDataAdapter ($query, $connection)
#    $adapter.Fill($set) | Out-Null
#     
#    return $set.Tables[0]
#}
#function Main
#{
#    Import-CSV -Path $Path | ForEach-Object { 
#        $server = $_.Server
#        $instance = $_.Instance
#    
#        (Get-OraTableSpace -Server $server -Instance $instance).Rows | ForEach-Object {
#            if ($_["USED_SPACE_PERCENTAGE"] -gt 30.00)
#            {
#                Write-host
#                ("Table Space Name {0} is crossed the threshold current value is {1} and {2} for the database {3} and on the server {4}" -f $_["TABLESPACE_NAME"], $_["USED_SPACE_PERCENTAGE"], $_["USED_SPACE_MB"], $instance, $server)
#            }
#        }
#    }
#}
#Main
#Nonsec
#New Member
#
#Posts:4
#03 Aug 2010 09:15 PM
#GWHowarth88, 
#Thank you very much for your help.
#astreet
#New Member
#
#Posts:1
#21 Jun 2011 07:59 AM
#New to powershell
#What would the command look like when passing in comma delimitted server list?
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL server agent failing to find file.
#Last Post 20 Jun 2011 05:26 AM by jshurak. 1 Replies.
#AuthorMessages
#jshurak
#New Member
#
#Posts:2
#20 Jun 2011 04:49 AM
#I've been executing a powershell script from SQL Server agent (sql 2008) for a while now using the Operating System (CmdExec) job step with the following expression.  
#powershell.exe C:\BackupAnalysis\RecentBackups.ps1 
#I'm migrating this to a SQL Server 2005 server,updating the file path and trying to do the same.  However, I'm getting a failed to find file error.  I've tried inputting the unc path to the file.  This works as a windows scheduled task but not through SQL job step.
#Has anyone encountered this?
#The SQL Server agent user is an admin on the server and has access to the file.
#jshurak
#New Member
#
#Posts:2
#20 Jun 2011 05:26 AM
#Fully qualifying the path to powershell did the trick 
#Found the resolution here 
#http://www.powershellcommunity.org/...aspx#18165
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#sqlps and Invoke-sqlcmd in a script
#Last Post 14 Jun 2011 02:17 AM by dmajor. 2 Replies.
#AuthorMessages
#dmajor
#New Member
#
#Posts:4
#13 Jun 2011 03:19 AM
#Hi All,
#I have a SQL script which I use to update information from one database to another (servers are linked)
#I want to execute the .sql script via powershell and when running the script line by line it works as expected however when executing the .ps1 it seems to stall after the execution of sqlps. I have also tried calling the individual lines by using functions and still not luck. Once the script stalls it leave teh shell in the PS SQLSERVER:\> prompt. I thne type exit and the rest of the script executed and I receive an error for the Invoke-SQLcmd cmdlet not being suitable for the current shell.
#The term 'Invoke-SQLcmd' is not recognized as the name of a cmdlet, function, script file, or operable program. Chec he spelling of the name, or if a path was included, verify that the path is correct and try again. At C:\Scripts\LoadVCDB.ps1:11 char:14 + Invoke-SQLcmd <<<< -Query "$q" + CategoryInfo : ObjectNotFound: (Invoke-SQLcmd:String) [], CommandNotFoundException + FullyQualifiedErrorId : CommandNotFoundException
#My powerscript is below:
#Function InitSQL {sqlps} 
#Function GetQuery {$q = Get-Content C:\Scripts\VeSD.sql}
#Function End {exit} 
#echo "Initiating..." 
#InitSQL echo "SQL Initiated" 
#echo "Gathering Scripts..." 
#GetQuery 
#echo "Scripts Gathered" 
#echo "Running Query..." 
#Invoke-SQLcmd -Query "$q"
#echo "Query Executed" 
#echo "exiting..." 
#End 
#echo "Exited"
#The .sql file is simply select @@version, I tried to simplify as many steps as possible.
#Thanks in advance for any assistance.
#Chad Miller
#Basic Member
#
#Posts:198
#13 Jun 2011 04:29 PM
#The problem you're seeing is one of scop, Calling sqlps.exe within a function means it is only "visible" within the the function. Also it appears you just want to have invoke-sqlcmd cmdlet available within regular PowerShell, so you could do one of the following: 
#Use the Init-SqlEnv.ps1 script feature here: 
#http://blogs.msdn.com/b/mwories/arc...shell.aspx 
#Or use a sqlps module: 
#http://sev17.com/2010/07/making-a-sqlps-module/ 
#Here's an example using the module approach (assuming you've downloaded and placed the module in WindowsPowerShell\Modules directory): 
#import-module sqlps 
#invoke-sqlcmd -ServerInstance "myserver" -Database master -InputFile C:\scripts\VEsd.sql 
#Notice invoke-sqlcmd has an -inputfile parameter--no need to use q = Get-Content C:\Scripts\VeSD.sql
#dmajor
#New Member
#
#Posts:4
#14 Jun 2011 02:17 AM
#Great - Thanks
#I didnt know you could import modules, it seems a much cleaner way than switching shells.
#That is working perfectly now and got script size down as well.
#Thanks again for your assistance.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Automate Backup Monitoring - Urgent (Please Help)
#Last Post 13 Jun 2011 03:33 AM by Chad Miller. 3 Replies.
#AuthorMessages
#systemsadmin
#New Member
#
#Posts:2
#01 Jun 2011 08:44 PM
#Hi guys,
#I need some urgent help. I'm a systems administrator and I have no clue when it comes to Power shell. However, I was assigned a task to "automate backup monitoring" and "receive an e-mail notification" should a backup fail. The current backup process involves SQL compress that compresses SQL databases and backs them up using a power shell script written to perform the backup and using windows task scheduler to schedule the task. In order to monitor the backups, I would need to go into the backup logs to see if it completes successfully. However, I need to automate this backup monitoring by editing the current power shell scrip in order to monitor backups when they are scheduled and see if any of the backup fails and if it does, then send out an e-mail notification to recipients. I also need it to create a report as in a spreadsheet which says backup completed successfully and how long it took.The script is as follows:
#function backupAndCompress {
#Param($databasesToBackup=@(), $backupType="full")
#foreach ($db in $databasesToBackup) {
#$rootPath = "D:\Backups\$db"
#$dayOfWeek = $(Get-Date).DayOfWeek
#$filePartPaths =  1..4 | foreach { "path=$rootPath\$db.$dayOfWeek.$backupType.$_.bak.zip;" }
#$command = "D:\SQLCompress\MSSQLCompressedBackup-1.2-20100527_x64\msbp.exe backup "
#$dbParam = "`"db(database=$db;instancename=wsdb1;clusternetworkname=wsdb1;backuptype=$backupType;)`""
#$zipParam = "`"zip64(level=1)`""
#$destParam = "`"local(" + [string]::join('', $filePartPaths) + ")`""
#$totalCommand = "$command $dbParam $zipParam $destParam"
#Write-Host "Creating $backupType backup for $db"
#$dt = $(Get-Date).ToString("yyyyMMdd")
#Invoke-Expression $totalCommand >> "D:\SQLCompress\Logs\$dt-log.txt"
#}
#}
#function backupForDay {
#Param($fullBackupDay, $databasesToBackup=@())
#$backupType = "differential"
#if ($(Get-Date).DayOfWeek -eq $fullBackupDay) {
#$backupType = "full"
#}
#backupAndCompress $databasesToBackup $backupType
#}
#$mondayFull = @("2430", "ws2418", "ws2420", "ws2426", "ws2430", "ws2431", "ws2435", "ws2439", "ws2441", "ws2447")
#$wednesdayFull = @("ws2404", "ws2408", "ws2412")
#$fridayFull = @("2440")
#backupForDay "Monday" $mondayFull
#backupForDay "Wednesday" $wednesdayFull
#backupForDay "Friday" $fridayFull
#-------------------------------
#Can someone PLEASE help me because I did some research and I don't know what to do. I'm more of a Network/Servers/Hardware guy (as in exchange, windows server, sharepoint etc)? I don't know what to write and where to begin in order for powershell to do the above tasks i.e. automate backup monitoring, create a spreadsheet and send out an e-mail notification should it fail.
#I would really appreciate this.
#Thanks a lot in advance !
#P.S: I need to get this done as soon as possible.
#Chad Miller
#Basic Member
#
#Posts:198
#02 Jun 2011 03:17 AM
#For successful backups and times I would suggest querying the backupset table in msdb. This table contains an entry for each successful backup regardless of what utility is used to create the database backup. I wrote an article detailing an approach using PowerShell 
#http://www.sqlservercentral.com/art...ore/66564/ 
#As for failed backups, there's two approaches you could take. In the article I mention there are really three outcomes to a database backup--succeed, fail and nothing. Nothing is what happens when you fail to configure a database for backup. I've been burned by nothing happening more often than failures. The interesting thing is that I check to ensure a backup has occurred within 1-day and this covers both failed and nothing states. 
#That said if you want to check for failure. All failed backups write a message to the SQL Error Log and Windows Application Event Log. Check for messages there. There's a ScriptingGuy post which details how to check the SQL ErrorLog: 
#http://blogs.technet.com/b/heyscrip...rrors.aspx 
#systemsadmin
#New Member
#
#Posts:2
#08 Jun 2011 12:23 PM
#Thanks a lot for your reply.
#I have been able to figure out how to send an e-mail through power shell and check for failure in logs. The script is as follows:
#E-mail
#--------
#$emailFrom = "xxx@xxx.com"
#$emailTo = "xxx@xxxx.com"
#$subject =  "Backup Report"
#$body = "This is to notify you that the backups ran successfully."
#$smtpServer = "xxxx"
#$smtp = new-object Net.Mail.SmtpClient($smtpServer)
#$smtp.Send($emailFrom, $emailTo, $subject, $body)
#Check for failure
#---------------------
#get-childitem D:\SQLCompress\Logs\temp.txt | select-string -pattern "The backup failed" -casesensitive > D:\failedbackup.txt
#What this does is check for the message that says "The backup failed" in logs and then outputs it to a file which includes the failure. However, I need it to check for failure and then send out an e-mail when the failure happens with the backup number as well as the error message from the log files.
#______________________________________________
#The script for backing up the databases is as follows:
#function backupAndCompress {
#Param($databasesToBackup=@(), $backupType="full")
#foreach ($db in $databasesToBackup) {
#$rootPath = "D:\Backups\$db"
#$dayOfWeek = $(Get-Date).DayOfWeek
#$filePartPaths =  1..4 | foreach { "path=$rootPath\$db.$dayOfWeek.$backupType.$_.bak.zip;" }
#$command = "D:\SQLCompress\MSSQLCompressedBackup-1.2-20100527_x64\msbp.exe backup "
#$dbParam = "`"db(database=$db;instancename=wsdb1;clusternetworkname=wsdb1;backuptype=$backupType;)`""
#$zipParam = "`"zip64(level=1)`""
#$destParam = "`"local(" + [string]::join('', $filePartPaths) + ")`""
#$totalCommand = "$command $dbParam $zipParam $destParam"
#Write-Host "Creating $backupType backup for $db"
#$dt = $(Get-Date).ToString("yyyyMMdd")
#del temp.txt
#Invoke-Expression $totalCommand >> temp.txt
#echo temp.txt >> "D:\SQLCompress\Logs\$dt-log.txt"
#get-childitem D:\SQLCompress\Logs\temp.txt | select-string -pattern "The backup failed" -casesensitive > D:\failedbackup.txt
#$emailFrom = "xxx@xxx.com"
#$emailTo = "xxx@xxxx.com"
#$subject =  "Backup Report"
#$body = "This is to notify you that the backups ran successfully."
#$smtpServer = "xxxx"
#$smtp = new-object Net.Mail.SmtpClient($smtpServer)
#$smtp.Send($emailFrom, $emailTo, $subject, $body)
#-----------------------------------------------------------
#if temp.txt does contains failure message...
#send email...
#-------------------------------------------------
#del temp.txt
#}
#}
#function backupForDay {
#Param($fullBackupDay, $databasesToBackup=@())
#$backupType = "differential"
#if ($(Get-Date).DayOfWeek -eq $fullBackupDay) {
#$backupType = "full"
#}
#backupAndCompress $databasesToBackup $backupType
#}
#$mondayFull = @("2430", "ws2418", "ws2420", "ws2426", "ws2430", "ws2431", "ws2435", "ws2439", "ws2441", "ws2447")
#$wednesdayFull = @("ws2404", "ws2408", "ws2412")
#$fridayFull = @("2440")
#backupForDay "Monday" $mondayFull
#backupForDay "Wednesday" $wednesdayFull
#backupForDay "Friday" $fridayFull
#_________________________________
#In the bold is what I have finalized to be put in the script. In italics is what I need to change. However, I need to write a function that will send an email based on failure which includes error code as well as the backup number everyday. I plan to execute this through a batch file that I will schedule using the Windows Scheduler. 
#Can someone please guide me in the right direction?
#Thanks ! I'd really appreciate it.
#Chad Miller
#Basic Member
#
#Posts:198
#13 Jun 2011 03:33 AM
#Where do you get the error code and backup number from? Is it also written to your to the temp.txt log file from which you are searching for failed backups?
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Elimination of Columnn Name from results
#Last Post 09 Jun 2011 08:31 PM by rerichards. 2 Replies.
#AuthorMessages
#rerichards
#New Member
#
#Posts:10
#09 Jun 2011 01:44 PM
#I have the following script that queries a table that holds the names of our servers:
#$SQLServer = "MyMainServer" #use Server\Instance for named SQL instances! 
#$SQLDBName = "MyDB" 
#$SQLConn = New-Object System.Data.SqlClient.SqlConnection 
#$SQLConn.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True" 
#$sw = new-object system.IO.StreamWriter("c:\dba\powershell\Server_List.txt",1) 
#$cmd="SELECT DISTINCT ServerName FROM dbo.Servers" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $SQLConn) 
#$dt = new-object System.Data.Datatable 
#$da.fill($dt) 
#foreach($Result in $Results){ 
#  $Result.ToString() 
#  $sw.writeline($Results) 
#}
#The script runs fine and the output to the file looks something like this:
#ServerName
#------------
#Server1
#Server2
#Server3
#...
#...
#My question is, how can I elimnate the column name (ServerName) and the dashes (-----------) from the output to the text file so that my text file just holds the server names?
#Chad Miller
#Basic Member
#
#Posts:198
#09 Jun 2011 02:47 PM
# 
#$SQLServer = "MyMainServer" #use Server\Instance for named SQL instances!
#$SQLDBName = "MyDB"
#$SQLConn = New-Object System.Data.SqlClient.SqlConnection
#$SQLConn.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
#$cmd="SELECT DISTINCT ServerName FROM dbo.Servers"
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $SQLConn)
#$dt = new-object System.Data.Datatable
#$da.fill($dt) | out-null
#$dt | select -ExpandProperty server_name >> ./server_list.txt
#get-content .\server_list.txt
#rerichards
#New Member
#
#Posts:10
#09 Jun 2011 08:31 PM
#Thanks Chad. Exactly what I needed.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Invoke-Sqlcmd warning
#Last Post 02 Jun 2011 10:50 PM by Diana. 2 Replies.
#AuthorMessages
#Diana
#New Member
#
#Posts:7
#02 Jun 2011 12:46 PM
#When I'm using Invoke-Sqlcmd the console displays a warning message - "WARNING: Using provider context. Server = ServerName".
#Why does this message appear? Is there anything I can do about it?
#Chad Miller
#Basic Member
#
#Posts:198
#02 Jun 2011 03:35 PM
#The message appears because that is how the SQL Server product team implemented the cmdlet. I would agree it doesn't make sense. You can however suppress or ignore the message using the -SuppressProviderContextWarning and -IgnoreProviderContext switches. See get-help invoke-sqlcmd -full for an explanation of these switch parameters.
#Diana
#New Member
#
#Posts:7
#02 Jun 2011 10:50 PM
#Thank you, Chad. I'm still a beginner, so please bear with me :)
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Exception calling "AttachDatabase" with "3" argument(s)
#Last Post 26 May 2011 07:06 AM by Hemant Kumar. 3 Replies.
#AuthorMessages
#Hemant Kumar
#New Member
#
#Posts:3
#17 May 2011 05:51 AM
#Hello Everyone,
#I 'm trying to backup the mdf file using the following approach but the script fails when attaching the database back to the server. I have started facing this issue in our new server (Windows Server 2008 R2). The following is the scriplet. 
##load assemblies
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null 
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null 
#write-host "Initializing..." 
##Initialization section 
#$serverName = "sqlserver\SQL2005" 
#$databaseName = "myDatabase" 
#$sourceLocation = "\\sqlserver\dbPath\myDatabase" 
#$attachDBSourceLocation = "D:\Sql 2005 Databases\dbPath\myDatabase"
#$mdfFileName = $sourceLocation + "\" + $databaseName + ".mdf" 
#$attachMDFFileName = $attachDBSourceLocation + "\" + $databaseName + ".mdf" 
#$ldfFileName = $sourceLocation + "\" + $databaseName + "_log.ldf" 
#$destLocation = read-host -prompt "Enter the destination location" 
##End of Initialization section 
#write-host "Initialization completed" 
##create a new server object 
#$serverConn = New-Object ("Microsoft.SqlServer.Management.Common.ServerConnection") 
#$serverName, "psuser", "psuser" 
#$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") 
#$serverConn write-host "Server object created" 
#$server.Databases["myDatabase"].ExecuteNonQuery("ALTER DATABASE myDatabase SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE", [Microsoft.SqlServer.Management.Common.ExecutionTypes]::Default) 
##detach the database to be copied. Drop connections if any by changing the connection mode to single user mode 
#$server.DetachDatabase($databaseName, $true) 
#write-host "Database $databaseName detached" 
##copy the database (backup) 
#write-host "Started copying database '$mdfFileName' to '$destLocation'. Please wait..." 
#copy-item $mdfFileName -Destination $destLocation 
#write-host "Database '$databaseName' copied to '$destLocation'" 
##delete the log file 
#remove-item -path $ldfFileName 
#write-host "Database LDF file deleted" #attach the mdf file without ldf so that a new ldf is automatically created 
#write-host "Attaching Database '$databaseName'. Please wait..." 
#$strColl = New-Object ("System.Collections.Specialized.StringCollection")
#[void]$strColl.Add($attachMDFFileName) 
#$server.AttachDatabase($databaseName, $strColl, [Microsoft.SqlServer.Management.Smo.AttachOptions]::NewBroker) 
#write-host "Database attached successfully" 
#write-host "Shrinking Database '$databaseName'. Please wait..." 
#$server.Databases[$databaseName].ExecuteNonQuery("DBCC SHRINKDATABASE ($databaseName, 5)") 
#write-host "Database shrinked successfully" 
#write-host "Database backup successful"
#Hemant Kumar
#New Member
#
#Posts:3
#19 May 2011 09:39 PM
#Any thoughts or ideas guys?
#Chad Miller
#Basic Member
#
#Posts:198
#21 May 2011 07:16 AM
#SMO uses nested error objects. Are there any additional details on error message if you run 
#$error[0] | fl -force 
#Also did this script run fine prior to Win2K8 R2? Do you have UAC turned on? Are you using runas administrator?
#Hemant Kumar
#New Member
#
#Posts:3
#26 May 2011 07:06 AM
#Hi Chad,
#              Thanks for reply. The point you have mentioned on the error details really helped a lot. 
#              I have created a user "psuser" and gave permission to the only database i was working. After the database is detached and copied to a safe location and while trying to add back, the user doesn't have access to other databases or the server. This has caused the script to fail. I was able to identify this issue because of the hint you provided me. Now i have provided "psuser" the role to access master, model, msdb and tempdb database as "dbo" also and now the script is working fine.
#Thanks,
#Hemant.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Login using another AD account
#Last Post 21 May 2011 06:27 AM by Chad Miller. 1 Replies.
#AuthorMessages
#Dave
#New Member
#
#Posts:1
#19 Apr 2011 12:41 PM
#Hello all,
#    I would like to use a AD administrative account instead of my normal account AD to access SQL Server.  This is what I attempted to use:
#$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "$instance"
#     $s.ConnectionContext.LoginSecure = $true
#     $s.ConnectionContext.Login = "adm-account"
#     $s.ConnectionContext.Password = "password"
#It looks like it is still using my normal login instead of the admin. account.  If someone could please point
#me in a direction I would very much appreciate it.
#Dave
#Chad Miller
#Basic Member
#
#Posts:198
#21 May 2011 06:27 AM
#The login and password properties are meant for SQL authentication. Furthermore these need to be specified before creating the SMO.Server object. To use alternate AD account you'll need to run PowerShell.exe as the alternate account.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL query with nothing returned
#Last Post 17 May 2011 04:19 PM by Jonathan. 6 Replies.
#AuthorMessages
#flash69
#New Member
#
#Posts:7
#12 May 2011 05:26 AM
#I have a function where I query SQL and try to determine which action to take.  If the server is not in the database there will be nothing returned from SQL.  I believe this is my problem however I don't know how to handle it.
#function getsysid {
#$Command = New-Object System.Data.SQLClient.SQLCommand
#$Command.Connection = $sqlconn
#$Command.CommandText = "SELECT sysid FROM systems WHERE systemname = '" + $server + "'"
#$Reader = $Command.ExecuteReader()
#while ( $Reader.read() ) {
#$sysid = $Reader[0]
#if ( $sysid -eq $null ) {
#Write-Host "$server not in the database"
#}
#else {
#Write-Host $server $sysid
#}
#}
#}
#I have also tried using [DBNull]::Value however that did not work either.
#Can someone help with this?
#Jonathan
#Basic Member
#
#Posts:175
#12 May 2011 06:20 AM
#Hi Flash,
#I have a blog post about getting data from a SQL server.  It is located at http://powershellreflections.wordpr...-sql-data/ .  In this article, I use a DataAdapter object to fill a dataset.  When you execute that 'fill' method, it will return a number equal to the number of rows retrieved from the database.  You can capture this number in a variable and if greater than 0, have it read the information, or else, return your '$server not in database' message.
#I think if you follow the example of my script, you can probably re-write yours in the same format and get what you are after.
#Let me know if you have any questions.
#Regards
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#Chad Miller
#Basic Member
#
#Posts:198
#12 May 2011 07:00 AM
#Use the reader hasrows property as follows. I also added closing connection...
#$server = "$env:computername\sql1" 
#$Database = "master"
#$sqlconn = new-object System.Data.SqlClient.SQLConnection $("Server={0};Database={1};Integrated Security=True;" -f $server,$Database) 
#$sqlconn.Open() 
#$Command = New-Object System.Data.SQLClient.SQLCommand 
#$Command.Connection = $sqlconn 
##Test true with "SELECT 1 AS sysid WHERE 1=1" 
#$Command.CommandText = "SELECT 1 AS sysid WHERE 1=2"
#$Reader = $Command.ExecuteReader()
# if (-not($reader.HasRows)) 
#{Write-Host "$server not in the database"} 
#else {
#    while ( $Reader.read() ) {
#    $sysid = $Reader[0] 
#    Write-Host $server $sysid 
#   }
#}
#$sqlconn.Close() 
#flash69
#New Member
#
#Posts:7
#12 May 2011 07:13 AM
#Thank you both for your replies. I am going to test them both. 
#Nathan - I am looking at your blog now. Thank You! 
#Chad - I have a function to open and close the DB which I didn't post, sorry I should have stated that. Thank you! 
#flash69
#New Member
#
#Posts:7
#16 May 2011 11:25 AM
#Again I would like to say thank you for the help. I do have more problems I cannot resolve. If you don't mind I would like to ask for more advice. 
#Also I would like ANY advice on these scripts. 
#Background: 
#Currently I have 3 scripts that I am going to use for inventorying machines on the network. The main script calls the other scripts via dot sourcing. The script I am currently working on is the Network info script (network.ps1). This script performs a WMI query on Win32_NetworkAdapterConfiguration for every machine. In this script I am trying to get the nics_id so I can either INSERT (if not exists) or UPDATE (if exists). 
#I created another function just like the one in my previous post except it queries the nics table. 
#function newgetnicsid { 
#$sqlcmd = New-Object System.Data.SQLClient.SQLCommand 
#$sqlcmd.Connection = $sqlconn 
#$sqlcmd.CommandText = "SELECT nics_id FROM nics WHERE nics_sysid = '" + $sysid + "'" 
#$dataadapter = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd 
#$dataset = New-Object System.Data.DataSet 
#[Void]$dataadapter.Fill($dataset) 
#} 
#This works however I don't seem to understand how to use it below. 
#network.ps1 
#param ($server) 
#newgetnicsid 
#function getnic { 
#gettime 
## new network section 
#$network = gwmi Win32_NetworkAdapterConfiguration -computername $server -Filter "IPEnabled = $true" 
#getnicsid 
#foreach ( $objitem in $network ) { 
##IPv4 
#$sqlcmd = $sqlconn.CreateCommand() 
#if ( $nicsid -eq 0 ) { 
#$sqlcmd.CommandText = "INSERT INTO [inventory].dbo.[nics] (" + 
#"nics_sysid , " + 
#"description , " + 
#"ip , " + 
#"mac , " + 
#"subnet , " + 
#"defaultgw , " + 
#"dnssearchorder , " + 
#"winsprimary , " + 
#"winssecondary , " + 
#"scantime " + 
#") VALUES ('" + 
#$sysid + "','" + 
#$objitem.description + "','" + 
#$objitem.ipaddress[0] + "','" + 
#$objitem.macaddress + "','" + 
#$objitem.ipsubnet + "','" + 
#$objitem.defaultipgateway + "','" + 
#$objitem.dnsserversearchorder + "','" + 
#$objitem.winsprimaryserver + "','" + 
#$objitem.winssecondaryserver + "','" + 
#$scantime + "')" 
#$sqlcmd.ExecuteNonQuery() 
#} 
#else { 
##newgetnicsid 
#foreach ( $nicsid in $dataset.Tables[0].Rows ) { 
#$sqlcmd.CommandText = "update [inventory].dbo.[nics] SET " + 
#"description = '" + $objitem.description + "'," + 
#"ip = '" + $objitem.ipaddress[0] + "'," + 
#"mac = '" + $objitem.macaddress + "'," + 
#"subnet = '" + $objitem.ipsubnet + "'," + 
#"defaultgw = '" + $objitem.defaultipgateway + "'," + 
#"dnssearchorder = '" + $objitem.dnsserversearchorder + "'," + 
#"winsprimary = '" + $objitem.winsprimaryserver + "'," + 
#"winssecondary = '" + $objitem.winssecondaryserver + "'," + 
#"scantime = '" + $scantime + "'" + 
#"where nics_sysid = '" + $sysid + "' and nics_id = '" + $nicsid + "' and mac = '" + $objitem.macaddress + "'" 
#} 
#} 
##IPv6 
#} 
#} 
#flash69
#New Member
#
#Posts:7
#17 May 2011 08:16 AM
#Anyone have any advice? 
#Perhaps I should consider using an 'if exists update else insert' statement?
#Jonathan
#Basic Member
#
#Posts:175
#17 May 2011 04:19 PM
#Hi,
#I am not sure I completely follow your script below (not sure where you are getting $nicsid to compare if it is 0), but it would seem that you shouldn't have to check the entire record.  Your database should have some sort of primary key that you could get from one of the records you are trying to add/update (IP Address, MAC Address, etc, that should be unique).  You should then be able to query the database for the record with that key.  If it exists, then update fields for that primary key...otherwise, create a new field.
#For example:
#(psedocode)
#Function DoesNICExist ($IPAddress)
#{
#   SELECT * FROM NICSTable WHERE IP = $IPAddress
#   if (rows = 1)
#   {
#      return $true
#   }
#   else
#   {
#      return $false
#   }
#}
#If (DoesNICExist -IPAddress $IP)
#{
#   Update NICSTable SET field1 = value1, field2 = value2, ...fieldn = valuen WHERE IP = $IP
#}
#else
#{
#   INSERT INTO NICSTable SET field1, field2...fieldn VALUE value1, value2...valuen
#}
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Getting SQL Server version from multiple servers
#Last Post 10 May 2011 11:47 PM by Shay Levy. 9 Replies.
#AuthorMessages
#Alex
#New Member
#
#Posts:4
#10 May 2011 08:10 AM
#I have written a script that will loop to get the SQL Server version on multiple servers/instances but it will not output all to a csv file. I am pretty sure it is the foreach command. My script is below. Any help would be appreciated. 
#foreach ($svr in Get-Content "C:\DBAScripts\SQLServers.txt") 
#{ 
#$con = "server=$svr;database=master;Integrated Security=sspi" 
#$cmd = "select serverproperty('servername') as Name,serverproperty('productversion') as Version,serverproperty('productlevel') ServicePack,serverproperty('edition') as Edition" 
#$da = New-Object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = New-Object System.Data.DataTable 
#$da.fill($dt) 
#$dt | Export-csv C:\DBAScripts\Test.csv 
#}
#Jonathan
#Basic Member
#
#Posts:175
#10 May 2011 08:45 AM
#Hi Alex, 
#I would suggest a small change. On your last line, instead of trying to immediately export to CSV, try "Write-Output $dt" instead. This will output the objects to the pipeline, which is how Powershell is designed to work. Each iteration through will push those objects to your next cmdlet. So, if your script is named "Get-SQLVersions.ps1", you would have the following command line: 
#C:\ PS > .\Get-SQLVersions.ps1 | export-csv c:\DBAScripts\Test.csv 
#Try that and let me know how it works.
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#Alex
#New Member
#
#Posts:4
#10 May 2011 09:51 AM
#The "Write-Output $dt" gives me the correct format I am looking for but when I call that script, it produces no results. It only has one line (#TYPE System.Int32) in the csv file but nothing else.
#bkastner
#New Member
#
#Posts:2
#10 May 2011 11:08 AM
#Each call to Export-CSV in the foreach loop over-writes the prior loop results. Try changing the line
#$dt | Export-csv C:\DBAScripts\Test.csv 
#to 
#$dt | ConvertTo-Csv 
#Then call your script with a pipe to Out-File. 
#PS> .\Get-SQLVersions.ps1 | Out-File C:\DBAScripts\Test.csv 
#HTH
#Alex
#New Member
#
#Posts:4
#10 May 2011 11:15 AM
#That actually worked. Thanks to the both of you.
#Chad Miller
#Basic Member
#
#Posts:198
#10 May 2011 11:23 AM
#I see a couple of problems, your call to $da.fill($dt) produces a 1 (int32) so assign the output to null, second you are overwriting the CSV file for each server, so move the export-csv outside the foreach block as show below:
#Get-Content"C:\DBAScripts\SQLServers.txt"| foreach {$srv=$_$con="server=$svr;database=master;Integrated Security=sspi"$cmd="select serverproperty('servername') as Name,serverproperty('productversion') as Version,serverproperty('productlevel') ServicePack,serverproperty('edition') as Edition"$da=New-ObjectSystem.Data.SqlClient.SqlDataAdapter($cmd,$con)$dt=New-ObjectSystem.Data.DataTable$null=$da.fill($dt)$dt } | Export-csvC:\DBAScripts\Test.csv -NoTypeInformation
#0ptikGhost
#Basic Member
#
#Posts:369
#10 May 2011 11:32 AM
#Updated: Added "$null =" as suggested by Jonathan.
#Try something like this:
#$( foreach ($server in @(Get-Content C:\DBAScripts\SQLServers.txt)) {
#    $connectionString = "server=${server};database=master;Integrated Security=sspi"
#    $query = "select serverproperty('servername') as Name, serverproperty('productversion') as Version, serverproperty('productlevel') as ServicePack, serverproperty('edition') as Edition"
#    $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter @( $connectionString, $query )
#    $dataTable = New-Object System.Data.DataTable
#    $null = $dataAdapter.Fill($dataTable)
#    $dataTable | Write-Output
#} ) | Export-Csv -NoTypeInformation C:\DBAScripts\Test.csv
#Blog - http://0ptikghost.blogspot.com 
#Jonathan
#Basic Member
#
#Posts:175
#10 May 2011 11:43 AM
#Man, you had me stumped there for a bit. The reason your output file has #Type System.Int32 is because the script is outputting the object from the fill method. 
#Change the line "$da.fill($dt)" to "$da.fill($dt) | out-null" and try it again. The Export-CSV cmdlet is picking up the first object that comes through the pipeline, which in this case is the number of rows, 1, that are populating the datatable. 
#If you don't wish to have the TYPE information at the top of the CSV file, you can add the -NoTypeInformation to the Export-CSV cmdlet when you run your script. 
#Let me know if that doesn't help!
#Of course, now that I have posted my answer, I see that everyone else jumped in! LOL!  Oh well...it was a great learning exercise for me to figure it out as well.
#Jonathan Tyler
#http://powershellreflections.wordpress.com
#Follow Me On Twitter
#Alex
#New Member
#
#Posts:4
#10 May 2011 11:53 AM
#Jonathan, your script was perfect. Not only did it work but it was perfect formatting. Thanks.
#Shay Levy
#PowerShell MVP, Admin
#Veteran Member
#
#Posts:1362
#10 May 2011 11:47 PM
#Here's an example using Microsoft.SqlServer.Smo: 
#$null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') 
#Get-Content C:\DBAScripts\SQLServers.txt | Foreach-Object{ 
#New-Object Microsoft.SqlServer.Management.Smo.Server $_ | Select-Object Name,@{n='Version';e={$_.Information.Version}} 
#}
#Shay Levy
#Windows PowerShell MVP
#http://PowerShay.com
#PowerShell Community Toolbar
#Twitter: @ShayLevy
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#[MySql.Data.MySqlClient.MySqlCommand]::ExecuteNonQuery() Returns -1
#Last Post 29 Apr 2011 08:57 AM by bernd_k. 3 Replies.
#AuthorMessages
#LMizuhashi
#New Member
#
#Posts:24
#28 Apr 2011 02:59 PM
#I'm trying to write a PowerShell script that will check the maximum character length of a field in a given table and database. Here's the code:
#<# I'm using MySQL. This loads the .NET Connector module #>
#if ($ENV:Processor_Architecture = "x86") {
#         [void][system.reflection.Assembly]::LoadFrom(“C:\Program Files\MySQL\MySQL Connector Net 5.1.7\Binaries\.NET 2.0\MySQL.Data.dll”)
#} else {
#         [void][system.reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\MySQL\MySQL Connector Net 5.1.7\Binaries\.NET 2.0\MySQL.Data.dll”) }
#$A = New-Object MySql.Data.MySqlClient.MySqlConnection
#$A.ConnectionString = “server=server;user id=user;password=password; database=information_schema;pooling=false”
#$A.Open()
#$B = New-Object MySql.Data.MySqlClient.MySqlCommand
#$B.Connection = $SchemaConnection
#$B.CommandText = “SELECT CHARACTER_MAXIMUM_LENGTH FROM COLUMNS WHERE TABLE_SCHEMA = 'MyDatabase' AND TABLE_NAME = 'MyTable' AND COLUMN_NAME = 'MyColumn'”
#$B.ExecuteNonQuery() <# This line returns the value -1 #>
#$A.Close()
#Any ideas on how to get this thing to return the value of CHARACTER_MAXIMUM_LENGTH from the COLUMNS table in the information_schema database on a MySQL server?
#bernd_k
#New Member
#
#Posts:7
#29 Apr 2011 07:03 AMAccepted Answer 
#This works for me: 
#[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data") 
#$A = New-Object MySql.Data.MySqlClient.MySqlConnection 
#$A.ConnectionString = “server=localhost;user id=root;password=mypassword;database=information_schema;pooling=false” 
#$A.Open() 
#$B = New-Object MySql.Data.MySqlClient.MySqlCommand 
#$B.Connection = $a 
#$B.CommandText = “SELECT CHARACTER_MAXIMUM_LENGTH FROM COLUMNS WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'city' AND COLUMN_NAME = 'city'” 
#$B.ExecuteScalar() 
#$A.Close() 
#LMizuhashi
#New Member
#
#Posts:24
#29 Apr 2011 07:50 AM
#That did the trick. Thank you!
#May I ask, how did you learn about the .NET Framework?
#(I assume the object class we're working with here, MySql.Data.MySqlClient.MySqlComman, came from the .NET Framework. I'd like to know enough to be able to find the right class for the job and know which methods to use on my own.)
#Again, thanks a million!
#bernd_k
#New Member
#
#Posts:7
#29 Apr 2011 08:57 AM
#I happened to learn it in the context of PowerShell. I had a VB background, didn't go C#, but specialized in database and scripting. You can find a lot of examples of the use of PowerShell to work with databases by studying the code of this project http://sqlpsx.codeplex.com/.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How to call SQL Stored procedure?
#Last Post 26 Apr 2011 01:04 AM by ananda. 2 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#25 Apr 2011 04:28 AM
#Hi,
#Procedure Name - Exec checkFragmentation
#output
#---------
#Table
#Index
#Avg Fragmentation
#page count
#SQL Script
#there is no input paratmeter,
#Power shell script as below
#foreach ($Reslut in $body)
#{
#$con = "server=IPAddress;database=master;Integrated Security=true" 
#   $cmd="EXEC master..xp_fixeddrives"
#  $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)
#  $dt1 = new-object System.Data.Datatable
#  $da.fill($dt1)
#  $svr
#  $Reslut1 = $dt1 | out-string
##email 
#foreach ($item in $body)
#{ 
#$smtp = new-object Net.Mail.SmtpClient("IPAddress") 
#$subject="SQL fragmentation  status Report From servername"  
#$from="servername@RIL.COM" 
#               $to = "ananda.murugesan@ril.com"
#               $cc = get-content "D:\DC\EmailList.txt"
#               $msg = New-Object system.net.mail.mailmessage
#               $msg.From = $from
#               $msg.to.add($to)
#               $msg.cc.add($cc)
#               $msg.Subject = $subject
#           $bodyText = ("$Reslut1")
#           $msg.Body = $bodyText
#               $smtp.Send($msg)
#} 
#This script is working fine as per free disk space check and receiving mail on daily basis.
#I want to get Index fragmentation status on monthly basis in database, please tell me how to include this stored procedure?
#Thanks
#ananda
#Chad Miller
#Basic Member
#
#Posts:198
#25 Apr 2011 09:07 AM
#Assuming your script works, you should be able to change the 
#$cmd="EXEC checkFragmentation" 
#You may also need to change your connection string if the checkFragemention procedure isn't in the master database
#ananda
#New Member
#
#Posts:28
#26 Apr 2011 01:04 AM
#Hi cmille19 , Thanks for reply.........
#Yes. It is working. 
#There are 5 SQL database in server. what i did manually executed checkFragmentation procedure for all five database. 
#One single powershell Script -->Indexfrag.ps1 
#I used the connection string ->$con = "server=IPAddress;database=Master;User Id=sa;Password=pw" 
#$cmd="exec Database1.dbo.checkFragmentation " 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt1 = new-object System.Data.Datatable 
#$da.fill($dt1) 
#$svr 
#$Reslut1 = $dt1 | out-string 
#$cmd="exec Database2.dbo.checkFragmentation " 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt2 = new-object System.Data.Datatable 
#$da.fill($dt2) 
#$svr 
#$Reslut2 = $dt2 | out-string 
#This above script working fine, and totally 10 records received continuous in email body. 
#Please tell me, which records belongs to which database? I want sample output like below 
#Database1 
#------------ 
#Table : Test_Result 
#Index : IDX_Sample_InTime 
#Avg Fragmentation : 10.9222 
#Page Count : 6528 
#SQL script : alter index [IDX_Sample_InTime] on [Test_Result] reorganize 
#Database2 
#-------------- 
#Table : Test_Result_Detail 
#Index : PK_Test_Result_Detail 
#Avg Fragmentation : 77.0330 
#Page Count : 49680 
#SQL script : alter index [PK_Test_Result_Detail] on [Test_Result_Detail] rebuild 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Execution error
#Last Post 19 Apr 2011 05:06 AM by ananda. 2 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#18 Apr 2011 02:54 AM
#Hi,
#PS D:\Monitor> .NB010.ps1
#The term '.NB010.ps1' is not recognized as a cmdlet, function, operable program, or script
#and try again.
#At line:1 char:17
#+ .NB010.ps1 <<<<
#Pl.give me, correct command, how to execute this script.
#Thanks
#ananda
#0ptikGhost
#Basic Member
#
#Posts:369
#18 Apr 2011 02:58 PM
#What is the absolute path to the script you are attempting to execute?
#The error you see is telling you that PowerShell cannot find the .NB010.ps1 script. More likely than not this occurred because of a typo.
#My guess is that the filename is NB010.ps1 and it's absolute path is D:\Monitor\NB010.ps1. If this is accurate then you indeed have a typo. Try the following:
#PS D:\Monitor> .\NB010.ps1
#This tells PowerShell to execute NB010.ps1 found in the current location (as specified by Get-Location). The PowerShell prompt also tells me that the current location is D:\Monitor.
#Blog - http://0ptikghost.blogspot.com 
#ananda
#New Member
#
#Posts:28
#19 Apr 2011 05:06 AM
#Hi OptikGhost, 
#Thanks for reply.. 
#It is working fine. 
#I done mistake for not correct path mention. 
#rgds 
#ananda 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Network error
#Last Post 18 Apr 2011 02:51 AM by ananda. 2 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#22 Mar 2011 04:45 AM
#At D:\Monitor\SQLBkpJGSRVR55.ps1:22 char:11
#+   $da.fill <<<< ($dt2)
#Exception calling "Fill" with "1" argument(s): "A network-related or instance-specific error occurre
#g a connection to SQL Server. The server was not found or was not accessible. Verify that the instance
#and that SQL Server is configured to allow remote connections. (provider: Named Pipes Provider, error
#open a connection to SQL Server)"
#this powershell coding was working for last 1 years.
#last week n/w team depolying some activity and disabled remote desktop connection also, after that this script is not working.
#Is there any alternative way for running this script. But remote SQL server machine is getting ping. I could not able to connect Remote disktop connection.
#rgds
#ananda
#0ptikGhost
#Basic Member
#
#Posts:369
#22 Mar 2011 06:03 AM
#This sounds like the SQL Server service is not running or was reconfigured to not allow the connection type you are trying to use. I really doubt this is a problem with your PowerShell script.
#Blog - http://0ptikghost.blogspot.com 
#ananda
#New Member
#
#Posts:28
#18 Apr 2011 02:51 AM
#problem resolved, due to block the SQL port 1433 by network team.
#Rgds
#ananda
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell script, SQL Server Agent Job Issues
#Last Post 11 Apr 2011 02:10 PM by Bobs. 0 Replies.
#AuthorMessages
#Bobs
#New Member
#
#Posts:1
#11 Apr 2011 02:10 PM
#Hi ... I am having an issue with a powershell step inside a SQL Server Agent job.  The job step does execute but only after a second iteration.  There are no "Retry Attempts".  The first execution remains in a "In Progress" state forever.  It does not seem to affect the overall execution of the job.
#OS: Windows 2008 R2
#SQL Server: 2008
#PowerShell: 2.0
#The purpose of the job is to detact whether a specific process is running on the Windows host.  That process isa NetApp  excutibale called sdcli.exe.  It cannot be runing when this job is executed.  The idea ti to what until the sdcli process exits so my job can start ... otherwise I have a big mess on my hands!
#Code/Job Step:
#$ProcessActive = Get-Process -computerName CORP-SQLATDEV1 -Name sdcli -ErrorAction SilentlyContinue
#if($ProcessActive -ne $null) 
#{ 
#   throw "Failure" 
#} 
#This is a portion of the SQL Agent log for the job:
#04/11/2011 15:20:00,GROrders Database Detach,In Progress,1,CORP-SQLATDEV1,GROrders Database Detach,Check SDCLI process,,,00:00:01,0,0,,,,0
#04/11/2011 15:20:00,GROrders Database Detach,Success,1,CORP-SQLATDEV1,GROrders Database Detach,Check SDCLI process,,Executed as user: . The step succeeded.,00:00:01,0,0,,,,0 
#As one can see, the job never really executes but says that its in progress ... i.e., it never successes.
#The code was run in a PowerShell cmd environment to test it out before it was pasted into an agent job and showed none of this behavior.
#Any help on this matter would be appreciated.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Query Results - Sybase ASE
#Last Post 29 Mar 2011 10:35 AM by sqlman69. 5 Replies.
#AuthorMessages
#wifeaggro
#New Member
#
#Posts:6
#06 Feb 2011 08:21 AM
#I'm definitely a beginner with PS; so be easy on me, please...  Basically, I would like to query a database and have the results returned to a variable.  This is what I'm currently working with so far (located most of this online; so if it's yours - Thanks!)
#$query="my query"
#$conn=New-Object System.Data.Odbc.OdbcConnection
#$conn.ConnectionString="driver={Sybase ASE ODBC Driver};dsn=dsn;db=db;na=na,port;uid=uid;pwd=pwd;"
#$conn.open()
#$cmd=new-object System.Data.Odbc.OdbcCommand($query,$conn)
#$cmd.CommandTimeout=15
#$ds=New-Object system.Data.DataSet
#$da=New-Object system.Data.odbc.odbcDataAdapter($cmd)
#$da.fill($ds)
#$ds.Tables[0]
#$conn.close()
#Now connecting isn't an issue.  I'm able to hit the server and authenticate without a problem.  So far all this returns is my return status; which is a numerical value.  When I run my query in SQL Advantage I get about 20 different rows back containing all of the account information. Any help would be much appreciated.  Please let me know if additional information is needed.
#EDIT: Removed the second part of my question about referencing a variable with a variable.  Apparently it's really straight forward and simple.
#Thanks again to anyone who takes the time to read this.  I know this may be basic stuff, but I'm still learning.
#Chad Miller
#Basic Member
#
#Posts:198
#06 Feb 2011 02:52 PM
#I don't have a Sybase database server to test with, but the syntax looks correct (same pattern for Oracle and SQL Server, just different drives). 
#I would suggest looking at your dataset. 
#$ds | get-member 
#or 
#$ds.Tables.Count 
#How many data tables are returned from count? 
#Does your query return multiple result sets or make use of print statements?
#wifeaggro
#New Member
#
#Posts:6
#07 Feb 2011 03:39 AM
#It has to be a print statement. Any idea on what my options are now?
#Chad Miller
#Basic Member
#
#Posts:198
#07 Feb 2011 08:31 AM
#T-SQL PRINT and RAISERROR messages are not returned to the client by default. I'm not sure if the Sybase driver you are using supports events, but adapting a SQL Server example I've used -- you'll need to add an event handler to the connection in order to return PRINT and RAISERROR messages: 
#$handler = [System.Data.Odbc.OdbcInfoMessageEventHandler] {Write-Output "$($_)"} 
#$conn.add_InfoMessage($handler) 
#This should be added before the call to $conn.Open() 
#I'm not sure about the add_InfoMessage method (whether this method exists for the Sybase drive) and I don't have a Sybase database to test with -- only installed Sybase one time many years ago. 
#wifeaggro
#New Member
#
#Posts:6
#08 Feb 2011 03:44 AM
#add_InfoMessage is returning invalid operation, but with everything you've given me, I may be able to locate a valid method. Thank you for the information!
#sqlman69
#New Member
#
#Posts:18
#29 Mar 2011 10:35 AM
#$conn = new-object system.data.oledb.oledbconnection 
#$connstring = "Provider=ASEOLEDB;Data Source=10.xx.xx.xx:5000;Database = master; User ID = sadbauser;Password = xxxxxxxx;" 
#$conn.connectionstring = $connstring 
#$conn.open() 
#$query = "select @@errorlog" 
#$cmd = New-Object system.data.oledb.oledbcommand 
#$cmd.connection = $conn 
#$cmd.commandtext = $query 
#$cmd.executenonquery() 
#$conn.close()
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Problems to Backup the Transaction Log
#Last Post 25 Mar 2011 09:38 AM by NanRos. 2 Replies.
#AuthorMessages
#NanRos
#New Member
#
#Posts:2
#24 Mar 2011 08:18 AM
#Hello...
#I'm new in PowerShell. This is the first time I'm using this tool so I don't know much but I found a script to backup the SQL database. Here is the script I'm using:
#=============================================
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")| out-null [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")| out-null $instance = "TAFSQL" 
#$s = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instance 
#$bkdir = "C:\BackDB" #We define the folder path as a variable 
#$dbname = "SIAT" 
#$dt = get-date -format yyyyMMddHHmmss #We use this to create a file name based on the timestamp 
#$dbBackup = new-object ("Microsoft.SqlServer.Management.Smo.Backup") 
#$dbBackup.Action = "Database" 
#$dbBackup.Database = $dbname 
#$dbBackup.Devices.AddDevice($bkdir + "\" + $dbname + "_Full_" + $dt + ".bak", "File") 
#$dbBackup.SqlBackup($s)
#Whe I want to runa a incremental backup I only add this line:
#$dbBackup.Incremental = $TRUE
#and change this line:
#$dbBackup.Devices.AddDevice($bkdir + "\" + $dbname + "_Diff_" + $dt + ".bak", "File") 
#And the incremental backup runs correctly
#But when I want to use this script to backup the transacion log I change this two lines:
#$dbBackup.Action = "Log" 
#$dbBackup.Devices.AddDevice($bkdir + "\" + $dbname + "_Log_" + $dt + ".trn", "File") 
#And it fails, I get this error:
#Excepción al llamar a "SqlBackup" con los argumentos "1": "Backup failed for Server 'TAFSQL'. " En línea: 14 Carácter: 20 
#+ $dbBackup.SqlBackup <<<< ($s) 
#+ CategoryInfo : NotSpecified: (:) [], MethodInvocationException 
#+ FullyQualifiedErrorId : DotNetMethodException
#Can somebody help me?, i guess is not about permission or security because the other two backups are running correclty.
#I'm runnign thie in a windows xp machine with SQL Server 2008R2
#Thank you for help.
#Nancy R.
#Chad Miller
#Basic Member
#
#Posts:198
#24 Mar 2011 05:28 PM
#SMO uses nested exceptions, try running 
#$error[0]|format-list -force 
#to get the error message. I ran the your code and was able to reproduce failure if the database was in simple mode. "$error[0]|format-list -force" showed the following error message: 
#System.Management.Automation.MethodInvocationException: Exception calling "SqlBackup" with "1" argument(s): "Backup failed 
#for Server 'Z003\r2'. " ---> Microsoft.SqlServer.Management.Smo.FailedOperationException: Backup failed for Server 'Z003\ 
#r2'. ---> Microsoft.SqlServer.Management.Common.ExecutionFailureException: An exception occurred while executing a Transa 
#ct-SQL statement or batch. ---> System.Data.SqlClient.SqlException: The statement BACKUP LOG is not allowed while the reco 
#very model is SIMPLE. Use BACKUP DATABASE or change the recovery model using ALTER DATABASE. 
#BACKUP LOG is terminating abnormally. 
#NanRos
#New Member
#
#Posts:2
#25 Mar 2011 09:38 AM
#You're right Chad. Thank you very much for your tip. Now I can backup the trans log file :D
#Regards,
#Nancy
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL Query
#Last Post 11 Mar 2011 02:50 PM by Chad Miller. 1 Replies.
#AuthorMessages
#WallaceTech
#New Member
#
#Posts:10
#11 Mar 2011 01:40 AM
#Guys.
#Please forgive me i am very very new to Powershell and moving over from VBScript. I put together a some code that will connect to a SQL server and run and SQL command looking for a user called ABC.
#When i run the code i get a return on screen for the user ABC that i am looking for.
#What i would like to do is if ABC is found then display User Found or if not displ User NOT Found.
#Can anyone help me along to get me started.
#Thanks in advance
#The Code so far.......
#$SQLServer = "SERVER NAME" #use Server\Instance for named SQL instances! 
#$SQLDBName = "DATABASE NAME" $SqlQuery = "select userid from mhgroup.docusers where userid = 'CJW'" $SQLConn = New-Object System.Data.SqlClient.SqlConnection 
#$SQLConn.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True" 
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
#$SqlCmd.CommandText = $SqlQuery 
#$SqlCmd.Connection = $SQLConn 
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
#$SqlAdapter.SelectCommand = $SqlCmd 
#$DS = New-Object System.Data.DataSet 
#$SqlAdapter.Fill($DS) 
#$SQLConn.Close() 
#clear 
#$DS.Tables[0]
#Chad Miller
#Basic Member
#
#Posts:198
#11 Mar 2011 02:50 PM
#Assuming your query is working correctly you only want to check if the query returned rows, you could add this to your script: 
#if ($DS.Tables[0] -ne $null) 
#{ Write-host "User Found" } 
#else 
#{ Write-Host "User NOT Found" } 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Calling SSRS with Form Authentication
#Last Post 09 Mar 2011 05:33 PM by Dat. 0 Replies.
#AuthorMessages
#Dat
#New Member
#
#Posts:1
#09 Mar 2011 05:33 PM
## SSRS 2008 R2 (Form Authentication - Login.aspx)
## -----------------------
#$reportServerURI = "htttp://localhost/reportserver/ReportExecution2005.asmx?wsdl"
#$RS = New-WebServiceProxy -Class 'RS' -NameSpace 'RS' -Uri $reportServerURI -UseDefaultCredential
#$RS.Url = $reportServerURI 
## Passing into Form Authentication (Not working)
## -----------------------
#$CredentialCache = New-Object System.Net.CredentialCache
#$URI = New-Object System.Uri("http://localhost")
#$NetworkCredential = New-Object System.Net.NetworkCredential("uid", "pwd", "MachineName")
#$CredentialCache.Add($URI, "Basic", $NetworkCredential)
#$RS.Credentials = $CredentialCache
## ----------------------- 
#$Report = $RS.LoadReport($report_path, $null)
#Error:
#New-WebServiceProxy : The document at the url h
#http://localhost/reportserver/ReportExecution2005.asmx?wsdl"> ttp://localhost/reportserver/ReportExecution2005.asmx?wsdl BR>
#Fiddler debug has shown that when requesting http://localhost/reportserver/ReportExecution2005.asmx?wsdl
#it return the login form rather than valid XML(DISCO Document).
#Can you help me with the Form Authentication Code?
#Many Thanks.
#Regards Dat.
#@datauduong
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Hiding password in SQL Server ConnectionString
#Last Post 04 Mar 2011 03:41 PM by Chad Miller. 1 Replies.
#AuthorMessages
#frogyy
#New Member
#
#Posts:1
#04 Mar 2011 03:52 AM
#Hi.
#I have an idea of using securestring to provide password for SqlConnection ConnectionString, but it doesn't seem to work.
#1) Sript to create encrypted password file:
#read-host -prompt "Enter password to be encrypted in mypassword.txt " -assecurestring | convertfrom-securestring | out-file C:\mypassword.txt
#2) Sript that suppose to use this file as a password:
#$pass = cat C:\mypassword.txt | convertto-securestring 
#[void][System.Reflection.Assembly]::LoadWithPartialName("System.Data.SqlClient") 
#$dbconnect = New-Object System.Data.SqlClient.SqlConnection 
#$dbconnect.ConnectionString = “server=server1;user id=myuser;password=$pass;database=mydatabase;pooling=false” 
#$dbconnect.Open() 
#$queryString = "select count(*) from mytable" 
#$command = new-Object System.Data.SqlClient.SqlCommand($queryString, $dbconnect) 
#$f = $command.ExecuteScalar() 
#echo $f 
#$dbconnect.Close()
#Your suggestion/advice/help will be really appreciated.
#Chad Miller
#Basic Member
#
#Posts:198
#04 Mar 2011 03:41 PM
#I've used this technique to encrypt strings:
#http://powershell.com/cs/blogs/tips...ripts.aspx
#Looking at your code I noticed you are missing -asPlainText -force switches
#$secure = ConvertTo-SecureString $script -asPlainText -force 
#$export = $secure | ConvertFrom-SecureString 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Log Windows Service State and Memory to SQL database
#Last Post 02 Mar 2011 06:09 PM by Chad Miller. 7 Replies.
#AuthorMessages
#MadHatter
#New Member
#
#Posts:6
#01 Mar 2011 01:45 PM
#Hello,
#I am looking to gather the state (running, stopped, etc.) of a specific windows service on multiple remote servers as well as its memory usage and log it to a sql database table.
#Does anyone know how I would go about doing this? I'm new to powershell.
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#01 Mar 2011 07:00 PM
#A very simple to construct insert statement from PowerShell command. As an example this statement creates insert statement for a remote computer SQL Server services:
#get-service -computername $env:computername -Include *SQL* | foreach {write-host "INSERT service V ALUES('$($_.MachineName)', '$($_.Name)', '$($_.Status))'"}
#to actually run the insert statement replace write-host with a call to invoke-sqlcmd2:
#http://poshcode.org/2279
#Not sure what you mean by memory usage. Do you want memory usage of the service or of the machine?
#MadHatter
#New Member
#
#Posts:6
#01 Mar 2011 07:20 PM
#Thanks for the reply, 
#I am looking for the current memory usage of the service, basically we have a custom application that runs on a server farm that I would like to insert into a sql table everyday its state, since we do have some crash and the memory its using. I'm just not sure how to write the code needed to grab these values.
#Chad Miller
#Basic Member
#
#Posts:198
#02 Mar 2011 06:13 AM
#Your question has multiple parts first let's see if we can get to just get the server name, service name, state and memory usage:
#gwmi -ComputerName (gc ./servers2.txt) -Class win32_service -filter "name LIKE '%SQL%'" | Select SystemName, name, State, @{n='WorkingSet';e={$(get-process -computername $_.SystemName -Id $_.ProcessId).WorkingSet }}
#What this code does is call get-wmiobject (gwmi) for each server listed in my servers2.txt file where there server name is like SQL then select systemname, service name, service state and adds property called workingset by calling get-process One you have the PowerShell command a very simple thing you could do is send the output to a CSV file then load the data into a SQL table on a regular basis:
# 
#gwmi -ComputerName (gc ./servers2.txt) -Class win32_service -filter "name LIKE '%SQL%'" | Select SystemName, name, State, @{n='WorkingSet';e={$(get-process -computername $_.SystemName -Id $_.ProcessId).WorkingSet }} | export-csv ./memusage.csv -NoTypeInformation
#The solution could get more sophisticated by generating and running insert statements or even creating a an ADO.NET datatable and bulk loading results. I would suggest keeping it simple for now.
#MadHatter
#New Member
#
#Posts:6
#02 Mar 2011 01:55 PM
#Thanks for the help, 
#Since I only have 4 servers in the cluster, I am just going to hard code the hostnames, would you be able to tell me how I can remove the heading from the WorkingSet portion of your code: 
#$Memory = (gwmi -ComputerName 'MyHostname' -Class win32_service -filter "name LIKE '%MyService%'" | Select @{n='WorkingSet';e={$(get-process -computername $_.SystemName -Id $_.ProcessId).WorkingSet }}) 
#I basically just want to return the value so I can insert it into the database, I managed to do it with the state using: 
#$State = (gwmi -ComputerName 'MyHostname' -Class win32_service -filter "name LIKE '%MyService%'" | Select State -Expand State)
#Chad Miller
#Basic Member
#
#Posts:198
#02 Mar 2011 03:27 PM
#If you just want the value of workingset you could do this: 
#gwmi -ComputerName 'myhostname' -Class win32_service -filter "name LIKE '%MyService%'" | foreach {(get-process -computername $_.SystemName -Id $_.ProcessId).WorkingSet } 
#One other thing I'll point out, if you work with PowerShell you'll notice there's a difference in syntax between PowerShell and WMI that can be confusing: 
#In PowerShell -like is the like operator while WMI like (no leading dash). Similarly in PowerShell * is a wildcard while in WMI % is wildcard
#MadHatter
#New Member
#
#Posts:6
#02 Mar 2011 05:12 PM
#Perfect this looks great.. looking at technet, it says that .WorkingSet is deprecated in favour of .WorkingSet64 - do you think I should move to this since I am on 64 bit servers? 
#Another note, I was going to take one more value.. that being .PeakWorkingSet64, but I am getting some strange values. Looking at one of the servers its peak memory in task manager shows: 6,707,196 K but powershell is returning: -1721765888 ... any thoughts? The current .WorkingSet64 is returning the correct value. 
#gwmi -ComputerName 'myhostname' -Class win32_service -filter "name LIKE '%MyService%'" | foreach {(get-process -computername $_.SystemName -Id $_.ProcessId).PeakWorkingSet64 }
#Chad Miller
#Basic Member
#
#Posts:198
#02 Mar 2011 06:09 PM
#I noticed WorkingSet64 returns the same value as WorkingSet on an x86 computer so it probably won't hurt to use the WorkingSet64. 
#I ran the PeakWorkingSet64 on my machine and I'm not getting a negative number. I would suggest looking into what's different about the one server in your environment. Is is x86 while the other x64 is the OS 2003 while the others 2008 etc.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Returning only NON NULL values
#Last Post 22 Feb 2011 04:34 PM by Chad Miller. 1 Replies.
#AuthorMessages
#PoSherLife
#Basic Member
#
#Posts:364
#22 Feb 2011 12:18 PM
#I'm trying to query an SQL DB and only return columns that have data.  Not all rows contain data in all columns, and not all rows contain data in the same columns.  The position of the data is dynamic depending on several factors.
#I do PoSh...not SQL!!!
#When at first you don't succeed Step-Into
#http://theposherlife.blogspot.com
#http://www.jandctravels.com
#Chad Miller
#Basic Member
#
#Posts:198
#22 Feb 2011 04:34 PM
#In SQL this would be expressed using IS NOT NULL. If you have several columns you would need to join together with AND/OR statements. To check if both columns are not null use AND: 
#select col1, col2 
#from table 
#where col1 IS NOT NULL AND col2 IS NOT NULL 
#This is different than PowerShell -ne $null. SQL does NOT support the syntax != NULL or more accurately !=NULL or <> NULL does not work as expected. In truth SQL's interpretation of null is more accurate since a null value is non-value and two non-values can't equal each other.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#export-csv and bulk insert
#Last Post 16 Feb 2011 05:05 PM by Chad Miller. 1 Replies.
#AuthorMessages
#yves
#New Member
#
#Posts:3
#16 Feb 2011 03:18 PM
#hi,
#i have a big problem.
#i export a dataset.table with export-csv. the table has a column with decimal(3.3).
#after the export the column is separated with ",".
#I'm from Germany.
#when i want to import this file with the "bulk insert" from mssql, i got an converting error.
#when i replace the "," with "." the "bulk insert" is correct.
#But i can't replace it every time. the export and import is a piece of an automatic script.
#To read the csv and replace "," with "." is not avalible, because there are other fields, the can have an "," value!
#Can anybody helpme to resolve this probleme?
#Chad Miller
#Basic Member
#
#Posts:198
#16 Feb 2011 05:05 PM
#export-csv supports a delimiter parameter which you can set to any value: 
#For example to set it to a bar/pipe 
#export-csv ./mycsvfile.csv -delimiter '|'
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#delete last row from file
#Last Post 16 Feb 2011 05:03 PM by Chad Miller. 1 Replies.
#AuthorMessages
#tran008
#New Member
#
#Posts:8
#15 Feb 2011 04:54 AM
#hi all, I got couple of flat files that need to be import into SQL. However these some of these file contain blank line at the last row, other this not. How can I check to see if it a blank line, if so, delete it for all the files. thanks
#Chad Miller
#Basic Member
#
#Posts:198
#16 Feb 2011 05:03 PM
#Either of these will filter out blank lines: 
#get-content .\empty.txt | where {$_ -ne ""} 
#get-content .\empty.txt | ? {$_ -notmatch '^$'} 
#The second one uses a regular expression. 
#If you want to update the file in-place: 
#(get-content .\empty.txt) | where {$_ -notmatch '^$'} | set-content ./empty.txt -Encoding ASCI
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Very large selects
#Last Post 16 Feb 2011 12:22 PM by yves. 1 Replies.
#AuthorMessages
#yves
#New Member
#
#Posts:3
#15 Feb 2011 03:56 PM
#Hi, I search a very long time in net, but i don't found the right. I have a very large select from mssql and i get every time a timeout. I try to set the timeout = 0. With this parameter i can get logner selects, but not a very large select. There i get every time the timeout. Can anybody help? SORRY FOR MY ENGLISH!!!
#yves
#New Member
#
#Posts:3
#16 Feb 2011 12:22 PM
#Sorry, i was looking in the wrog function. The $sqlCmd.timeout=0 let me use very large selects
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Query SMS DB
#Last Post 15 Feb 2011 07:16 PM by vstarmanv. 6 Replies.
#AuthorMessages
#mqh7
#New Member
#
#Posts:9
#08 Feb 2011 01:00 PM
#I am totally new to Powershell so bare with me.   I have a list of Login ID's from AD.  In my case it is Mathar01.   In SMS this field or data is called the Last Logged On User.   When SMS does an inventory of any machine it grabs the Last Logged On User and stores it in the SQL DB.
#I have a .TXT file that has over 200 Login ID's.   I need to read each name and then query the SMS DB for that value and if found return the NetBIOS name of their PC & Last Logged On User value and write it back to a new .TXT file.
#Is that possible with Powershell and if so how?  
#Thank you.
#vstarmanv
#New Member
#
#Posts:17
#08 Feb 2011 03:59 PM
#Here is Simple Example 
##load snapin for using sql 
#Add-PSSnapin SqlServerProviderSnapin100 
#Add-PSSnapin SqlServerCmdletSnapin100 
##set your db location 
#Set-Location SQLSERVER:\SQL\computername\Default\Databases\SMSDB 
##get your login id 
#$ids = get-content "C:\AD_Login_List.txt" 
#foreach($id in $ids) 
#{ 
#$query = Invoke-Sqlcmd -Query "select top 1 * from SMSDB WHERE LoginID = $id" ` 
#| ft{$_.NetBIOS, $_.LoginTime} ` #filter what you want 
#| out-file -filepath "C:\test.txt" -encoding utf8 -append # append contents to file 
#} 
#mqh7
#New Member
#
#Posts:9
#09 Feb 2011 09:49 AM
#Thank you. I ran your script and pointed it to our SMS DB. I keep getting the same error. 
#An empty pipe element is not allowed. 
#At C:\Tools\PowerShell\adstuff2.ps1:13 char:2 
#+ | <<<< ft{$_.NetBIOS, $_.LoginTime} ` #filter what you want 
#+ CategoryInfo : ParserError: (:) [], ParseException 
#+ FullyQualifiedErrorId : EmptyPipeElement 
#I'll bang around on this but if you know off the top of your head what the issue is that'd be greats :-) 
#vstarmanv
#New Member
#
#Posts:17
#09 Feb 2011 03:19 PM
#i think back-tip(`) make a error.
#For convenience of viewing,  i use back-tip.
#but actuallly 3 line is one sentence
# 
#so execute like that ..
#$query = Invoke-Sqlcmd -Query "select top 1 * from SMSDB WHERE LoginID = $id"  | ft{$_.NetBIOS, $_.LoginTime}  | out-file -filepath "C:\test.txt" -encoding utf8 -append
#or 
#don't make a blank next of back-tip(`)
#$query = Invoke-Sqlcmd -Query "select top 1 * from SMSDB WHERE LoginID = $id" `
# | ft{$_.NetBIOS, $_.LoginTime} `
#  | out-file -filepath "C:\test.txt" -encoding utf8 -append 
#mqh7
#New Member
#
#Posts:9
#15 Feb 2011 11:44 AM
#Hello. I ran this script and I get this error now. 
#The term 'Invoke-Sqlcmd' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again. 
#At C:\Tools\PowerShell\Try3.ps1:1 char:23 
#+ $query = Invoke-Sqlcmd <<<< -Query "select top 1 * from SMSDB WHERE LoginID 
#= $id" | ft{$_.NetBIOS, $_.LoginTime} | out-file -filepath "C:\temp\test.txt" 
#-encoding utf8 -append 
#+ CategoryInfo : ObjectNotFound: (Invoke-Sqlcmd:String) [], Comma 
#ndNotFoundException 
#+ FullyQualifiedErrorId : CommandNotFoundException 
#PS C:\Windows\system32>
#vstarmanv
#New Member
#
#Posts:17
#15 Feb 2011 07:04 PM
#i think that  "Add-PSSnapin SqlServerCmdletSnapin100" is failed, 
#so  'Invoke-Sqlcmd' is not recognized.
#please check out whether you can load sql snapin
#if you can load sql snapin, you will see result list of 
#"get-pssnapin -registered"
#vstarmanv
#New Member
#
#Posts:17
#15 Feb 2011 07:16 PM
#if mssql installed your pc that execute powershell, you can find snapin. 
#but you can't find ...
#http://www.vistax64.com/powershell/...alled.html
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Execute a Powershell script using a DML Trigger or Stored Procedure
#Last Post 04 Jan 2011 05:54 PM by Rob Burgess. 2 Replies.
#AuthorMessages
#Rob Burgess
#New Member
#
#Posts:44
#04 Jan 2011 04:26 PM
#Hi
#Is there a way to execute a Powershell script using a DML Trigger or Stored Procedure in SQL Server 2008?
#Chad Miller
#Basic Member
#
#Posts:198
#04 Jan 2011 05:39 PM
#If you mean executing a PowerShell script from a calling trigger or stored procedure, its possible but a bit of a hack using xp_cmdshell. I have a blog post about it here:
#http://sev17.com/2010/11/executing-...ver-redux/
#Using something like SQL CLR isn't an option since hosting the System.ManagementAutomation PowerShell classes in SQL CLR isn't supported.
#Rob Burgess
#New Member
#
#Posts:44
#04 Jan 2011 05:54 PM
#Thanks Chad. That is exactly what I was looking for. 
#Rob
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Looking for help to have a self correcting function
#Last Post 29 Dec 2010 10:26 AM by DBArrrr. 1 Replies.
#AuthorMessages
#Plainweasel
#New Member
#
#Posts:1
#29 Dec 2010 07:47 AM
#Hi, i'm new to the community and powershell scripting.  I recently created a script that does a few DB queries and logs the information.  the problem i see in the future with this script is that its not self correcting if the DB im pointing two fails over to the server.  Bascially we have 2 servers with the same DB mirroring, and i just need help with a function that will check with DB is active one and save that as a variable i can use.
#My function for connecting to the sql servers is 
#function query-sql {
#    param ($SqlServer, $SqlCatalog, $SqlQuery)
#        $conn = New-Object system.Data.SqlClient.SqlConnection
#        $conn.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True"
#        $conn.Open()
#        $cmd1 = New-Object System.Data.SqlClient.Sqlcommand
#        $cmd1.connection = $conn
#        $cmd1.CommandText = $SqlQuery
#        $data = $cmd1.ExecuteReader()
#        $dt = New-Object System.data.datatable
#        $dt.Load($data)
#        $dt | Format-Table -Autosize
#        $conn.Close()
#        }
#Thank you in advanced.
#DBArrrr
#New Member
#
#Posts:1
#29 Dec 2010 10:26 AM
#If this is regular sql server database mirroring, i think you should be able to use "failover partner=$failoversqlserver" in the connectionstring
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How to compare SQL Server Table list with Windows SVN table list?
#Last Post 24 Dec 2010 03:31 AM by Asaf. 2 Replies.
#AuthorMessages
#Asaf
#New Member
#
#Posts:4
#23 Dec 2010 02:35 AM
#Hi All,
#Let me describe the scenario so that each of you follows what I am trying to each. We use source control solution that requires each of the SQL Server objects, such as tables, needs to be scripted out in designated folder in its individual file. For example, table dbo.Subscriber would be scripted out in C:\SVN\Tables directory with a name of the file as dbo.Subscriber.sql. 
#What I need to know is if all SQL tables have been actually scripted out and they are present in SVN directory. To automate this check I am trying to use the following powershell script from SQL Server 2008 Powershell utility;
#$SqlList = invoke-Sqlcmd -Query "SELECT Table_Schema + '.' + Table_Name + '.sql' AS Name FROM INFORMATION_SCHEMA.Tables WHERE Table_Type = 'Base Table' ORDER BY Table_Schema, Table_Name" 
#$SvnList = Get-ChildItem -Path C:\SVN\Tables | Sort-Object Name | Format-Table Name 
#Compare-Object -ReferenceObject $SqlList -DifferenceObject $SvnList
#What I need to get is a name of tables that exist in SQL Server but missing from SVN/Tables directory.
#Any help would be appreciated.
#Thanks,
#Asaf
#0ptikGhost
#Basic Member
#
#Posts:369
#23 Dec 2010 10:09 AMAccepted Answer 
#$sqlTables = Invoke-Sqlcmd -Database DatabaseName -Query "SELECT Table_Schema + '.' + Table_Name AS Name FROM INFORMATION_SCHEMA.Tables WHERE Table_Type = 'Base Table' ORDER BY Table_Schema, Table_Name" | Select-Object -ExpandProperty Name $svnTables = Get-Item -Path C:\SVN\Tables\*.sql | Select-Object -ExpandProperty BaseName | Sort-Object Compare-Object -ReferenceObject $sqlTables -DifferenceObject $svnTables | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject
#Blog - http://0ptikghost.blogspot.com 
#Asaf
#New Member
#
#Posts:4
#24 Dec 2010 03:31 AM
#Marvellous 0ptikGhost. It does exactly what I needed.
#Thanks a million.
#Asaf
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Update SQL table
#Last Post 29 Nov 2010 03:39 PM by Chad Miller. 13 Replies.
#AuthorMessages
#Berki
#New Member
#
#Posts:23
#08 Nov 2010 06:31 AM
#Hi,
#I'm trying to write a powershell script that retrieves a list of server names from a table then queries various WMI objects on each of the server before updating the table.
#I've managed to read in the list of servers and can obtain, for example, the memory type but I want it to check the value and based on the value write a specific value back to the original table.
#The script I created so far is:
## Create SqlConnection object and define connection string cls
#$con = New-Object System.Data.SqlClient.SqlConnection
#$con.ConnectionString = "Server=My_Server; Database=My_Database; Integrated Security=true;"
## Create SqlCommand object, define command text, and set the connection
#$cmd = New-Object System.Data.SqlClient.SqlCommand
#$cmd.CommandText = "SELECT serverName FROM servers"
#$cmd.Connection = $con
## Create SqlDataAdapter object and set the command
## The SQLDataAdapter is used instead of the SQLDataReader so that the data can be written back not just read from
#$da = New-Object System.Data.SqlClient.SqlDataAdapter
#$da.SelectCommand = $cmd
## Create and fill the DataSet object
#$ds = New-Object System.Data.DataSet
#$da.Fill($ds, "serverName") | Out-Null
## Get the memory type for each server 
#ForEach ($server in $ds.tables["Servername"].rows) {
#$serverName = Write-Output $server | foreach {$_.serverName}
#try{
#$colItems = Get-WmiObject Win32_PhysicalMemory -Namespace "root\CIMV2" -Computername $serverName -ErrorAction "Stop" | Select-Object MemoryType -Unique | foreach {$_.MemoryType}
#foreach($objItem in $colItems) {
#                if ($objItem = '0' ) {
#                Write-host $serverName "Memory Type: Unknown"
#                }
#                ELSEIF ($objItem = '1' ) {
#                Write-host $serverName "Memory Type: Other"     
#                }
#                ELSEIF ($objItem = '2' ) {
#                Write-host $serverName "Memory Type: DRAM"     
#                }
#                ELSEIF ($objItem = '3' ) {
#                Write-host $serverName "Memory Type: Synchronous DRAM"     
#                }
#                ELSEIF ($objItem = '4' ) {
#                Write-host $serverName "Memory Type: Cache DRAM"     
#                }
#                ELSEIF ($objItem = '5' ) {
#                Write-host $serverName "Memory Type: EDO"     
#                }
#                ELSEIF ($objItem = '6' ) {
#                Write-host $serverName "Memory Type: EDRAM"     
#                }
#                ELSEIF ($objItem = '7' ) {
#                Write-host $serverName "Memory Type: VRAM"     
#                }
#                ELSEIF ($objItem = '8' ) {
#                Write-host $serverName "Memory Type: SRAM"     
#                }
#                ELSEIF ($objItem = '9' ) {
#                Write-host $serverName "Memory Type: RAM"     
#                }
#                ELSEIF ($objItem = '10' ) {
#                Write-host $serverName "Memory Type: ROM"     
#                }
#                ELSEIF ($objItem = '11' ) {
#                Write-host $serverName "Memory Type: Flash"     
#                }
#                ELSEIF ($objItem = '12' ) {
#                Write-host $serverName "Memory Type: EEPROM"     
#                }
#                ELSEIF ($objItem = '13' ) {
#                Write-host $serverName "Memory Type: FEPROM"     
#                }
#                ELSEIF ($objItem = '14' ) {
#                Write-host $serverName "Memory Type: EPROM"     
#                }
#                ELSEIF ($objItem = '15' ) {
#                Write-host $serverName "Memory Type: CDRAM"     
#                }
#                ELSEIF ($objItem = '16' ) {
#                Write-host $serverName "Memory Type: 3DRAM"     
#                }
#                ELSEIF ($objItem = '17' ) {
#                Write-host $serverName "Memory Type: SDRAM"     
#                }
#                ELSEIF ($objItem = '18' ) {
#                Write-host $serverName "Memory Type: SGRAM"     
#                }
#                ELSEIF ($objItem = '19' ) {
#                Write-host $serverName "Memory Type: RDRAM"     
#                }
#                ELSEIF ($objItem = '20' ) {
#                Write-host $serverName "Memory Type: DDR"     
#                }
#                ELSEIF ($objItem = '21' ) {
#                Write-host $serverName "Memory Type: DDR-2"     
#                }
#                ELSEIF ($objItem = '22' ) {
#                Write-host $serverName "Memory Type: DDR-3"     
#                }
#}
#}
#catch {
#write-host "Can not connect to" $serverName}
#}
## Close the connection
#$con.close()
#Any idea's?
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#08 Nov 2010 12:54 PM
#If you have table named servers with a primary key defined and a column for memoryType, this works:
##CREATE TABLE servers            
##(            
##	serverName varchar(50) NOT NULL,            
##	memoryType int NULL,            
##    CONSTRAINT PK_servers PRIMARY KEY CLUSTERED             
##    (serverName)            
##)            
#            
#$serverName = "$env:computername\sql2k8"            
#$databaseName = "dbautility"            
#$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter            
#$query = 'select * from servers'            
#$connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"            
#$dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)            
#$commandBuilder = new-object System.Data.SqlClient.SqlCommandBuilder $dataAdapter            
#$dt = New-Object System.Data.DataTable            
#[void]$dataAdapter.fill($dt)            
#$dt | foreach { [int32]$memoryType = $(Get-WmiObject Win32_PhysicalMemory -computername $_.serverName | select -ExpandProperty MemoryType -Unique); $_.MemoryType = $memoryType }             
#$dataAdapter.Update($dt)            
#Berki
#New Member
#
#Posts:23
#09 Nov 2010 01:32 AM
#Thanks cmille19, this works however is it possible nestle IfElse statements within the query?
#Chad Miller
#Basic Member
#
#Posts:198
#09 Nov 2010 03:56 AM
#Sure, but based on the sample data you provided, it would be easier/cleaner to use an array:
##CREATE TABLE servers                        #(                        #	serverName varchar(50) NOT NULL,                        #	memoryType int NULL,                        #    CONSTRAINT PK_servers PRIMARY KEY CLUSTERED                         #    (serverName)                        #)                        $map = @('Unknown','Other','DRAM','Synchronous DRAM','Synchronous DRAM')                        $serverName = "$env:computername\sql2k8"                        $databaseName = "dbautility"                        $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter                        $query = 'select * from servers'                        $connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"                        $dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)                        $commandBuilder = new-object System.Data.SqlClient.SqlCommandBuilder $dataAdapter                        $dt = New-Object System.Data.DataTable                        [void]$dataAdapter.fill($dt)                        $dt | foreach { [int32]$memoryType = $(Get-WmiObject Win32_PhysicalMemory -computername $_.serverName | select -ExpandProperty MemoryType -Unique); $_.MemoryType = $map[$memoryType] }                         $dataAdapter.Update($dt)
#Berki
#New Member
#
#Posts:23
#09 Nov 2010 05:53 AM
#That's brilliant, last query, some of the servers are unix servers, is it possible to try to connect to WMI if possible collect WMI data otherwise don't make any changes?
#Chad Miller
#Basic Member
#
#Posts:198
#09 Nov 2010 08:36 AM
#If you know some servers are Unix then you could filter them in your select query i.e. select * from servers where serverType = 'Windows' 
#You could also add a check for the $memoryType not null before setting. 
#if ($memoryType) {$_.MemoryType = $map[$memoryType]}
#Berki
#New Member
#
#Posts:23
#10 Nov 2010 03:08 AM
#Thanks cmille19 but I'm not sure where to put the
#if ($memoryType) {$_.MemoryType = $map[$memoryType]}
#check in the original script?
#Chad Miller
#Basic Member
#
#Posts:198
#10 Nov 2010 07:41 AM
#dt | foreach { [int32]$memoryType = $(Get-WmiObject Win32_PhysicalMemory -computername $_.serverName | select -ExpandProperty MemoryType -Unique); if ($memoryType) {$_.MemoryType = $map[$memoryType]} }
#Berki
#New Member
#
#Posts:23
#29 Nov 2010 08:30 AM
#Thanks cmile 19 this works perfectly however when I'm querying the network cards for the IP Address it returns system.string[]. 
#The query I have is 
#dt | foreach { [string]$NetworkCards = $(Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -computername $_.serverName | Select-Object ipaddress,macaddress -ExcludeProperty IPX*,WINS); if ($NetworkCards) {$_.NetworkCards = $NetworkCards }}
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2010 09:37 AM
#This is because your networkcards example is returning two properties while your memory type returns only one. Do you want just the IPAddress, a concatenated field with both IP Address and MACAddress or do you have separate columns in your SQL Server table to hold the IP and MAC?
#Berki
#New Member
#
#Posts:23
#29 Nov 2010 10:34 AM
#I'd like it concantenated with the MAC address
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2010 10:47 AM
#Try this: 
#[string]$NetworkCards = $(Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -computername $_.serverName | Select-Object @{n='NetworkCards';e={"{0}--{1}" -f $($_.IPAddress),$($_.MACAddress)}} | Select -ExpandProperty NetworkCards)
#Berki
#New Member
#
#Posts:23
#29 Nov 2010 02:20 PM
#The IPAddress and the MAC Adress are joined but the IP address does not resolve. 
#I get System.Object[]--00:00:00:
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2010 03:39 PM
#Worked fine on my Vista machine. I ran the statement on my Windows 7 machine and noticed an IPV4 and IPV6 IP address being returned hence the System.Object[] array. 
#You can use the -join operator to concatenate the IPs: 
#Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE computername $_.serverName | Select-Object @{n='NetworkCards';e={"{0}--{1}" -f $($_.IPAddress -join ';').ToString(),$($_.MACAddress)}} | Select -ExpandProperty NetworkCards
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#insert space to text file
#Last Post 29 Nov 2010 09:24 AM by sza. 11 Replies.
#AuthorMessages
#tran008
#New Member
#
#Posts:8
#06 Jul 2010 09:31 AM
#Hi,
#I'm having problems importing a text file. There are no column delimiters in the file. It has the following data:
#AcctNo
#Street1
#Street2
#City
#State
#Zip
#because some of the row may or may not fill up to 350 character, I need the powershell script to update the text file with rows that does not have 350 in length 
#with trailing space to make all the row with 350 character in lenght.
#thanks
#Chad Miller
#Basic Member
#
#Posts:198
#06 Jul 2010 11:12 AM
#Can you explain the format of the incoming file in more detail? For example is a row a complete address with variable length: 
#acctNo Street1 Street2 City State Zip 
#OR is each item on separate line i.e. each item a separate row? 
#Also are any elements missing from some but not all records? For example will Street2 be present in every record? 
#Obviously it would be easier to control the way the output is formatted from the source. Any chance you can have the file created a delimited?
#tran008
#New Member
#
#Posts:8
#06 Jul 2010 06:33 PM
#This is a row with complete address with variable length. I'm not worried about the missing elements, but the lost of records. According to the vendor, there were certain amount of record data, but the import seem to be less. After searching, sqlis doesn;t seem to like null value, and seem to overlap the records. I could import as 1 row column into the sql, and split afterward...and I'm kinda heading to that direction.
#Chad Miller
#Basic Member
#
#Posts:198
#06 Jul 2010 06:57 PM
#Is your end goal to split each field (acctno, Street, etc.) into its own column? Or do you simply want to pad a 350 character length address with spaces i.e. meaning total address is within 350 characters?
#tran008
#New Member
#
#Posts:8
#07 Jul 2010 05:01 AM
#The end goal is to split each field out. However I need to have all correct number of record count from the vendor. I was looking at this http://agilebi.com/cs/blogs/jwelch/...umns.aspx, and gave me some idea. However this article based on the comma delimiter. The reason I want to fill the space in at the end that I have a small test text file, and insert the correct space in at the end, I was able to load in with ragged right format.
#Chad Miller
#Basic Member
#
#Posts:198
#07 Jul 2010 07:11 AM
#Splitting based on space would seem unreliable for addresses. If all you want to do is pad a full line (record) you can call the padright method 
#get-content ./myfile.txt | foreach-object {$_.padright(350)} 
#If you want split each record/line on space you can something like this in PowerShell 2.0: 
#get-content ./myfile.txt | foreach-object {$_ -split "\s"}
#tran008
#New Member
#
#Posts:8
#07 Jul 2010 08:06 AM
#Thank you very much, the Padright did the trick.
#sza
#New Member
#
#Posts:3
#29 Nov 2010 05:49 AM
#Hello, 
#Thank you in advance. I need to insert a space at the end of each line of a text file. I never use powershell before. I will appreciate if anybody can help me to solve this. From the Powershell command prompt I have executed the above mentioned suggestion: 
#get-content ./myfile.txt | foreach-object {$_.padright(350)} 
#It executed but did not insert a space. 
#Thanks again
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2010 06:56 AM
#Do you just want to insert a single space at the end of each line? If so, this command will insert a single space: 
#Get-Content .\myfile.txt | foreach {$_ -replace "$"," "}
#sza
#New Member
#
#Posts:3
#29 Nov 2010 07:33 AM
#Thanks cmille19. 
#I have copied and paste the above command and it executed smoothly but it did not put a space at the end of each line. Am I missing something? As I told, I am a newbie. 
#thanks
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2010 08:34 AM
#The above command just adds a single whitespace to each line of a text file. You'll need to send the output to a file or update the existing file: 
#Get-Content .\myfile.txt | foreach {$_ -replace "$"," "} >> mynewfile.txt 
#or update in place (be careful with this one make sure you really want to do this): 
#(Get-Content .\myfile.txt) | foreach {$_ -replace "$"," "} | Set-Content myfile.txt 
#To prove the whitespace is being added and since you can't see the whitespace in the console you could run something like this, which will add a dash to the end of each line: 
#Get-Content .\myfile.txt | foreach {$_ -replace "$","-"}
#sza
#New Member
#
#Posts:3
#29 Nov 2010 09:24 AM
#Hi cmille19, 
#Thanks a lot for helping me. Lot of things to know...............
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Manipulate the results returned from a SQL Query
#Last Post 19 Nov 2010 06:44 AM by Sam. 2 Replies.
#AuthorMessages
#Sam
#New Member
#
#Posts:6
#17 Nov 2010 10:38 AM
#Hello,
#A newbie here who is trying to query the SQL Server for its version information.
#$con = "server=$strSQLServerName;database=master;Integrated Security=sspi" 
#$cmd = "SELECT LEFT(@@VERSION, 26) AS '- Product Name', 
#              SERVERPROPERTY('Edition') AS '- Edition', 
#              SERVERPROPERTY('ProductVersion') AS '- Version', 
#              SERVERPROPERTY('ProductLevel') AS '- Patch Level'" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.DataTable
#$da.fill($dt) | out-null
#$dt | Format-List
#The Output looks like this:
#==================
#- Product Name : Microsoft SQL Server 2008 
#- Edition : Enterprise Edition (64-bit) 
#- Version : 10.0.2757.0 
#- Patch Level : SP1
#What I'd like to do is to store the values of each result item above into separate variables (4 variables to store 4 values returned) so that I can then apply some logic to it. Example, if the Patch Level value is SP1, then do something.
#Any help is appreciated.
#Thanks,
#Sam
#Chad Miller
#Basic Member
#
#Posts:198
#18 Nov 2010 05:01 PM
#You already have the values in "separate" variables by nature of being in a datatable: 
#$dt | gm 
#To reference each property use the foreach operator: 
#$dt | foreach {$_."- Product Name"} 
#You could also assign the property to another variable: 
#$dt | foreach {$product=$_."- Product Name"; $edition=$_."- Edition"}
#Sam
#New Member
#
#Posts:6
#19 Nov 2010 06:44 AM
#Thanks Chad, that worked like a charm :)
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#need help! automating cluster group failover for MS patching
#Last Post 28 Oct 2010 07:21 AM by SideOfBacon. 2 Replies.
#AuthorMessages
#SideOfBacon
#New Member
#
#Posts:5
#28 Oct 2010 05:47 AM
#I am writing a script to help with automating our weekend patches so that we are not forced to fail over cluster groups manually due to time constraints and making sure all instances are balanced back out on some 20 clusters we administer. I am trying to write a powershell script that will fail everything over to the last node in a configuration where the configuration is 2+ nodes. I also want/need the script to verify that the move was in fact successful and no failures were experienced during failover, and then automating a reboot of all nodes except last node. any assistance would be greatly appreciated. I have an extremely basic script using the available R2 cmdlets right now that only will failover to a 2nd node and then reboot, this has no confirmation of failover succeeding and also will not work for our 3+ node configurations. with over 300 servers to patch, and 20 some clusters, this will dramatically improve the turnaround time on patch management and no words to describe the gratitude if someone is able to assist me! ANY assistance is GREATLY GREATLY appreciated!
#halr9000
#PowerShell MVP, Site Admin
#Advanced Member
#
#Posts:565
#28 Oct 2010 06:05 AM
#If you are using 2008 R2, then check out the cluster cmdlets. http://technet.microsoft.com/en-us/...61009.aspx 
#Community Director, PowerShellCommunity.org
#Co-host, PowerScripting Podcast
#Author, TechProsaic
#SideOfBacon
#New Member
#
#Posts:5
#28 Oct 2010 07:21 AM
#I have used the cmdlets to do the basic script I have now that failover to desired nodes, but I want the script to be as automated as possible. 
#1. use Get-ClusterGroups and calculate the number of instances/groups running 
#2. fail over all ClusterGroups to last Node in cluster using some variation of Move-ClusterGroup -Node LASTNODE
#3. verify that the cluster succeeded by perhaps using the status found by the Get-ClusterGroups "Online" 
#4. automatically reboot all nodes but last node 
#my script currently just fails over to 2nd node and automatically reboots first node. but the nodes are defined in the script, and would like this automated, not hardcoded, so that it is easy configurable for the 20+ R2 clusters we currently administer and as we add nodes. 
#thanks again, everyone!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Getting CSV's into SQL Table
#Last Post 22 Oct 2010 10:28 AM by bluehat. 7 Replies.
#AuthorMessages
#bluehat
#New Member
#
#Posts:16
#19 Oct 2010 12:19 PM
#I have been using a lot of powershell recently for our Exchange environment which has lead me here to this community before.  So, I thought someone might be able to figure out the basics of what I am doing wrong.  I will try to be as clear as I can.  First off, I am using this website to get activesync information for our users.
#http://www.simple-talk.com/sysadmin...sync-logs/
#I installed SQL Express on machine just to get this thing to work.  I created the database, and the table with all the column headers.  I have run the command to pull all the IIS logs and rename them to...
#u_ex090116_Users.csv.  This is the file that the script below is calling on...
#I copied and pasted his script from the webpage.  But where it seems to get hung up is the data information. 
#Here is what he has..
# 
## Find all the Users.csv files and import them
#Get-ChildItem "C:\Temp\EASReports\*Users.csv" | ForEach {
#      # Get the date from the name of the file
#      $Date = ($_.Name).SubString(2,6)
#      $Year = "20" + $Date.SubString(0,2)
#      $Month = $Date.SubString(2,2)
#      $Day = $Date.SubString(4,2)
#      $Date = Get-Date -Year $Year -Month $Month -Day $Day -Hour 0 -Minute 0 -Second 0
#      
#      # Import the CSV file
#      $CSVFile = Import-Csv $_
# 
#      # Get the column names from the first line of the CSV file 
#      $CSVFileProperties = Get-Content "$_" -totalcount 1 | % {$_.split(",")}
# 
#      # Loop through each entry in the CSV file
#      ForEach ($Entry in $CSVFile) {
# 
#            # Ignore lines with an empty Device ID
#            If ($Entry."Device ID" -ne "") {
#                  # Construct the SQL insert statement
#                  $SQLString = "INSERT INTO Users ("
#                  Foreach ($Prop in $CSVFileProperties) {
#                        $SQLString = $SQLString + "[$Prop],"
#                  }
#                  
#                  $SQLString = $SQLString + "[Date]) VALUES ("
#                  
#                  Foreach ($Prop in $CSVFileProperties) {
#                        $SQLString = $SQLString + "'" + $Entry."$Prop" + "',"
#                  }
#      
#                  $SQLString = $SQLString + "'$Date')"
#                  
#                  # Add the record to the database
#                  $null = $objConnection.Execute($SQLString)
#            }
# 
#      }
#}
#And here is what I get..
#Get-Date : Cannot bind parameter 'Year'. Cannot convert value "20ex" to type "System.Int32". Error: "Input string w
#as not in a correct format."
#At line:10 char:29
#+       $Date = Get-Date -Year <<<<  $Year -Month $Month -Day $Day -Hour 0 -Minute 0 -Second 0
#    + CategoryInfo          : InvalidArgument: (:) [Get-Date], ParameterBindingException
#    + FullyQualifiedErrorId : CannotConvertArgumentNoMessage,Microsoft.PowerShell.Commands.GetDateCommand
#Any ideas where the code is faltering?
#Chad Miller
#Basic Member
#
#Posts:198
#19 Oct 2010 01:58 PM
#The script author is deriving the date by parsing the file name. His file name format is different than yours. The problem and solution:
##This fails            
#$name = 'u_ex090116_Users.csv'            
#$Date = ($Name).SubString(2,6)            
#$Year = "20" + $Date.SubString(0,2)            
#$Month = $Date.SubString(2,2)            
#$Day = $Date.SubString(4,2)            
#$Date            
##Returns this ex0901            
#$Date = Get-Date -Year $Year -Month $Month -Day $Day -Hour 0 -Minute 0 -Second 0            
#            
##This works            
#$name = 'ex080901_Users.csv'            
#$Date = ($Name).SubString(2,6)            
#$Year = "20" + $Date.SubString(0,2)            
#$Month = $Date.SubString(2,2)            
#$Day = $Date.SubString(4,2)            
#$Date            
##Returns this 080901            
#$Date = Get-Date -Year $Year -Month $Month -Day $Day -Hour 0 -Minute 0 -Second 0
#bluehat
#New Member
#
#Posts:16
#19 Oct 2010 02:31 PM
#ok, well that makes sense I guess. So now I need to figure out how to rename all 3500 log files to get rid of the u_ at the beginning of the file name. Shouldn't be too tough. Is there something I need to change in the year value as it is erroring and saying that the value "20ex" cannot be converted to "System.INT32". 
#Is there a way to just rename every single file to get rid of the u_ex at the beginning? It seems to just be screwing things up.
#Chad Miller
#Basic Member
#
#Posts:198
#19 Oct 2010 05:42 PM
#The reason the year value is erroring is because your file name pattern has extra u_, so the substring is off. Of course you can use PowerShell to rename the files: 
#get-childItem *.csv | rename-item -newname { $_.name -replace 'u_' }
#seaJhawk
#Basic Member
#
#Posts:191
#19 Oct 2010 09:33 PM
#Instead of renaming the files, you could just change the part of the script that reads the file name from: 
#$Date = ($Name).SubString(2,6) 
#to 
#$Date = ($Name).SubString(4,8) 
#-Chris
#bluehat
#New Member
#
#Posts:16
#20 Oct 2010 09:22 AM
#So you may be wondering why I posted in the SQL Server Forum....well, the start of my problems came from trying to connect to my own SQL server on my desktop to even get this script started.  Since this whole thing requires a sql database to then be connected to EXcel to make these pretty graphs I figured I could just download SQL EXpress on my desktop and I would be fine.  
#So I set everything up and am using windows Authentication to connect to the databases.  But, with my script, it doesn't seem to like the fast that I am using SQL express since it refuses to connect.  I have spent the better part of yesterday and this morning trying different configurations with my username, password, db names but still haven't been able to get the script to run and authenticate to open a connection.  Here is what I have so far.  
## Set up the parameters for connecting to the SQL database
#$dbserver = "computername\SQLEXPRESS" ( I tried this wish (local)
#$dbname = "EASReports"
#$dbuser = "my login" (deleted this a time or two )
#$dbpass = "my password" (deleted this a time or two ) 
## Create the ADO database object
#$objConnection = New-Object -comobject ADODB.Connection
## Open the database connection
#$objConnection.Open("PROVIDER=SQLOLEDB;DATA SOURCE=$dbserver;UID=$dbuser;PWD=$dbpass;DATABASE=$dbname")
#I continue to get Login failed for user. Is there a specific syntax I need to use for windows authentication against a SQL server?  I can log into the management studio without issue using my windows creds but I can't login using "sa" for instance.  Dont' know if that is an issue.
#Chad Miller
#Basic Member
#
#Posts:198
#20 Oct 2010 10:57 AM
#To use Windows authentication: 
#$objConnection.Open("Provider=SQLOLEDB;Server=$ENV:computername\SQLEXPRESS;Database=$dbname;Trusted_Connection=yes;") 
#Your SQLEXPRESS may be confirmed to use Windows Only authentication. Also you have computername instead of $env:computername. You can change the to Windows and SQL Authentication by right clicking SQL Server in SQL Server Management Studio >> Selecting Security table and clicking Windows and SQL Authentication. Then restart SQL.
#bluehat
#New Member
#
#Posts:16
#22 Oct 2010 10:28 AM
#I just wanted to write back to say all is well with the world.  The changes you guys suggested worked great and I was able to modify the code based on your posts to get it all to work perfectly.  Thank you very much.  You all do a great service to the community.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL service tracking
#Last Post 19 Oct 2010 08:35 AM by Chad Miller. 1 Replies.
#AuthorMessages
#IMark
#New Member
#
#Posts:1
#19 Oct 2010 08:01 AM
#I am trying to monitor ALL SQL services on every server. I have a hard coded list of servers in a file and it the script works ok in version 1.0. I add the AND section to the script and it fails. 
# 
#Version 1.0   gwmi win32_service -comp (gc servers.txt) -filter "name like '%sql%' " | select __server,name,startmode,state,status
#Version 1.1   gwmi win32_service -comp (gc servers.txt) -filter "name like '%sql%' and state -eq 'stopped'" | select __server,name,startmode,state,status
# 
# 
#Also I would like to add the output to an email if I find any services not running. 
# 
# 
# 
# 
#Chad Miller
#Basic Member
#
#Posts:198
#19 Oct 2010 08:35 AM
#The filter parameter uses a WMI Query Language (WQL) syntax instead of the PowerShell syntax, so -eq should be = as follows: 
#gwmi win32_service -filter "name like '%sql%' and state = 'stopped'" 
#Note: this is explained in get-help get-wmiobject 
#For sending a mail message take a look at the PowerShell V2 cmdlet Send-MailMessage (get-help send-mailmessage -full).
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Why can´t I do a sql update while reading?
#Last Post 17 Oct 2010 12:50 PM by sirampersand. 2 Replies.
#AuthorMessages
#sirampersand
#New Member
#
#Posts:25
#14 Oct 2010 05:02 AM
#Hello,
#Why can´t I do a sql update while reading?
#The error (translated by me into english) is like that:
#Exeption calling "ExecuteScalar" with "0" argument(s): "This Command is allready assigned to a open DataReader, which must be closed first." At C:\ps\hosts\db\db_test.ps1:40 char:25 + $cmd_1.ExecuteScalar <<<< () + CategoryInfo : NotSpecified: (:) [], MethodInvocationException + FullyQualifiedErrorId : DotNetMethodException I need to run throug all entrys, check them and update the row... 
#$PROVIDER = "System.Data.SqlClient" $CONNSTRING ="Data Source=ntsx1\iximixi; Database=mysupport2;User Id=ssc;Password=SSCRun07!" $provider = [System.Data.Common.DbProviderFactories]::GetFactory($PROVIDER) $conn = $provider.CreateConnection() $conn.ConnectionString = $CONNSTRING $conn.Open(); $SQL2 = "select * from atool_hosts order by ip_addr" [System.Data.Common.DbCommand] $cmd1 = $provider.CreateCommand() $cmd1.CommandText = $SQL2 $cmd1.Connection = $conn $reader = $cmd1.ExecuteReader() while($reader.Read()) { if ($reader.Item("ip_addr") -eq "172.20.180.0") { echo $reader.Item("ip_addr") } $SQL_1 = "UPDATE $table_name SET last_ping='I wana test it' WHERE ip_addr = '172.20.180.0'" [System.Data.Common.DbCommand] $cmd_1 = $provider.CreateCommand() $cmd_1.CommandText = $SQL_1 $cmd_1.Connection = $conn $cmd_1.ExecuteScalar() } 
#thanks for any help ampersand
#Chad Miller
#Basic Member
#
#Posts:198
#15 Oct 2010 04:16 AM
#If you're going to update a data set don't use a reader. Here's an example that updates a datatable and then called the update method, you'll need to adapt this example to your code:
#  
#    
#$serverName = "Z003\R2"            
#   $databaseName = "Northwind"            
#  $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter            
#   $query = 'select * from Customers'            
#  $connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"            
#    $dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)            
#    $commandBuilder = new-object System.Data.SqlClient.SqlCommandBuilder $dataAdapter            
#    $dt = New-Object System.Data.DataTable            
#    [void]$dataAdapter.fill($dt)            
#    $dt | where {$_.CompanyName -eq 'Wolski  Zajazd'} | foreach {$_.CompanyName = 'Zajazd  Wolski'}            
#    $dataAdapter.Update($dt)            
#sirampersand
#New Member
#
#Posts:25
#17 Oct 2010 12:50 PM
#cmile19,
#Thanks, Thanks,Thanks!  You helped me solving my problem!
#The data set and data row and dataadapter thing seems quiet complex to me because I didn´t found much good examples and explainations on the web.
#anyway, I´m happy for the moment, hoping to get deeper into it after a while.
#cheers 
#ampersand
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Remote SQL Install
#Last Post 12 Oct 2010 11:40 AM by Chad Miller. 3 Replies.
#AuthorMessages
#Sean Davis
#New Member
#
#Posts:2
#05 Oct 2010 06:02 PM
#I wrote a script that provisions all of servers using the PSSession Remoting. The only install I seem to have problems with is when I try to do a remote install of MSSQL Server 2008 R2 with files local to the remote box. This is on AD Domain. I have ran the script local and it installs beautifully but when I install remotely I always get a failure mentioning something about access is denied the account or user trying to install must have delgation rights. Any suggestions. I don't want to have to create service accounts or assign SPN's etc. And I have set the credentials and Start-Process for both domain and local server credentials still to no avail.
#Chad Miller
#Basic Member
#
#Posts:198
#12 Oct 2010 04:43 AM
#I haven't tried this myself, but I've seen other posts reporting the same issue which makes me question whether using PS remoting to install software is a good use case of remoting. My feeling is that it isn't and other technologies are better suited for software deployment (SCCM, LanDesk, Altiris, etc.)
#Sean Davis
#New Member
#
#Posts:2
#12 Oct 2010 08:35 AM
#For business reasons all provisioning is written in house and is currently a combination of vb script and batch lol. So I figured powershell would be a much better choice.
#Chad Miller
#Basic Member
#
#Posts:198
#12 Oct 2010 11:40 AM
#I would agree Powershell is a better choice over Vbscript, however I'm not convinced using PS remoting to install complex S/W is a good use case for Powershell.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Backup SQL database and overwrite all existing backup sets
#Last Post 12 Oct 2010 04:35 AM by Chad Miller. 1 Replies.
#AuthorMessages
#Rob Burgess
#New Member
#
#Posts:44
#11 Oct 2010 11:33 AM
#Hi
#I found a script that performs a backup of a single SQL Server 2008 Express database but I'm not sure where to add the switch to 'overwrite all existing backup sets'.
#Here is the script care of Donabel Santos :
##============================================================
## Backup a Database using PowerShell and SQL Server SMO
## Script below creates a full backup
## Donabel Santos
##============================================================
##specify database to backup
##ideally this will be an argument you pass in when you run
##this script, but let's simplify for now
#$dbToBackup = "test"
##clear screen
#cls
##load assemblies
##note need to load SqlServer.SmoExtended to use SMO backup in SQL Server 2008
##otherwise may get this error
##Cannot find type [Microsoft.SqlServer.Management.Smo.Backup]: make sure
##the assembly containing this type is loaded.
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
##Need SmoExtended for smo.backup
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
##create a new server object
#$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") "(local)"
#$backupDirectory = $server.Settings.BackupDirectory
##display default backup directory
#"Default Backup Directory: " + $backupDirectory
#$db = $server.Databases[$dbToBackup]
#$dbName = $db.Name
#$timestamp = Get-Date -format yyyyMMddHHmmss
#$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
##BackupActionType specifies the type of backup.
##Options are Database, Files, Log
##This belongs in Microsoft.SqlServer.SmoExtended assembly
#$smoBackup.Action = "Database"
#$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
#$smoBackup.BackupSetName = $dbName + " Backup"
#$smoBackup.Database = $dbName
#$smoBackup.MediaDescription = "Disk"
#$smoBackup.Devices.AddDevice($backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak", "File")
#$smoBackup.SqlBackup($server)
##let's confirm, let's list list all backup files
#$directory = Get-ChildItem $backupDirectory
##list only files that end in .bak, assuming this is your convention for all backup files
#$backupFilesList = $directory | where {$_.extension -eq ".bak"}
#$backupFilesList | Format-Table Name, LastWriteTime
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#12 Oct 2010 04:35 AM
#Set the initialize property to true. This can be done anytime before the call SQLBackup method, but after the creation of the SMO.BACKUP object: 
#$smoBackup.Action = "Database" 
#$smoBackup.Initialize = $true 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Select child items based on a database table list
#Last Post 27 Sep 2010 11:16 AM by Chad Miller. 1 Replies.
#AuthorMessages
#schwizla
#New Member
#
#Posts:1
#23 Sep 2010 08:46 AM
#Probably an easy one for you gurus out there but this is stumping a newbie like me :-(
#I have a table with a List of stored Procedure names
#I would like to script out the stored procedures in a database where the name of the Stored proc matches a name on my table list
#This works for me to list my stored procs that I want to filter on
#Invoke-sqlcmd -Query "Select name from tempdatabase.dbo.temp"
#And the following below works to script out ALL the stored procs from my database
## Navigate to the directory 
## PS SQLSERVER:\SQL\TESTSERVER\DEFAULT\Databases\tempdatabase\StoredProcedures> 
#gci | %{$Proc = $_.Name; $_.script() | out-file -filepath D:\temp\$Proc.sql}
#How can I utilse the get-childitem to filter on the query and script out only the procs that match the table list?
#Thanks in advance
#Chad Miller
#Basic Member
#
#Posts:198
#27 Sep 2010 11:16 AM
#This question was also asked in answered in the MS Windows PowerShell forum:
#http://social.technet.microsoft.com...4b0bb0bc0f
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How does a PowerShell SQL Server Agent Step signal failure?
#Last Post 01 Sep 2010 05:12 PM by Chad Miller. 1 Replies.
#AuthorMessages
#Don DeCosta
#New Member
#
#Posts:2
#01 Sep 2010 11:10 AM
#As a simple example, let's say I'm using a PowerShell Step in a SQL Sever Agent job to check for the existence of a file.
#If the file does not exist, how does the PowerShell Step signal to the Agent Job that the step failed so that Agent can retry the step according to the step's settings?
#I could just let PowerShell loop and sleep until the file arrives but I want to use SQL Agent as it was intended and have it handle failure and success and retries and continue to this step on success or that step on failure, etc.
#Chad Miller
#Basic Member
#
#Posts:198
#01 Sep 2010 05:12 PM
#A throw will cause the job step to fail. In fact any exception which isn't handled will. See this post on Server Fault: Post
#if (!(test-path c:\myfolder\myfile.txt))
#{ throw 'file does not exist'}
#I would probably go with a cmdexec (Operating System) job step and call regular PowerShell.exe, then use 
#System.IO.FileSystemWatcher + Register-ObjectEvent + Wait-Event rather than rely on Agent.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Query SQL for 2 tables then merge info into Get-QADUser csv
#Last Post 30 Aug 2010 02:52 PM by Chad Miller. 1 Replies.
#AuthorMessages
#MG2
#New Member
#
#Posts:1
#30 Aug 2010 08:47 AM
#Hello,
#I have two issues. In SQL we have active and inactive customer numbers associated with a code. In AD we have only active customer numbers with address information. My goal is to export the customer number and address information from AD then somehow merge that data with the SQL code information for active stores only. ie: Get-qaduser customer number etc.. then, if the number exists in the sql database, get the code.
#1) How to query SQL for customer number and code to a text or csv file?
#2) Once I have the SQL text file, how can merge the data into my foreach statement block?
#Thank you,
#MG2
#Chad Miller
#Basic Member
#
#Posts:198
#30 Aug 2010 02:52 PM
#You may want to consider an alternate approach of importing the AD information into SQL Server. One way to do so: 
#Create a table to hold AD data in SQL Server: 
#Create table qaduser_fill 
#( 
#samid varchar(255), 
#customerNum varchar(255) 
#) 
##Get AD info: 
#get-qaduser | select NTAccountName, customerNumber | export-csv -noTypeInfo ./qaduser.csv 
##Cleanup CSV file for import into SQL Server by removing double quotes 
#(Get-Content C:\Users\Public\qaduser.csvv) | foreach {$_ -replace '"'} | Set-Content C:\Users\Public\qaduser.csv 
#Define query to import data: 
#$query = @" 
#BULK INSERT mydatabaseName.dbo.qaduser_fill FROM 'C:\Users\Public\qaduser.csv' 
#WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n') 
#"@ 
#Execute query using Invoke-SqlCmd or Invoke-Sqlcmd2: http://poshcode.org/1791 
#Invoke-SqlCmd2 -ServerInstance "WIN2K8R2\SQL2K8" -Database mydatabaseName-Query $query 
#Use a standard SQL join to join the data: 
#SELECT * 
#FROM mydatabaseName.dbo.OrginalInfo o 
#JOIN qaduser_fill q ON 
#o.id = q.samid 
#You could use Invoke-Sqlcmd or Invoke-Sqlcmd2 to call the query in PowerShell 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Powershell -contains/-notcontains - having trouble with an array result from SQLServer
#Last Post 05 Aug 2010 02:14 PM by Chad Miller. 4 Replies.
#AuthorMessages
#mg48
#New Member
#
#Posts:26
#04 Aug 2010 01:01 PM
#I am using Invoke-SQLCmd to get a list of items that I want to process. In that list may be an item that indicates that the entire list needs to be bypassed. I have tried to figure out how to use the -contains and -notcontains operator but I am not having any luck. This would be the pseudo code: 
#$dont_process = "dont process" 
#$list = Invoke-SQLCmd ........ 
#if ($list -notcontains $dont_process) {processing goes here} 
#$list is a System.array of DataRows. The operator is supposed to work on an array but I guess an array of DataRows is not the kind it works on. Any help would be greatly appreciated.
#Chad Miller
#Basic Member
#
#Posts:198
#04 Aug 2010 03:33 PM
#Since $list is array of DataRows I would suggest using something like this: 
#if (!($list | where-object {$_.text -eq "dont process"})) {do stuff} 
#Note in this example text is the name of the SQL table column.
#mg48
#New Member
#
#Posts:26
#05 Aug 2010 04:31 AM
#Thanks - after I posted I continued searching and actually found an earlier post by you on technet. I was able to use that to complete this part of the script I am working on. I'll try this out also. 
#I case you're curious, this is what you posted in June: 
#$list = New-Object System.Collections.ArrayList 
#get-sqlcmd2 MyServer MyDatabase "Select X FROM Table Y" | foreach { [void]$list.Add($_.X) } 
#mg48
#New Member
#
#Posts:26
#05 Aug 2010 04:41 AM
#I I would like to mark this post as "Answered" or "Resolved" but haven't figured out how. Where do I do that?
#Chad Miller
#Basic Member
#
#Posts:198
#05 Aug 2010 02:14 PM
#That works too as they in Perl scripting There's More than One Way To Do It. 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Insert Free Disk Space into SQL table
#Last Post 04 Jul 2010 07:24 PM by MadHatter. 2 Replies.
#AuthorMessages
#MadHatter
#New Member
#
#Posts:6
#04 Jul 2010 01:39 AM
#Hello,
#I am new to powershell but would like to use it to insert into a SQL table the free diskspace available on a network path, I am using the following script:
#(new-object -com scripting.filesystemobject).getdrive("\\127.0.0.1\share").availablespace
#Could anyone tell me how I can accomplish this? The output of the above just returns the bytes free but that's all I would like to insert.
#Thanks in advance.
#Chad Miller
#Basic Member
#
#Posts:198
#04 Jul 2010 05:52 AM
#Single you are just returning a single value you could define a simple function for running SQL queries and insert the available space value into your table:
#function Invoke-Sqlcmd2 
#{                param(                [string]$ServerInstance,                [string]$Database,                [string]$Query,                [Int32]$QueryTimeout=30                )                            $conn=new-object System.Data.SqlClient.SQLConnection                $conn.ConnectionString="Server={0};Database={1};Integrated Security=True" -f $ServerInstance,$Database                $conn.Open()                $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn)                $cmd.CommandTimeout=$QueryTimeout                $ds=New-Object system.Data.DataSet                $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)                [void]$da.fill($ds)                $conn.Close()                $ds.Tables[0]                        }            $space = (new-object -com scripting.filesystemobject).getdrive("\\127.0.0.1\C`$").availablespace                        invoke-sqlcmd2 -ServerInstance Z002\SQL2K8 -Database spacedb -Query "INSERT driveSpace Values ('$space')"
#MadHatter
#New Member
#
#Posts:6
#04 Jul 2010 07:24 PM
#Thanks cmille19! This worked perfectly..
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Run T-SQL query based on output of another T-SQL query
#Last Post 21 Jun 2010 11:27 AM by Rob Burgess. 12 Replies.
#AuthorMessages
#Rob Burgess
#New Member
#
#Posts:44
#17 Jun 2010 06:52 PM
#Hi
#I am trying to get the following powershell code to work in the SQL Server Powershell window but I get the error 'Invoke-Sqlcmd : Must declare variable "@" ' .
#>$audits = Invoke-Sqlcmd -ServerInstance DBSVR -Database Test -Query "SELECT RUNCODE FROM AUDIT WHERE RUNDATE = '2010-04-13 06:07:00' " | Select-object RUNCODE
#>foreach ($runcode in $audits) {Invoke-Sqlcmd -ServerInstance DBSVR -Database Test -Query "SELECT PRACTICECODE FROM AUDIT WHERE RUNCODE = $runcode" | Select-object PRACTICECODE}
#Once I have this working I would then like to use the $runcode variable with a stored procedure using Invoke-Sqlcmd.
#What am I doing wrong? Once this is working how would I run the code in a Powershell script?
#Chad Miller
#Basic Member
#
#Posts:198
#18 Jun 2010 10:58 AM
#It looks like this question was asked and answered in the Windows PowerShell forum:
#http://social.technet.microsoft.com...5bda28a3e9
#Rob Burgess
#New Member
#
#Posts:44
#18 Jun 2010 12:01 PM
#Hi
#The suggestion in the Windows Powershell forum didn't work. I am still looking for a solution to my problem.
#Chad Miller
#Basic Member
#
#Posts:198
#18 Jun 2010 12:51 PM
#Is RUNCODE a string datatype?
#I'm able to get results running a test against the pubs sample database using your code with slight modifications:
#$audits = Invoke-Sqlcmd -ServerInstance sql2k8 -Database pubs -Query "Select TOP 10 au_id from authors" 
#foreach($runcode in $audits) {Invoke-Sqlcmd -ServerInstance sql2k8 -Database pubs -Query "Select au_lname from authors where au_id = '$($runcode.au_id)'"}
#Rob Burgess
#New Member
#
#Posts:44
#18 Jun 2010 01:31 PM
#Hi
#Runcode is nvarchar datatype.
#Rob Burgess
#New Member
#
#Posts:44
#18 Jun 2010 01:44 PM
#Thanks for your help. That worked.
#I needed to add the quotes round $($runcode.au_id) as you did in your example.
#'$($runcode.au_id)'
#Could you please tell me how I now add this code to a Powershell script so I don't need to run it in the SQL Server Powershell window. Do I need to add some extra code to the start of the script to register DLLs?
#Chad Miller
#Basic Member
#
#Posts:198
#18 Jun 2010 04:39 PM
#Just so I undertand are trying to run it in regular PowerShell and not sqlps? Do you want parameterize 2010-04-13 06:07:00?
#Rob Burgess
#New Member
#
#Posts:44
#18 Jun 2010 11:39 PM
#I wanted to be able to schedule the code to run on a regular basis or run it manually without opening sqlps or the regular Powershell window. It would be great to be able to parameterize the date in the queries.
#Am I better to do any of this with SQLPSX?
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#19 Jun 2010 09:34 AM
#If you're using SQL Server 2008 or 2008 R2 you can create a SQL Server Agent job with a PowerShell jobstep and directly paste your working script into the command text box. 
#If you're using SQL Server 2005 or 2000. Create a SQL Server Agent job and create an Operating System job step. In the command text box specify: 
#powershell -command "your commands go here" 
#Alternativley you can save you script as ps1 text file and specify: 
#powershell -command "C:\pathtoscriptfile\yourscriptfile.ps1" 
#If you want the date to be driven by the current date time you can do something like this: 
#WHERE RUNDATE BETWEEN '$((Get-Date).ToShortDateString())' AND '$((Get-Date).AddDays(1).ToShortDateString())' 
#Note: Make sure Powershell's execution policy is not set to restricted: 
#Get-ExecutionPolicy 
#Set-ExecutionPolicy RemoteSigned
#Rob Burgess
#New Member
#
#Posts:44
#19 Jun 2010 11:25 AM
#Thanks for you help.
#We are using SQL Server 2008 so I will create a SQL Server Agent job.
#Rob
#Rob Burgess
#New Member
#
#Posts:44
#20 Jun 2010 03:27 PM
#Hi
#I worked out how to run the code as a Powershell script. When I run the script I get the following error but the script has run correctly:
#Invoke-Sqlcmd : Timeout expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.
#Is there a way to extend the Timeout period?
#Chad Miller
#Basic Member
#
#Posts:198
#20 Jun 2010 06:54 PM
#Unfortunately the built-in cmdlet invoke-sqlcmd has bug where the timeout value cannot be extended, however it is trivial to implement your own function. See this blog post and my comments for details: 
#http://scarydba.wordpress.com/2010/...o-problem/
#Rob Burgess
#New Member
#
#Posts:44
#21 Jun 2010 11:27 AM
#Thanks Chad.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#LogFile Class
#Last Post 01 May 2010 11:51 AM by Chad Miller. 1 Replies.
#AuthorMessages
#Terry2win
#New Member
#
#Posts:39
#29 Apr 2010 06:10 AM
#Hello.
#I'm using the logfile class (http://msdn.microsoft.com/en-us/lib...0%29.aspx) to get information about the logfiles on the SQL2008 R2 server.
#However, I'm not fully understanding the property "http://msdn.microsoft.com/en-us/lib...00%29.aspx">MaxSize". It's supposed to display "maximum size to which the file can grow", but I find this hard to believe. To test this I created a database where the initial size of the log file were set to 10 MB. I then checked the box "no growth allowed". But when running the command to get MaxSize I get the number 2097152 (presumably MB after formating from KB). This number seems to be standard for most of my log files.
#Anyone have any experience with this?
#Kind regards
#Chad Miller
#Basic Member
#
#Posts:198
#01 May 2010 11:51 AM
#I'm using SQL 2008 R2 Eval edition and do not have the same issue. If I set a database log file max size and then turn off auto grow. PowerShell/SMO returns the MaxSize I set. I did notice a problem in setting the max file size via the GUI, SSMS where the property change did not take effect. Are you sure the property was in fact changed? 
#As a test try making the change via T-SQL: 
#Alter database SQLPSX 
#Modify File 
#(Name = SQLPSX_log, 
#MaxSize = 4MB); 
#GO 
#Then try retrieving the MaxSize property via PowerShell. 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Remote Connection using SQLCMD
#Last Post 23 Feb 2010 02:37 AM by Bobdee. 1 Replies.
#AuthorMessages
#Bobdee
#Basic Member
#
#Posts:130
#23 Feb 2010 01:07 AM
#Hi,
#I'm using MS SQL cmdlets and am attempting to connect to a remote database.  However, I'm having a problem connecting using powershell :-
#$sqlconnect = 'sqlcmd -S DBServer\MyDB' 
#Invoke-expression $sqlconnect
#Error is :-
#Sqlcmd: Error: Internal error at ReadTextLine (Reason: Unspecified error). At :line:1 char:7 + sqlcmd <<<< -S DBServer\MyDB
#If I run sqlcmd -S DBServer\MyDB in command prompt, I can connect no problem and do what ever I please to the data.
#Is there something I am missing when attempting to connect to the remote database?
#I do have another script running on a database that is local to my workstation, but that is SQLExpress rather than 2008 which we are running in our environment.
#Any help would be appreciated as this is doing my head in.
#Thanks.
#Bobdee
#Basic Member
#
#Posts:130
#23 Feb 2010 02:37 AM
#Found the solution with 
#Invoke-SQLCMD -serverinstance DBserver\MyDB -query "xxxxxxx" 
#pretty simple!!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Create New SQL Instance using Powershell 2.0 Remote
#Last Post 22 Feb 2010 01:26 PM by Chad Miller. 1 Replies.
#AuthorMessages
#Tom
#New Member
#
#Posts:2
#22 Feb 2010 06:11 AM
#Hi All I wish to create a new SQL Instance on a remote machine via Powershell. I simply wish to call the SQL command line application and pass in the credentials and use the SQL Express install exe to install the instance automatically. I have the following code: cmd /c " "cd C:\...\SQLEXPR32.EXE /qb ADDLOCAL=ALL INSTANCENAME="MyInstanceName" SECURITYMODE=SQL SAPWD="MyPassword" SQLAUTOSTART=1 "" This works fine when run from powershell on my local machine, SQL express opens up and installs the instance with no user input needed. But when I create a remote session to a remote PC, and try and call this code, the powershell window hangs forever as if the process is still going, but no instance is created on the Remote Machine. I have the SQL Express exe on the remote machine, and I have powershell installed with a module that has the code to install the new instance via SQLCMD. Not sure if this is possible or if anyone has any tips on how to go about doing this? Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#22 Feb 2010 01:26 PM
#This may not have anything to do with Powershell. The command-line install for SQL Server is tricky/buggy to begin with. 
#Suggestions: 
#Check the SQL Server setup log on the remote machine See http://msdn.microsoft.com/en-us/lib...43702.aspx for details
#Try installing on the remote system interactively from a regular command prompt.
#A quick web search for SQLEXPR32.EXE command line returns a few blog posts that indicate issues just running the utility from a normal command-line:
#http://blogs.msdn.com/astebner/arch...10435.aspx
#http://blogs.msdn.com/astebner/arch...spx#605285
#http://www.developersdex.com/sql/me...024&page=2
#The last link points to an issue if the current user isn't logged in. Don't know if this is your issue, hopefully the setup log file will contain some type of error message.
#I don't know of many people using the command-line install of SQL Server and even fewer using the command-line installation + Powershell. You may want to post your question in a SQL Server forum
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#problem implementing powershell script in Job Agent
#Last Post 03 Feb 2010 12:39 AM by r2d2. 4 Replies.
#AuthorMessages
#r2d2
#New Member
#
#Posts:5
#22 Jan 2010 02:30 AM
#Hello everybody
#I have tried to create a script for SQL Server2008 executed as job.
#JobType: PowerShell
#Until this point everything worked fine... 
#I need to read the OS Disk Statuts... so here the Snippet which works just fine:
#get-Wmiobject -class Win32_LogicalDisk | ft Name, VolumeName, Size, FreeSpace
#Then I tried to write a script to fill the data in a DataTable which will be automatically bulkinserted into sql.
#Here my prob begins...
#If somebody has a clue please help :/
#Code:
#function Out-DataTable {
#param($Properties="*") 
#Begin {
#$dt = new-object Data.datatable $First = $true } 
#Process { $DR = $DT.NewRow() foreach ($item in $_ | Get-Member -type *Property $Properties ) 
#{ $name = $item.Name if ($first) 
#{ $Col = new-object Data.DataColumn $Col.ColumnName = $name $DT.Columns.Add($Col) } 
#$DR.Item($name) = $_.$name } 
#$DT.Rows.Add($DR) $First = $false } 
#End 
#{ return @(,($dt)) } } 
#$dataTable = get-Wmiobject -class Win32_LogicalDisk | ft Name, VolumeName, Size, FreeSpace | Out-DataTable
#$connectionString = „Data Source=QCDEVPDS01\MSSQLSERVERDEV;Integrated Security=true;Initial Catalog=SS_DBA_Dashboard;“ 
#$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString 
#$bulkCopy.DestinationTableName = "t_OS_Drives" 
#$bulkCopy.WriteToServer($dataTable) 
#Error Message 
#Executed as user: QCDEVPDS01\SYSTEM. A job step received an error at line 19 in a PowerShell script. The corresponding line is '$DR.Item($name) = $_.$name '. Correct the script and reschedule the job. The error information returned by PowerShell is: 'Exception setting "Item": "Exception calling "set_Item" with "2" argument(s): "Column 'formatEntryInfo' does not belong to table ."" '. Process Exit Code -1. The step failed. 
#Chad Miller
#Basic Member
#
#Posts:198
#22 Jan 2010 06:37 AM
#In the future I would suggest getting code to run interactively from regular Powershel console before trying to create a SQL Agent job. There are a couple of issues:
#I don't know if this formatting of your forum post, but the entire script you posted is on a single line. This will not work as there are considerations for needing line breaks, having certain keywords by themselve or using a semi-colon or continuation character. It's much easier to use line break as follows (this works):
#function Out-DataTable            
#{            
#    param($Properties="*")            
#    Begin            
#    {            
#        $dt = new-object Data.datatable              
#        $First = $true             
#    }            
#    Process            
#    {            
#        $DR = $DT.NewRow()              
#        foreach ($item in $_ |  Get-Member -type *Property $Properties ){              
#          $name = $item.Name            
#          if ($first) {              
#            $Col =  new-object Data.DataColumn              
#            $Col.ColumnName = $name            
#            $DT.Columns.Add($Col)       }              
#            $DR.Item($name) = $_.$name              
#        }              
#        $DT.Rows.Add($DR)              
#        $First = $false              
#    }            
#    End            
#    {            
#        return @(,($dt))            
#    }            
#}            
#            
#$dataTable = get-Wmiobject -class Win32_LogicalDisk | Select Name, VolumeName, Size, FreeSpace | Out-DataTable            
#$connectionString = "Data Source=QCDEVPDS01\MSSQLSERVERDEV;Integrated Security=true;Initial Catalog=SS_DBA_Dashboard;"            
#$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString            
#$bulkCopy.DestinationTableName = "t_OS_Drives"             
#$bulkCopy.WriteToServer($dataTable)
#The second issue I see you are using Format-Table (FT) instead of select-object (select). 
#The output of format table cannot be piped to your out-datatable function. 
#Format table returns a differrent type
#r2d2
#New Member
#
#Posts:5
#27 Jan 2010 06:39 AM
#thanx alot for the hint, but it sill doesnt work... 
#could it be that powershell 1.0 doesnt support that kind of action? 
#Error yet: 
#The corresponding line is '$bulkCopy.WriteToServer($dataTable)'. 
#Exception calling "WriteToServer" with "1" argument(s): "The given value of type String from the data source cannot be converted to type int of the specified target column." 
#Chad Miller
#Basic Member
#
#Posts:198
#27 Jan 2010 07:03 AM
#It looks like you we worked past the issues of converting the output to a datatable, but now the issue is in calling the WriteToServer method. Based on the error message your problem is that the dataTable column order does not match your SQL Server table column order and the wrong column are mapped. There are two ways to fix this: 
#Explicity map columns using the SqlBulkCopy class OR change your SQL table to match the datatable column order. The latter is easier, to do this: 
#After this line 
#$dataTable = get-Wmiobject -class Win32_LogicalDisk | Select Name, VolumeName, Size, FreeSpace | Out-DataTable 
#Run $dataTable | get-member 
#Recreate or alter your table, t_OS_Drives to match the order you see in the Powershell console. If you have issues doing this post your t_OS_Drives table SQL script and I'll take a look at it.
#r2d2
#New Member
#
#Posts:5
#03 Feb 2010 12:39 AM
#Thanx for the hint. 
#it works now, a bit slow but it does what it should. 
#many thanx again. 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SQL query never completes in background job
#Last Post 26 Jan 2010 11:41 AM by Chad Miller. 4 Replies.
#AuthorMessages
#Ryan Greeley
#New Member
#
#Posts:3
#26 Jan 2010 07:05 AM
#I have a command that I want to run against multiple SQL servers.  To make the script run quicker I'd like to use background jobs.  When I run the command outside of a job it completes and gives me the output I expect.  When I run the command inside of a job it gets stuck in a "running" state.
#This command runs fine:
#$Serverlist = 'server1','server2' foreach ($Server in $ServerList) {    $con = "server=$Server;database=master;Integrated Security=sspi"    $cmd = "EXEC master.dbo.xp_msver"    $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)    $dt = new-object System.Data.DataTable    $da.fill($dt)    $dt  }
#However, this command creates the background jobs but they never complete
#$Serverlist = 'server1','server2' foreach ($Server in $ServerList) {    Start-Job -ArgumentList $Server -ScriptBlock {       param ($Server)       $con = "server=$Server;database=master;Integrated Security=sspi"       $cmd = "EXEC master.dbo.xp_msver"       $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)       $dt = new-object System.Data.DataTable       $da.fill($dt)       $dt    } } 
#Chad Miller
#Basic Member
#
#Posts:198
#26 Jan 2010 11:04 AM
#Having trouble reproducing issue. I ran both commands only changing server1 and server2 to my server names and both complete without issue. Are running Get-Job | Receive-Job to return the output? What's the output of Get-Job?
#Ryan Greeley
#New Member
#
#Posts:3
#26 Jan 2010 11:18 AM
#Get-job gives me this: 
#PS U:\> get-job 
#Id Name State HasMoreData Location Command 
#-- ---- ----- ----------- -------- ------- 
#1 Job1 Running True localhost ... 
#3 Job3 Running True localhost ... 
#Get-job | receive-job returns nothing: 
#PS U:\> get-job | receive-job 
#PS U:\> 
#Ryan Greeley
#New Member
#
#Posts:3
#26 Jan 2010 11:31 AM
#I found a workaround.  The script's background jobs don't complete when running from Powershell V2 on Windows XP.  
#I just tried running the script on Windows 2008 and it completed successfully.
#Ryan
#Chad Miller
#Basic Member
#
#Posts:198
#26 Jan 2010 11:41 AM
#Interesting, I would have thought of that. You may want to verify you have the RTM version of V2 on XP: 
#http://support.microsoft.com/kb/968929 
#Maybe file a connect bug if one doesn't already exist. 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#insert formatted Object in to a table
#Last Post 23 Dec 2009 12:10 PM by Chad Miller. 1 Replies.
#AuthorMessages
#southwest
#New Member
#
#Posts:1
#23 Dec 2009 06:25 AM
#I've been trying to get my formatted get-eventlog query to pass each event that gets returned as a row in a table.  While I am successful each time I pass an individual string to the table, I receive the following error when attempting to pass in my string variable:
#Exception calling "Fill" with "1" argument(s): "Incorrect syntax near 'Index'. If this is intended as a part of a table hint, A WITH ke yword and parenthesis are now required. See SQL Server Books Online for proper syntax. Unclosed quotation mark after the character string ' ca...
#Below is my script thus far (ideally I'd like to add some addtional string manipulation which will parse each returned property to its own column).
#param ( [string] $filename ) 
## PowerShell script to list the Application eventlogs on another computer 
#$Log = "Application" 
##$Computers = get-content $filename
##use the above get-content to read from a list of machines, use below to query a single machine
#$Computers = "workstationName" 
#$ID = "1002" 
#$Type = "Error" 
#foreach ($Computer in $Computers) 
#{ 
#write-host "Details of the Server :" $Computers 
#write-host "-----------------------------------" 
#write-host "Index, DateTime, EntryType, Source, InstanceID, Message" 
#$Objlog = New-Object system.diagnostics.eventLog($Log, $Computers) 
#$result = $Objlog.entries | select -last 5 | out-string 
##The above fails, the below will successfully pass the string and add a row to the db table
##$result = "hello1" 
##write-host $result 
##} 
### add each entry in to SQL #$testVar = "'talk"+" blabla'" 
##$postToDB = $testVar 
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
#$SqlConnection.ConnectionString = "Server=serverName\InstanceName;Database=EventLogDB;Integrated Security=True" 
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
#$SqlCmd.CommandText = "insert into Events values ($result)" 
#$SqlCmd.Connection = $SqlConnection $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
#$SqlAdapter.SelectCommand = $SqlCmd 
#$DataSet = New-Object System.Data.DataSet 
#$SqlAdapter.Fill($DataSet) 
#$SqlConnection.Close() 
#$DataSet.Tables[0] 
#}
#Chad Miller
#Basic Member
#
#Posts:198
#23 Dec 2009 12:10 PM
#It appears you have the incorrect variable name in your foreach loop. Should be this: 
#$Objlog = New-Object system.diagnostics.eventLog($Log, $Computer) 
#Instead of this 
#$Objlog = New-Object system.diagnostics.eventLog($Log, $Computers) 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Use SQL Authentication
#Last Post 14 Dec 2009 12:38 PM by Dan Ball. 2 Replies.
#AuthorMessages
#Ayth
#Basic Member
#
#Posts:239
#14 Dec 2009 08:35 AM
#Hello,
#I have a script which does some actions, and upon completion writes some information to a sql database which allows us to go back and see who ran it. Currently it makes the connection using the credentials of the user running the script, however, I need to change it to use SQL authentication, but am having trouble getting started. Here is the snippet from my script:
#$SQLQuery = "INSERT INTO Logs (Technician, DateTime) VALUES ('"
#$SQLQuery += $curuser
#$SQLQuery += "', '"
#$SQLQuery += $now
#$SQLQuery += "')"
#$SqlServer = "SQLServer";
#$SqlCatalog = "SQLDatabase";
#$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True"
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
#$SqlCmd.CommandText = $SqlQuery
#$SqlCmd.Connection = $SqlConnection
#$SQLConnection.Open()
#$cmd = $SQLConnection.CreateCommand()
#$cmd.CommandText = $SQLQuery
#$result = $cmd.ExecuteNonQuery()
#$SqlConnection.Close();
#I'm using straight powershell, no other providers or anything. Can anyone assist? Thanks.
#My Blog about Powershell http://poweroftheshell.blogspot.com/ Follow me on twitter @darrinhenshaw
#seaJhawk
#Basic Member
#
#Posts:191
#14 Dec 2009 08:40 AM
#Hi Ayth, 
#The script below was originally created by Lee Holmes, but I added -username and -password parameters to allow SQL Authentication: 
############################################################################### ## ## Invoke-SqlCommand.ps1 ## ## From Windows PowerShell Cookbook (O'Reilly) ## by Lee Holmes (http://www.leeholmes.com/guide) ## Updated by Chris Harris (seaJHawk) ## - Allow use of SQL Auth ## ## Return the results of a SQL query or operation ## ## ie: ## ## ## Use Windows authentication ## Invoke-SqlCommand.ps1 -Sql "SELECT TOP 10 * FROM Orders" ## ## ## Use SQL Authentication ## $cred = Get-Credential ## Invoke-SqlCommand.ps1 -Sql "SELECT TOP 10 * FROM Orders" -Cred $cred ## ## ## Perform an update ## $server = "MYSERVER" ## $database = "Master" ## $sql = "UPDATE Orders SET EmployeeID = 6 WHERE OrderID = 10248" ## Invoke-SqlCommand $server $database $sql ## ## $sql = "EXEC SalesByCategory 'Beverages'" ## Invoke-SqlCommand -Sql $sql ## ## ## Access an access database ## Invoke-SqlCommand (Resolve-Path access_test.mdb) -Sql "SELECT * FROM Users" ## ## ## Access an excel file ## Invoke-SqlCommand (Resolve-Path xls_test.xls) -Sql 'SELECT * FROM [Sheet1$]' ## ############################################################################## ############################################################################## ##param( ## [string] $dataSource = "sqlrpt1", ## [string] $database = "ShelbyReport", ## [string] $sqlCommand = $(Throw "Please specify a query."), ## [System.Management.Automation.PsCredential] $credential ## ) ############################################################################## param( [string] $dataSource = "sqlrpt1", [string] $database = "ShelbyReport", [string] $sqlCommand = $(Throw "Please specify a query."), [System.Management.Automation.PsCredential] $credential, [string] $username = "readonly", [string] $password = "readonly" ) ## Prepare the authentication information. By default, we pick ## Windows authentication $authentication = "Integrated Security=SSPI;" ## If the user supplies a credential, then they want SQL ## authentication if($credential) { $plainCred = $credential.GetNetworkCredential() $authentication = ("uid={0};pwd={1};" -f $plainCred.Username,$plainCred.Password) } else { if ($username -and $password) { $authentication = ("uid={0};pwd={1};" -f $username,$password) } } ## Prepare the connection string out of the information they ## provide $connectionString = "Provider=sqloledb; " + "Data Source=$dataSource; " + "Initial Catalog=$database; " + "$authentication; " ## If they specify an Access database or Excel file as the connection ## source, modify the connection string to connect to that data source if($dataSource -match '\.xls$|\.mdb$') { $connectionString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$dataSource; " if($dataSource -match '\.xls$') { $connectionString += 'Extended Properties="Excel 8.0;"; ' ## Generate an error if they didn't specify the sheet name properly if($sqlCommand -notmatch '\[.+\$\]') { $Error = 'Sheet names should be surrounded by square brackets, and ' + 'have a dollar sign at the end: [Sheet1$]' Write-Error $Error return } } } ## Connect to the data source and open it $connection = New-Object System.Data.OleDb.OleDbConnection $connectionString $command = New-Object System.Data.OleDb.OleDbCommand $sqlCommand,$connection $connection.Open() ## Fetch the results, and close the connection $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command $dataset = New-Object System.Data.DataSet [void] $adapter.Fill($dataSet) $connection.Close() ## Return all of the rows from their query $dataSet.Tables | Select-Object -Expand Rows 
#Dan Ball
#Basic Member
#
#Posts:154
#14 Dec 2009 12:38 PM
#It is all based off of the connection string line, the rest of the code doesn't care who logged in. 
#This is the line you need to modify (right now it is set to integrated security): 
#$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True" 
#To help you out with what to put in this line, check out this website: 
#http://www.connectionstrings.com/ 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#using sql server authenication with SMO
#Last Post 29 Nov 2009 03:01 PM by Chad Miller. 3 Replies.
#AuthorMessages
#chart
#New Member
#
#Posts:25
#27 Nov 2009 12:05 PM
#I have a powershell script that uses SMO to get database info from several servers that are in a table.  I need to be able to login to a few servers using sql server authenication (instead of windows authenication).  I cannot get this to work no matter what I try.  My lastest attempt is attached.   Please help someone new to powershell.  Thanks
#try983.ps1
#Chad Miller
#Basic Member
#
#Posts:198
#27 Nov 2009 04:45 PM
#There are couple of ways to connect to a SQL Server using SMO with SQL authentication:
#Method 1, create and pass a SQL Connection object to the SMO.Server constructor:
#$con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") "MyServer\Myinstance","sa","mypassword"
#$server = new-object ("Microsoft.SqlServer.Management.Smo.Server") $con
#Method 2, first create an SMO.Server object and then set 
#$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "MyServer\Myinstance"
#$server .ConnectionContext.LoginSecure = $false
#$server .ConnectionContext.Login = "sa"
#$server .ConnectionContext.Password = "mypassword"
#I noticed you are using the SQL 2008 invoke-sqlcmd cmdlet, SQL authenication is also supported see get-help invoke-sqlcmd and use the -username and -password parameters.
#chart
#New Member
#
#Posts:25
#29 Nov 2009 02:44 PM
#Thanks for the input. I used option two and it worked great. 
#This is probalbly not the correct place for this question. What is the least you can give a sql server user so that they can use Microsoft.SqlServer.Management.Smo.Server to collect 
#$db.size - ($db.logfiles|measure-object -property size -sum).sum / 1024
#Chad Miller
#Basic Member
#
#Posts:198
#29 Nov 2009 03:01 PM
#Not sure, SMO uses the underlying security context of login executing the SMO command. Each SMO command ultimately executes a SQL Query. Assuming the logfile meta data is derived from sys.datababase_fiiles, according to Books Online anyone in the public role for a particular database can retrieve file meta data.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Question about run query against
#Last Post 16 Oct 2009 03:42 AM by Sean. 3 Replies.
#AuthorMessages
#Sean
#New Member
#
#Posts:4
#15 Oct 2009 04:45 AM
#Hope my question is in the right queue, it's not very much related with "management".
#I'm trying to run some query against my SQL server database. I "stealed" some code from a blog, but I can't understand them.
#partial code:
#....#defining connection string etc
#$Reader = $Command.ExecuteReader()
#$Counter = $Reader.FieldCount
#while ($Reader.Read()) {
#    $SQLObject = @{}
#    for ($i = 0; $i -lt $Counter; $i++) {
#        $SQLObject.Add(
#            $Reader.GetName($i),
#            $Reader.GetValue($i));
#    }
#    $SQLObject
#}
#$Connection.Close()
#=======end of code======
#My question is focused on     $SQLObject = @{}. I guess "@{}" means define an empty hashtable, but I still failed to run my own script without the for loop.
#My code:
#...#define connection string etc.
#$conn.open()
#$cmd = $conn.CreateCommand()
#$cmd.CommandText = "select avg(boottime) from cdcs.dbo.bootperf"
#$Reader=$cmd.ExecuteReader()
#    $SQLObject = @{}
#    $SQLObject.Add($Reader.GetName(0),$Reader.GetValue(0));
#$conn.close()
#====EOF====
#error message is "Exception calling "GetValue" with "1" argument(s): "No data exists for the row/column."". And I'm very sure my query will only return one row.
#Also, the datatype of $reader is very new to me: SQLSystem.Data.Common.DataRecordInternal.
#Any ideas how to deal with $reader?
#The blog link is below:
#http://www.powershell.nu/2009/01/27...owershell/
#TIA.
#seaJhawk
#Basic Member
#
#Posts:191
#15 Oct 2009 10:35 AM
#My suggestion is run, don't walk, to Lee Holmes' script: Invoke-SQLCommand.ps1. 
#http://www.leeholmes.com/blog/Categ...20c1033469 
#Unless that is you have SQL 2008. Then you can use the cmdlets with SQL 2008, but they may not do cool things like these that Lee's script does: 
### ## Use Windows authentication 
### Invoke-SqlCommand.ps1 -Sql "SELECT TOP 10 * FROM Orders" 
### 
### ## Use SQL Authentication 
### $cred = Get-Credential 
### Invoke-SqlCommand.ps1 -Sql "SELECT TOP 10 * FROM Orders" -Cred $cred 
### 
### ## Perform an update 
### $server = "MYSERVER" 
### $database = "Master" 
### $sql = "UPDATE Orders SET EmployeeID = 6 WHERE OrderID = 10248" 
### Invoke-SqlCommand $server $database $sql 
### 
### $sql = "EXEC SalesByCategory 'Beverages'" 
### Invoke-SqlCommand -Sql $sql 
### 
### ## Access an access database 
### Invoke-SqlCommand (Resolve-Path access_test.mdb) -Sql "SELECT * FROM Users" 
### 
### ## Access an excel file 
### Invoke-SqlCommand (Resolve-Path xls_test.xls) -Sql 'SELECT * FROM [Sheet1$]' 
#Sean
#New Member
#
#Posts:4
#16 Oct 2009 03:42 AM
#I wish I can. I have to leave it along for now, but I have to figure it out sometime. 
#Sean
#New Member
#
#Posts:4
#16 Oct 2009 03:42 AM
#I wish I can. I have to leave it along for now, but I have to figure it out sometime. 
#thank you for reply.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How get data from a column of a table and put in a variable?
#Last Post 15 Oct 2009 05:01 AM by Sean. 6 Replies.
#AuthorMessages
#George Gustavo
#New Member
#
#Posts:10
#16 Sep 2009 12:35 PM
#I need help to create a script.
#The script gets a data of determinate column of a table in my database and store in a variable.
#Somebody Help's me?
#thanks
#Chad Miller
#Basic Member
#
#Posts:198
#16 Sep 2009 01:25 PM
#To do this, I'll use simple function in my script:
########################
#function Get-SQLData
#{
#    param(
#    [string]$serverName,
#    [string]$databaseName,
#    [string]$query
#    )
#    Write-Verbose "Get-ISData serverName:$serverName databaseName:$databaseName query:$query"
#    $connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"
#    $da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($query,$connString)
#    $dt = New-Object "System.Data.DataTable"
#    [void]$da.fill($dt)
#    $dt
#} #Get-SQLData
#Then I will call the function within the same script:
#Get-SqlData "Z002\SQL2K8" "pubs" "select au_id from authors" | foreach {$_.au_id }
#George Gustavo
#New Member
#
#Posts:10
#18 Sep 2009 11:39 AM
#Hi, thanks for the script, but I have a problem for understand the third parameter $query.
#what is au_id and authors?
#if you can explain for me, I will be very hapy.
#Thanks.
#George Gustavo
#New Member
#
#Posts:10
#18 Sep 2009 01:00 PM
#$SQLSERVER=read-host "Enter SQL Server Name:" 
#$Database=read-host "Enter Database Name:" 
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
#$SqlConnection.ConnectionString = "Server=$SQLSERVER;Database=$DATABASE;Integrated Security=True" 
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
#$SqlCmd.CommandText = "select name from sysobjects where type='u'" 
#$SqlCmd.Connection = $SqlConnection 
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
#$SqlAdapter.SelectCommand = $SqlCmd 
#$query="select usuarios from usuarios" | foreach {$_.usuarios} 
#Write-Verbose "Get-ISData serverName:$serverName databaseName:$databaseName query:$query" 
#$da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($query,$SqlConnection) 
#$dt = New-Object "System.Data.DataTable" 
#[void]$da.fill($dt) 
#$dt 
#$SqlConnection.Close() 
#tables name is: usuarios
#columns name is: usuarios
#but return this error:
#Exception callin "fill" with "1" argument(s): "ExecuteReader: CommandText property has not been At C:\sql.ps1:16 char:16 
#+          [void]$da.fill( (((( $dt)
#help me correct this error!
#Chad Miller
#Basic Member
#
#Posts:198
#18 Sep 2009 01:19 PM
#au_id is my example column name and authors an example table name. Both are from the sample database pubs provided by Microsoft. Since you didn't provide your column name or table name, I had to make up an example.
#Chad Miller
#Basic Member
#
#Posts:198
#18 Sep 2009 01:24 PM
#Posted By ggmt89 on 18 Sep 2009 02:00 PM 
#$SQLSERVER=read-host "Enter SQL Server Name:" 
#$Database=read-host "Enter Database Name:" 
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
#$SqlConnection.ConnectionString = "Server=$SQLSERVER;Database=$DATABASE;Integrated Security=True" 
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
#$SqlCmd.CommandText = "select name from sysobjects where type='u'" 
#$SqlCmd.Connection = $SqlConnection 
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
#$SqlAdapter.SelectCommand = $SqlCmd 
#$query="select usuarios from usuarios" | foreach {$_.usuarios} 
#Write-Verbose "Get-ISData serverName:$serverName databaseName:$databaseName query:$query" 
#$da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($query,$SqlConnection) 
#$dt = New-Object "System.Data.DataTable" 
#[void]$da.fill($dt) 
#$dt 
#$SqlConnection.Close() 
#tables name is: usuarios
#columns name is: usuarios
#but return this error:
#Exception callin "fill" with "1" argument(s): "ExecuteReader: CommandText property has not been At C:\sql.ps1:16 char:16 
#+          [void]$da.fill( (((( $dt)
#help me correct this error! 
#This is somewhat odd, $query="select usuarios from usuarios" | foreach {$_.usuarios}. You should just set $query to a string i.e. 
#$query="select usuarios from usuarios"  
#Get rid of the | foreach {$_usarios} part. I haven't test the entire thing. Post back any errors after making this change first.
#Sean
#New Member
#
#Posts:4
#15 Oct 2009 05:01 AM
#I believe the script the in the link can help. Although i don't really understand it... 
#http://www.powershell.nu/2009/01/27...owershell/
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#trouble with output format
#Last Post 10 Oct 2009 06:15 AM by dcoz. 4 Replies.
#AuthorMessages
#dcoz
#New Member
#
#Posts:16
#07 Oct 2009 04:46 AM
#Hi guys,
#I am trying to create a simple script that produces the server names and last backup data for a particular SQL database.
#what i have got to far is:
#foreach ($sql in get-Content "servers.txt") 
#{ $srv = get-sqlserver $sql 
#   $srvname = $srv.Name 
#   $db = get-sqldatabase $srvname test 
#   $dbprop = $db.Properties | Where-Object {$_.name -eq 'lastbackupdate'} |Select-Object value 
#}
#I am trying to have the output show the server name and last backup date. At the moment just having trouble trying to see how i can get this output format.
#Any help would be appreciated.
#regards
#DC
#Chad Miller
#Basic Member
#
#Posts:198
#07 Oct 2009 02:47 PM
#$db | select @{name='Server';e={$db.parent.name}}, name, lastbackupdate
#dcoz
#New Member
#
#Posts:16
#08 Oct 2009 06:29 AM
#Thanks cmille19 thats works great. 
#I'm wondering if you could explain what is going on in the line you gave me? 
#I understand some of it but just trying to get a better grasp of it. 
#thanks 
#DC
#Chad Miller
#Basic Member
#
#Posts:198
#08 Oct 2009 09:30 AM
#Assigning a database object to the variable $db next we're using the select-object aka select to well, select specific properties of name and lastbackupdate. The Server name is not a property of database class natively, however in PowerShell there are several ways to add synthetic properties to an object. The way we are doing this in the code example above is by using an expression which is abbreviated "e" 
#The expression @{name='Server';e={$db.parent.name}} creates a new property callled Server, the value is assigned is $db.parent.name. The Parent property of a database object is a server object and the server class has a name property.
#dcoz
#New Member
#
#Posts:16
#10 Oct 2009 06:15 AM
#I understand it alot better now thanks chad. 
#I appreciate the help. 
#Regards 
#DC
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#SMO ManagedComputer object
#Last Post 08 Oct 2009 09:50 AM by Chad Miller. 1 Replies.
#AuthorMessages
#rhavenn
#New Member
#
#Posts:1
#01 Oct 2009 03:07 PM
#Hey Peeps,
#I'm trying to use PowerShell and SMO objects to query the available instances of a SQL 2008 server.
#I loaded the SQLWMIManagement class and then created a WMI.ManagedComputer object.
#However, the server I'm connecting to requires a SQL username and password and I get an error when trying to set the password for the connection.
#$m = new-object ('Microsoft.SQLServer.Management,SMO,WMI.ManagedComputer') 'TESTSERVER'
#$m.ConnectionSettings.username = "sa"
#$m.ConnectionSettings.SetPassword("password")
#$m.ServerInstances
#I tried set_Username("sa") as well. However,  both error out as access denied.
#If I create a Smo.Server object and use the set_Login and set_Password I'm able to connect fine to the same server. However, the Smo.Server object requires me to define named instances and I would rather just query a server for all available instances which the ManagedComputer object should provide.
#Any thoughs / suggestions?
#Thanks.
#Chad Miller
#Basic Member
#
#Posts:198
#08 Oct 2009 09:50 AM
#The ManagedComputer class uses WMI and only supports Windows authentication.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Calling stored procedure
#Last Post 12 Sep 2009 01:30 AM by ananda. 2 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#11 Sep 2009 04:09 AM
#Hi cmille, 
#Could you clear me one doubts.
#{
#$con= "server=ipaddress;database=master;User Id=username;Password=password" 
#select * from table1
#select * from table2
#select * from table3
#.........................
#  $cmd="select * from table7"
# $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)
# $dt7 = new-object System.Data.Datatable 
# $da.fill($dt7)
# $svr 
# $Reslut7 = $dt7 | out-string
#after that below part i want calling stored procedure, how to calling sp here?
#sp there we don't give parameter value.
#sp name - exec usp_checksqlservices
#sp retun value is - SQL Server "servername" is Online for the past 22 hours & 59 minutes
# MSSQLSERVER SERVICE and SQL AGENT SERVICE both are running 
# $con = new-object System.Data.SqlClient.SqlConnection
#$con.Open() 
#$cmd = new-object System.Data.SqlClient.SqlCommand("exec usp_checksqlservices", $con) $cmd.ExecuteNonQuery()
#$con.Close() 
#}
#......................
#.......................
#here email part,  
#I have received all table result fine via email, so i want receive table result with sp values. how to add body text on sp return values?
#{
#........
#$bodyText = ("$Reslut1","$Reslut2","$Reslut3","$Reslut4","$Reslut5","$Reslut6","$Reslut7","$txt")
#.......
#}
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#11 Sep 2009 12:29 PM
#Use the same code to call the stored procedure as you're using for the select query. The method ExecuteNonQuery() should only be used for SQL statements that do not return result sets i.e. insert, update, delete statements. So, you should be able to call the procedure like this 
#$cmd="exec usp_checksqlservices" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt7 = new-object System.Data.Datatable 
#$da.fill($dt7) 
#$Reslut7 = $dt7 | out-string 
#ananda
#New Member
#
#Posts:28
#12 Sep 2009 01:30 AM
#Hi Cmille , thanks for your reply 
#I could tried below statement, It return value is 0, 
#$cmd="exec usp_checksqlservices" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt7 = new-object System.Data.Datatable 
#$da.fill($dt7) 
#$Reslut7 = $dt7 | out-string 
#Thanks
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Adding Multiple query
#Last Post 08 Sep 2009 10:52 PM by ananda. 2 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#08 Sep 2009 02:52 AM
#Hi friends,
#I want ask two doubts, In powershell script
#1. $con = "server=ipaddress;database=master;Integrated Security=true" 
#Error 
#Exception calling "Fill" with "1" argument(s): "Login failed for user '(null)'. Reason: Not associated with a trusted SQL Server connection."
# $con = "server=ipaddress;database=master;Integrated Security=true" - This statment require local Administrator login for execute the query,  some of the server this login has been disabled. so how can i change connection string? but i did't know sa password
#2. 
#$con = "server=ipaddress;database=master;Integrated Security=true" 
#  $cmd="SELECT * from tablename" 
#  $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)
#  $dt = new-object System.Data.Datatable
#  $da.fill($dt)
#  $svr
#$Reslut = $dt| out-string
#I want adding multiple query, how can change it? for exmple
#  $cmd="SELECT * from tablename1" 
#$cmd="SELECT * from tablename2" 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#08 Sep 2009 08:50 AM
#1. Changing the connection string to sa won't help you if you don't know the password. I would suggest looking at two things: 
#Adding your login to the SQL instance by running SSMS as a local administrator 
#Ensuring allow remote connection options is turned on. By default MSDE/Express versions this option off and you will not be allow to connect removely. 
#As far as connection strings, check out http://connectionstrings.com/ for sample connection strings. 
#2. This works fine for me as far as executing two queries, do you want to execute both queries in a single pass? 
#$con = "server=ipaddress;database=master;Integrated Security=true" 
#$cmd="SELECT * from tablename1" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.Datatable 
#$da.fill($dt) 
#$Reslut = $dt| out-string 
#$cmd="SELECT * from tablename2" 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.Datatable 
#$da.fill($dt) 
#$Reslut = $dt| out-string 
#ananda
#New Member
#
#Posts:28
#08 Sep 2009 10:52 PM
#Hi Cmile thanks for your reply.
##1 - I have created one sql user and given permission to respective database,  and changed connection string also It is worked for me.
#$con = "server=ipaddress;database=master;User Id=username;Password=password" 
##2 As per your reply that is also worked fine for me
#Thanks
# 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Stored Procedure Help
#Last Post 29 Aug 2009 06:33 PM by Chipper351. 3 Replies.
#AuthorMessages
#Chipper351
#New Member
#
#Posts:19
#29 Aug 2009 01:33 AM
#I am Trying to Get the Results of a SQL Stored procedure that I am feeding multiple databases to restore. I have a function that Opens up the Connection with SQL as I'm going to be passing several databases to a single query. My problem is understanding how to get the results from the Stored procedure and being able to get values from those results.
#function SQLRestoreDatabase {
#    Param ($query, $connection)
#        
#    $sqlCommand = new-object System.Data.SqlClient.SqlCommand
#    $sqlCommand.Connection= $connection
#    $sqlCommand.CommandText= $query
#                    
#    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
#    $SqlAdapter.SelectCommand = $sqlCommand
#    $DataSet = New-Object System.Data.DataSet    
#    $SqlAdapter.Fill($DataSet)     
#    $DataSet.Tables[0]
#            
#}
#$sqlConnection = new-object System.Data.SqlClient.SqlConnection
#$sqlConnection.ConnectionString = "server=" + $SQLServer + ";integrated security=true;database=" + $SQLDatabase
#$SQLQuery = "exec dbo.restoredb"
#SQLRestoreDatabase $SQLQuery $sqlConnection
#These are the results that are returned every time I run the query. 
#I would like to be able to pull the value out of Col3. is there any way to do this or possibly a better way to run this SQL Stored Procedure to get the results that I am looking for? 
#Is there a way to make it so the results are not Output but I can still use them.
#Also if there is a better way to format the output as Format-Table doesn't seem to do anything
# Col1                   Col2             Col3                       DateTime             
#  ---------         ----------       ------------         -------------------             
#             0                  0                 1                    8/29/2009 2:36:22 AM    
#Chad Miller
#Basic Member
#
#Posts:198
#29 Aug 2009 07:29 AM
#You could capture the array of DataRow returned from your function: 
#$dt = SQLRestoreDatabase $SQLQuery $sqlConnection 
#and then do something like this 
#$col3 = $dt | foreach {$_.Col3} 
#$col3[0] 
#Or using a select-object 
#$col3 = $dt | select Col3 
#$col3[0].Col3 
#I'm not sure what you mean by format-table doesn't do anything, the results you've posted are formated in table. Check get-help format-table for additional options.
#Chipper351
#New Member
#
#Posts:19
#29 Aug 2009 05:24 PM
#EDIT: Looks Like this did not solve my issues When calling my Function
#$dt = SQLRestoreDatabase $SQLQuery $sqlConnection 
#$col3 = $dt | select Col3 
#$col3[0].Col3 
#I get no result. This is my full code
#function SQLRestoreDatabase {
#    Param ($query, $connection)
#        
#    $sqlCommand = new-object System.Data.SqlClient.SqlCommand
#    $sqlCommand.Connection= $connection
#    $sqlCommand.CommandText= $query
#                    
#    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
#    $SqlAdapter.SelectCommand = $sqlCommand
#    $DataSet = New-Object System.Data.DataSet    
#    $SqlAdapter.Fill($DataSet)     
#    $DataSet.Tables[0]
#            
#}
#$sqlConnection = new-object System.Data.SqlClient.SqlConnection
#$sqlConnection.ConnectionString = "server=" + $SQLServer + ";integrated security=true;database=" + $SQLDatabase
#$SQLQuery = "exec dbo.restoredb"
#$dt = SQLRestoreDatabase $SQLQuery $sqlConnection 
#$col3 = $dt | select Col3 
#$col3[0].Col3 
#I get No result displayed. When Debugging and going through my dt variable under the SyncRoot>[1]> shows the column names and then the values next to them. This lead me to believe that the function is returning the results that I am looking for I just can't figure out the proper syntax to retrieve the information I need. Thank you!!!!
#Chipper351
#New Member
#
#Posts:19
#29 Aug 2009 06:33 PMAccepted Answer 
#Looks like using your suggestion I was able to call the actual column name and return the result that I needed
#$col2 = $dt[1].DidRestore
#My File Code looks like this and returns the result that I need. The "DidRestore" is the name of the column. It would be nice if I could do this without calling the column name but this does work.
#function SQLRestoreDatabase {
#    Param ($query, $connection)
#        
#    $sqlCommand = new-object System.Data.SqlClient.SqlCommand
#    $sqlCommand.Connection= $connection
#    $sqlCommand.CommandText= $query
#                    
#    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
#    $SqlAdapter.SelectCommand = $sqlCommand
#    $DataSet = New-Object System.Data.DataSet    
#    $SqlAdapter.Fill($DataSet)     
#    $DataSet.Tables[0]
#            
#}
#$sqlConnection = new-object System.Data.SqlClient.SqlConnection
#$sqlConnection.ConnectionString = "server=" + $SQLServer + ";integrated security=true;database=" + $SQLDatabase
#$SQLQuery = "exec dbo.restoredb"
#$dt = SQLRestoreDatabase $SQLQuery $sqlConnection 
#$col3 = $dt[1].DidRestore
#Really Appreciate your time and help. I would not of been able to come to this without your help!
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Query Result with email body
#Last Post 13 Aug 2009 03:42 AM by Chad Miller. 23 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#28 Jul 2009 03:37 AM
#$svr = get-content "D:\DC\servers.txt"
# 
#foreach ($Reslt in $body) 
#{
# $con = "server=$svr;database=data_reliance;Integrated Security=sspi" 
#$cmd = "select * from dc_online where dc_status = 'fail' " 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.DataTable 
#$da.fill($dt)|out-null 
#$svr
# $dt | Format-Table -autosize }
# 
#foreach ($item in $body) 
#{
# $txt = @" This is an informational Message from TEST Server, For online data concentator network checking either DC status Fail or success, Please kindly check it ASAP and avoid wrong data to be insert on EBS database 
#NOTE:- This is an auto generated mail notification from Micosoft SQLSERVER2000,Please do not reply. "@
# 
#$recpts = get-content "D:\DC\EmailList.txt"
# $smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="EBS DC N/W failure on" + $svr
# $from="JerpCoker@RIL.COM" 
#foreach ($recpt in $recpts)
# {
# $to = "ananda.murugesan@ril.com" 
#$cc = $recpt $msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.to.add($to) 
#$msg.cc.add($cc)
# $msg.Subject = $subject 
#$msg.Body = $da 
#$msg.Body = $txt 
#$smtp.Send($msg) } } 
#the above script is working fine, but i could not able to create script for query result should comes in email body content, please can any one help me.
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#28 Jul 2009 02:58 PM
#I noticed you're setting $msg.Body to $da and $txt. Also the first foreach loop (foreach ($Reslt in $body) isn't related to the second (foreach ($item in $body) ). Did you want to loop through the DataTable? 
#ananda
#New Member
#
#Posts:28
#28 Jul 2009 08:34 PM
#I want result with mail body like 
#This is query result 
#dc_id location dc_status IP_no dc_date 
#----- -------- --------- ----- ------- 
#1 S12 Fail 10.4.20.12 7/28/2009 11:39:11 AM 
#2 S13 Fail 10.4.20.32 7/28/2009 11:39:30 AM 
#3 S16 Fail 10.4.20.44 7/28/2009 11:39:47 AM 
#4 S22 Fail 10.4.20.56 7/28/2009 11:40:09 AM 
#This is an informational Message from test Server, 
#For online data concentator network checking either DC status Fail or success, 
#Please kindly check it ASAP and avoid wrong data to be insert on test database 
#NOTE:- This is an auto generated mail notification from Micosoft SQLSERVER2000,Please do not reply. 
#Chad Miller
#Basic Member
#
#Posts:198
#29 Jul 2009 05:22 AM
#Perhaps something like this...
#$result = $dt | format-table -autosize | out-string
#$txt = @"
#This is an informational Message from TEST Server, For online data concentator network checking either DC status Fail or success, Please kindly check it ASAP and avoid wrong data to be insert on EBS database 
#NOTE:- This is an auto generated mail notification from Micosoft SQLSERVER2000,Please do not reply.
#"@
#$bodyText = "$result $txt"
##Remove these lines
#$msg.Body = $da 
#$msg.Body = $txt 
##Replace with
#$msg.Body = $bodyText
#ananda
#New Member
#
#Posts:28
#30 Jul 2009 12:11 AM
#hi Cmille19 thanks for your reply, 
#As per your reply, i have changed the below script, but email body loaded only $txt messages not query result. is there any suggestion welcomes you. 
#$svr = get-content "D:\DC\servers.txt" 
#foreach ($Reslut in $body) 
#{ 
#$con = "server=$svr;database=data_reliance;Integrated Security=sspi" 
#$cmd = "select * from dc_online where dc_status = 'fail' " 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.Datatable 
#$da.fill($dt)|out-null 
#$svr 
#$Reslut = $dt | format-table -autosize | out-string 
#} 
#foreach ($item in $body) 
#{ 
#$txt = @" 
#This is an informational Message from JGSRVR55 EBS Server, 
#For online data concentator network checking either DC status Fail or success, 
#Please kindly check it ASAP and avoid wrong data to be insert on EBS database 
#NOTE:- This is an auto generated mail notification from Micosoft SQLSERVER2000,Please do not reply. 
#"@ 
#$recpts = get-content "D:\DC\EmailList.txt" 
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="EBS DC N/W failure on " + $svr 
#$from="JerpCoker@RIL.COM" 
#foreach ($recpt in $recpts) 
#{ 
#$to = "ananda.murugesan@ril.com" 
#$cc = $recpt 
#$msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.to.add($to) 
#$msg.cc.add($cc) 
#$msg.Subject = $subject 
#$bodyText = "$result $txt" 
#$msg.Body = $bodyText 
#$smtp.Send($msg) 
#} 
#} 
#what i am getting in email body result is like... 
#This is an informational Message from JGSRVR55 EBS Server, 
#For online data concentator network checking either DC status Fail or success, 
#Please kindly check it ASAP and avoid wrong data to be insert on EBS database 
#NOTE:- This is an auto generated mail notification from Micosoft SQLSERVER2000,Please do not reply. 
#-------------- 
#But Query result not loaded in email body. 
#Thanks 
#ananda
#New Member
#
#Posts:28
#30 Jul 2009 02:46 AM
#Hi , 
#I got the full result in email body, i changed script like this 
#$da.fill($dt) 
#$Reslut = $dt | format-table -autosize | out-string 
#$msg = New-Object system.net.mail.mailmessage 
#$bodyText = ("$result"," $txt" ) 
#$msg.Body = $bodyText 
#$smtp.Send($msg) 
#Thank you cimlle19 for your help. 
#ananda
#New Member
#
#Posts:28
#01 Aug 2009 03:43 AM
#$con = "server=$svr;database=data_reliance;Integrated Security=sspi" 
#$cmd = "select * from dc_online where dc_status = 'fail' " 
#$da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con) 
#$dt = new-object System.Data.Datatable 
#$da.fill($dt)|out-null 
#$svr 
#$Reslut = $dt | format-table -autosize | out-string 
#WARNING: 4 columns do not fit into the display and were removed. 
#Email Body i got warning messages, and all table column not dispaly, pl tell me how to resolve it, 
#I tried the following script but this is not hope.
#$Reslut = $dt | format-table -autosize | select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS @{e={(get-acl $_.mshpath).owner}};n='Owner' | ft -auto
#Error details:
#Select-Object : A parameter cannot be found that matches parameter name 'System.Collections.Hashtable At D:\DC\DCfinalCheck.ps1:11 char:50 + $Reslut = $dt | format-table -autosize | select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS @{e= th).owner}};n='Owner' | ft -auto The term 'n=Owner' is not recognized as a cmdlet, function, operable program, or script file. Verify gain. At D:\DC\DCfinalCheck.ps1:11 char:133 + $Reslut = $dt | format-table -autosize | select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS @{e={(get- ner}};n='Owner' <<<< | ft -auto
#Thnaks. 
#ananda
#Chad Miller
#Basic Member
#
#Posts:198
#01 Aug 2009 06:17 AM
#I see a couple problems, first you are using format-table then select and then ft which is short for format table. Instead use should use select and then format table at the end. So remove the first format-table -autosize. The second problem is the way you are constructing your expression it should be @{name='Owner';Expression={(get-acl $_.mshpath).Owner}
#ananda
#New Member
#
#Posts:28
#03 Aug 2009 04:28 AM
#Thanks for your help, as per your reply, I changed the script like below 
#$Reslut = $dt | select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS @{name="Owner";Expression={(get-acl $_.mshpath).Owner} |ft -auto 
#It was not hope. 
#Error: 
#Select-Object : A parameter cannot be found that matches parameter name 'System.Collections.Hashtable'. 
#At D:\DC\DCfinalCheck.ps1:11 char:24 
#+ $Reslut = $dt | select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS @{name="Owner";Expression={(get-acl $_.mshpath).Owner} | ft -auto 
#thanks 
#Chad Miller
#Basic Member
#
#Posts:198
#03 Aug 2009 04:32 AM
#There's comma missing between DC_STATUS and the expression, should be: 
#DC_STATUS, @{name="Owner";Expression={(get-acl $_.mshpath).Owner}
#ananda
#New Member
#
#Posts:28
#04 Aug 2009 03:43 AM
#Hi cmille19 thank you for reply, I trid as you suggestion me, but it is not working, the script like below 
#$Reslut = $dt| select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}} 
#Error 
#------- 
#Select-Object : The argument cannot be null or empty. 
#At D:\DC\DCfinalCheck.ps1:14 char:22 
#+ $Reslut = $dt| select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}} 
#Select-Object : The argument cannot be null or empty. 
#At D:\DC\DCfinalCheck.ps1:14 char:22 
#+ $Reslut = $dt| select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}} 
#Select-Object : The argument cannot be null or empty. 
#At D:\DC\DCfinalCheck.ps1:14 char:22 
#+ $Reslut = $dt| select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}} 
#I serached many powershell script, but it was not hope. 
#Thanks 
#ananda 
#Chad Miller
#Basic Member
#
#Posts:198
#04 Aug 2009 04:01 AM
#The statement syntax looks correct. Where does mshpath come from? Is it a column in your dc_status table? Is it not null? Please post the resuls of $dt without piping through select.
#ananda
#New Member
#
#Posts:28
#05 Aug 2009 09:37 PM
#I am using script below, and i got the result in List type not table format.  between location and dc_port one blank line comes because location datatype lenth is 150 varchar. 
#$Reslut = $dt | out-string 
#The result is 
#DC_ID : 14 
#LOCATION : S22_B20 
#DC_PORT : 2101 
#IP_NO : 10.60.131.149 
#DC_STATUS : Fail 
#DC_ID : 45 
#LOCATION : S22_B52 
#DC_PORT : 2101 
#IP_NO : 10.60.131.181 
#DC_STATUS : Fail 
#DC_ID : 134 
#LOCATION : S21_B32 
#DC_PORT : 2101 
#IP_NO : 10.60.131.190 
#DC_STATUS : Fail 
#This is an informational message from dc Server, For online data concentator network checking either DC status Fail or Success, kindly check DC fail status ASAP and avoid wrong data to be insert on dc database. 
#NOTE:- Please do not reply this is an auto generated mail notification from Micosoft windows. If you need further information and contact SERVER ADMIN TEAM. 
#------------------------
#If i am using script like --> $Reslut = $dt | format-table -auto | out-string 
# 
#Result is
#WARNING: 3 columns do not fit into the display and were removed. 
#-------- 
#Thanks 
#ananda 
#Chad Miller
#Basic Member
#
#Posts:198
#06 Aug 2009 03:19 AM
#I don't see mshpath as a property returned from your $dt variable. This will cause a problem with your original statement: 
#$Reslut = $dt| select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}} 
#ananda
#New Member
#
#Posts:28
#07 Aug 2009 04:17 AM
#hi cimlle, if using below script, 
#$Reslut = $dt | select DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS, @{name="Owner";Expression={(get-acl $_.mshpath).Owner}} 
#Error: 
#Select-Object : The argument cannot be null or empty. At D:\DC\DCNWCheck.ps1:14 char:22 + $Reslut = $dt| select <<<< DC_ID,LOCATION,DC_PORT,IP_NO,DC_STATUS,@{name="Owner";Expression={(get-acl $_.mshpath).owner}}
#Chad Miller
#Basic Member
#
#Posts:198
#07 Aug 2009 05:00 AM
#I don't have the same test as you, however if I use the sample pubs database. This works: 
#$dt | Select au_id, au_lname, @{name="City";Expression={($_.City).tolower()}} 
#Again as I stated in my previous post, mshpath must be a property of $dt. Is it? Please post the results of 
#$dt | get-member -type Property 
#ananda
#New Member
#
#Posts:28
#07 Aug 2009 10:39 PM
#Hi cimlle thanks for reply
#I m using two different script and result as follows 
#1. $Reslut = $dt| select DC_ID, DC_PORT, IP_NO, DC_STATUS, @{name="LOCATION";Expression={($_.LOCATION).Owner}} | out-string 
#this result location data not display 
#DC_ID : 266 
#DC_PORT : 2101 
#IP_NO : 10.60.131.182 
#DC_STATUS : Ok 
#LOCATION : 
#2. $Reslut = $dt| select DC_ID, DC_PORT, IP_NO, DC_STATUS, @{name="LOCATION";Expression={($_.LOCATION).tolower()}} | out-string 
#I got result list in email body as below, but could not get table format becuase location column length 150 char in database table. so how to reduce column length thro powershell, data loss if i tried manully reduced column length in sql table. ( storing data length always 8 char in table)
#DC_ID : 1 
#DC_PORT : 2101 
#IP_NO : 10.60.131.130 
#DC_STATUS : Ok 
#LOCATION : SS23
#The above result comes around 81KB total 269 records, so i need table format in email body.
#I could tired script below for table format
#$Reslut = $dt|select DC_ID, DC_PORT, IP_NO, DC_STATUS, @{name="LOCATION";Expression={($_.LOCATION).toupper()}} | ft | out-string 
#I got result but In email body two coulmn between more space available. so how to reduce and adjust white space.
#3. $dt | get-member -type Property 
#TypeName: System.Data.DataRow 
#Name MemberType Definition 
#---- ---------- ---------- 
#DC_ID Property System.Int32 DC_ID {get;set;} 
#DC_PORT Property System.Int32 DC_PORT {get;set;} 
#DC_STATUS Property System.String DC_STATUS {get;set;} 
#IP_NO Property System.String IP_NO {get;set;} 
#LOCATION Property System.String LOCATION {get;set;} 
#Thanks 
#-----
#Chad Miller
#Basic Member
#
#Posts:198
#08 Aug 2009 06:53 AM
#You could try format-table with the wrap option i.e. ft -wrap 
#To remove extra spaces you do something like: 
#out-string | foreach {$_ -replace "\s *", " "} 
#As for your original error, since mshpath isn't a property of your $dt variable that would explain the error The argument cannot be null or empty. 
#ananda
#New Member
#
#Posts:28
#10 Aug 2009 04:25 AM
#Thanks for reply.... 
#I am asking one final question? 
#$cmd = "select * from dc_online where dc_status = 'fail' " 
#I want send email alert for How set the when dc_staus fail? 
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#10 Aug 2009 08:56 AM
#Just to clarify, do you want to updated the column dc_status OR do you want to send an email if dc_status is equal to fail? 
#To do the latter, simply add an if statement: 
##This menas if $dt is not null 
#if ($dt) 
#{ 
#} 
#ananda
#New Member
#
#Posts:28
#12 Aug 2009 03:49 AM
#Hi Cmille thank for reply... 
#Actually table of dc_status column is updated one, it is updated by application. this column contain string values. 
#I could try below script, but it was send email both condition for dc_status fail and success 
#if ($dt -eq 0) 
#{ 
#"$dt is success" 
#} 
#else 
#{ 
#foreach ($item in $body) 
#{ 
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="Data Concentrator Network status Notification from EBS server" 
#$from="JGSRVR55@RIL.COM" 
#$to = "ananda.murugesan@ril.com" 
##$cc = get-content "D:\DC\EmailList1.txt" 
#$msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.to.add($to) 
##$msg.cc.add($cc) 
#$msg.Subject = $subject 
#$bodyText = ("$Reslut") 
#$msg.Body = $bodyText 
#$smtp.Send($msg) 
#} 
#}
#Chad Miller
#Basic Member
#
#Posts:198
#12 Aug 2009 03:57 AM
#$dt will never equal zero. It will either be null or contain an array of DataRows. To check whether $dt is null you should use either: 
#if ($dt -eq $null) 
#or the statement I listed in my previous reply which is short way of testing for null: 
#if ($dt)
#ananda
#New Member
#
#Posts:28
#13 Aug 2009 02:51 AM
#Hi Cmille, i coud tried the following script but sending email both condition 
#1. if ($dt -eq $null) 
#2. if ($dt) 
#----------------------------------- 
#if ($dt -eq $null) 
#{ 
#"$dt is success" 
#} 
#else 
#{ 
#foreach ($item in $body) 
#{ 
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="Data Concentrator Network status Notification from EBS server" 
#$from="JGSRVR55@RIL.COM" 
#$to = "ananda.murugesan@ril.com" 
##$cc = get-content "D:\DC\EmailList1.txt" 
#$msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.to.add($to) 
##$msg.cc.add($cc) 
#$msg.Subject = $subject 
#$bodyText = ("$Reslut") 
#$msg.Body = $bodyText 
#$smtp.Send($msg) 
#} 
#} 
#another way
#if ($dt -eq $null)
#{
#"dt is ok"}
#else{
#      $smtp.Send($msg)
#}
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#13 Aug 2009 03:42 AM
#Perhaps its your data. Are you specifying failed status in your query? Here's a quick test I ran which duplicates what you are trying to do and the results are as expected, the first query returns null for $dt and the second returns not null for $dt.
#function Get-SqlData
#{
#    param($serverName, $databaseName, $query)
# 
#    $connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;"
#    $da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($query,$connString)
#    $dt = New-Object "System.Data.DataTable"
#    [void]$da.fill($dt)
#    $dt
# 
#} #Get-SqlData
#$dt = Get-SqlData "$env:computername\sqlexpress" pubs "select * from authors where au_id = '000'"
##record does not exist returns null
#if ($dt)
#{
# "dt is not null"
#}
#else
#{
# "dt is null"
#}
#$dt = Get-SqlData "$env:computername\sqlexpress" pubs "select * from authors"
##records exists return not null
#if ($dt)
#{
# "dt is not null"
#}
#else
#{
# "dt is null"
#}
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Help required : Manipulating select output
#Last Post 09 Aug 2009 09:36 AM by Boolean_z. 2 Replies.
#AuthorMessages
#Boolean_z
#New Member
#
#Posts:2
#09 Aug 2009 08:37 AM
#Hi All, 
#Below is a typical code for getting result regarding SQL jobs 
#$srv.JobServer.Jobs | Where-Object {$_.IsEnabled -eq $TRUE} | Select Name,LastRunOutcome, LastRunDate 
#For sake of brevity I am not giving full code, in the above code srv is sql server. 
#What I need ? 
#I want to add a text before name of the job like- if job name is "Job - Truncate Table", i want it to be "MY - Job - Truncate Table". So I want to add "MY " before all job name. Please help.
#Mike Pfeiffer
#New Member
#
#Posts:28
#09 Aug 2009 09:17 AMAccepted Answer 
#Try this:
#$srv.JobServer.Jobs | Select @{n="Name";e={"My {0}" -f $_.name}},LastRunOutcome, LastRunDate
#Boolean_z
#New Member
#
#Posts:2
#09 Aug 2009 09:36 AM
#Great! works absolutely fine. 
# 
#Thanks a lot.. 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Confused about different State values
#Last Post 03 Aug 2009 06:35 AM by geedeearr. 3 Replies.
#AuthorMessages
#geedeearr
#New Member
#
#Posts:7
#29 Jul 2009 11:09 AM
#Hi All,
#(I'm using PowerGUI to write these scripts)                                             
#When I use the following to query Linked Servers,
#param (
#      [string]$ComputerName = "MyServerName"
#      )
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')  | out-null
# 
#$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName
#$ls = new-object Microsoft.SqlServer.Management.Smo.LinkedServer
# 
#$lss = $s.LinkedServers
#foreach ($ls in $lss) {
#      Write-Host "------------"
#      Write-Host "Name: "$ls.Name | Out-Null
#      Write-Host "DataSource: "$ls.DataSource | Out-Null
#      Write-Host "DateLastModified: "$ls.DateLastModified | Out-Null
#      Write-Host "Catalog: "$ls.Catalog | Out-Null
#      Write-Host "State: "$ls.State | Out-Null
#      Write-Host "DataAccess: "$ls.DataAccess | Out-Null
#      Write-Host "<><><><><><>"
#}
#$ls.State = Existing.
#However when I use this Insert statement into SQL Server
#$cmd.CommandText = "INSERT INTO DBServerLinkedServers(DBServerPKID, `
#                                                      NameAlias, `
#                                                      DataSource, `
#                                                      DateLastModified, `
#                                                      LinkedServerCatalog, `
#                                                      LinkedServerState, `
#                                                      LinkedServerDataAccess)
#                                    VALUES (@DBServerPKID, `
#                                                @Name, `
#                                                @DataSource, `
#                                                @DateLastModified, `
#                                                @Catalog, `
#                                                @State, `
#                                                @DataAccess);"
#$cmd.Connection = $conn
#$cmd.Parameters.AddWithValue("@DBServerPKID", $DBServerPKID) | Out-Null
#$cmd.Parameters.AddWithValue("@Name", $ls.Name) | Out-Null
#$cmd.Parameters.AddWithValue("@DataSource", $ls.DataSource) | Out-Null
#$cmd.Parameters.AddWithValue("@DateLastModified", $ls.DateLastModified) | Out-Null
#$cmd.Parameters.AddWithValue("@Catalog", $ls.Catalog) | Out-Null
#$cmd.Parameters.AddWithValue("@State", $ls.State) | Out-Null
#$cmd.Parameters.AddWithValue("@DataAccess", $ls.DataAccess) | Out-Null
#$cmd.ExecuteNonQuery() | Out-Null
#$ls.State = 2. 
#I know that the enumeration for existing is 2, but why the difference in the return value? 
#Is there something going on "under the hood" that I am obviously unaware?
#Thank you
#gdr
#Chad Miller
#Basic Member
#
#Posts:198
#29 Jul 2009 12:35 PM
#The underlying type of an emumeration is an int, just as the underlying type for a boolean is bit. If you want string you could call the ToString method on an emun. 
#In any case, why do you care about the state anyways? My understanding of state in SMO is that used internally and state will always be existing unless you haven't called the create method on certain SMO objects.
#geedeearr
#New Member
#
#Posts:7
#03 Aug 2009 06:35 AM
#---see next post----
#geedeearr
#New Member
#
#Posts:7
#03 Aug 2009 06:35 AM
#OK Thank you. 
#Since State is not a property to be concerned about (although it was not me who wanted to know about it) how about LoginMode? Or a couple of other parameters I know have this same result....that have these same characteristics. When called as in the first example of my post, 
#param ( 
#[string]$ComputerName = "MyComputer" 
#) 
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | out-null 
#$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName 
#Write-Host "------------" 
#Write-Host "LoginMode: " $s.LoginMode 
#Write-Host "------------" 
#it returns either "Integrated" or "Mixed". When inserting into a SQL Server database, 
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | out-null 
## For data acquisition - Create the SMO connection object 
#$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName 
## For data insert - Create SqlConnection object, define connection string, and open connection 
#$conn = New-Object System.Data.SqlClient.SqlConnection 
#$conn.ConnectionString = "Server=MyServer; Database=MyDatabase; Integrated Security=true" 
#$conn.Open() 
## For data insert - Create SqlCommand object, define command text, and set the connection 
#$cmd = New-Object System.Data.SqlClient.SqlCommand 
#$cmd.CommandText = "INSERT INTO DBServer(DBServerLoginMode) 
#VALUES (@LoginMode)" 
#$cmd.Connection = $conn 
#$cmd.Parameters.AddWithValue("@LoginMode", $s.Settings.LoginMode) | Out-Null 
## Execute INSERT statement 
#$cmd.ExecuteNonQuery() | Out-Null 
## Close the connections 
#$conn.Close() 
#it inserts 1 or 2. Of course I am inserting more parameters that just LoginMode) 
#You will also notice that when returning "Integrated" or "Mixed" I have NOT used ToString. I know about the enumeration and my question stands: "Why does this return different values as I can see no difference in what I've written?" 
#Thank you. 
#gdr
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Disk space alert through e-mail
#Last Post 03 Aug 2009 03:51 AM by Chad Miller. 1 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#03 Aug 2009 03:41 AM
#This is script below,
##array with the server name to check
# $serversToCheck="servername" 
##array tostore the results
# $results=@() 
##loop through the list of servers..... 
#foreach ($server in $serversToCheck) 
#{ 
##get information about the server logical disk drives(include only the drive,size and free space 
#$diskList=Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -computerName $server | select-Object -Property Name, Size, FreeSpace 
##loop through the server drives and add a few custom properties
# foreach ($disk in $diskList)
# {
# add-member -inputobject $disk -type noteproperty -name Machine -value $server; 
#add-member -inputobject $disk -type noteproperty -name PrecentFree -value ([long]$disk.freespace/[long]$disk.Size); 
#add-member -inputobject $disk -type scriptproperty -name Status -value 
#{
#if($this.PrecentFree -lt 0.20){"CRITTICAL"} elseif ($this.PrecentFree -lt 0.35) {"WARNING"}else{"OK"}}; #add the drive info to the result array $results += $disk; } } 
##return from the results only data for drives with status different than Ok
##format the output in table, grouped by server name, with size in GB 
#$badDisks = $results | where-object -filterScript {$-.Status -ne "OK"} 
##check if there are any disks which are running on low disk space 
#if ($badDisks) 
#{ 
##format the output (store it in a file) 
#$badDisks | format-table -groupBy Machine -Property
# @{lable="Drive";expression={$_.Name}}, 
#@{lable="Disk Size ";expression={"{0,7:N2} GB" -f ($_.Size / 1gb)}},
# @{lable="Free Space"; expression={"{0,72:N2} GB" -f($_.FreeSpace / 1gb)}}, 
#@{lable="Precent Free";expression={"{0,12:P}" -f $_.PrecentFree}}, 
#@{lable="Free Status";expression={$_.Status}} | out-file "D:\ananda\powershell\baddisk.txt" -encoding Unicode
# [string]$msg=get-content -path "D:\ananda\powershell\baddisks.txt" -encoding Unicode 
##send out an alert e-mail 
#$SmtpClient = new-object system.net.mail.smtpclient ("10.4.54.22") #$SmtpClient.host $From="Diskspacealert@ril.com" $to="ananda.murugesan@ril.com" $Title="Low disk space alert" $Body="The following drive are runnning low on diskspace 'n" + $msg $SmtpClient.send($from,$to,$title,$body) } 
#I could not able to correct this error, Pl can anyone help me .
#Error details:
#The term '$-.Status' is not recognized as a cmdlet, function, operable program, or script file. Verify the term and try again. At D:\DC\DiskspaceAlert.ps1:28 char:61 + $badDisks = $results | where-object -filterScript {$-.Status <<<< -ne "OK"} The term '$-.Status' is not recognized as a cmdlet, function, operable program, or script file. Verify the term and try again. At D:\DC\DiskspaceAlert.ps1:28 char:61 + $badDisks = $results | where-object -filterScript {$-.Status <<<< -ne "OK"}
#thanks
#Chad Miller
#Basic Member
#
#Posts:198
#03 Aug 2009 03:51 AM
#One problem I noticed is that you have a format before a select or foreach statement. The second problem you are missing a select or foreach 
#This line 
#$badDisks | format-table -groupBy Machine -Property 
#should be 
#$badDisk | Select 
#the format-table statement should be after the select and before the out-file 
#For the error, I don't see where status is being set to a value in your script. The where condition should be (you have a dash instead of an underline plus the filter script terms are not needed): 
#$results | where-object {$_.Status -ne "OK"} 
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Return Value = 0, should be newly inserted primary key
#Last Post 29 Jul 2009 10:36 AM by geedeearr. 4 Replies.
#AuthorMessages
#geedeearr
#New Member
#
#Posts:7
#20 Jul 2009 08:22 PM
#Hi All, 
#I'm extremely new at Powershell and not even close to an expert in ADO.NET, but I'm learning. In the following script, the Insert statement works, but the return value of the newly inserted Primary Key is not. Would someone be so kind to point out what I'm missing? 
#Thank you. 
#gdr 
##================================================================= 
##  Win32_ComputerSystem.ps1 
##================================================================= 
#param ( [string]$ComputerName = "MyRemoteComputer" 
#            ,[int]$NewCompPKID ) 
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | out-null 
#$CompSys = get-wmiobject -class "Win32_ComputerSystem" -namespace "root\CIMV2" -computername $ComputerName 
#$conn = New-Object System.Data.SqlClient.SqlConnection $conn.ConnectionString = "Server=MyServer; Database=MyDatabase; Integrated Security=true" 
#$conn.Open() 
#foreach ($property in $CompSys) { 
#$cmd = New-Object System.Data.SqlClient.SqlCommand 
#$cmd.CommandText = "INSERT INTO ComputerInformation(FullComputerName, ` 
#                                                                                               ComputerDescription, ` 
#                                                                                               ComputerSystemType, ` 
#                                                                                               ComputerManufacturer, ` 
#                                                                                               ComputerModel, ` 
#                                                                                               NumberProcessors, ` 
#                                                                                              TotalPhysicalMemory, ` 
#                                                                                              CompInfoEntryDate) 
#                                    VALUES (@Name, ` 
#                                                     @ComputerDescription, ` 
#                                                     @ComputerSystemType, ` 
#                                                     @ComputerManufacturer, ` 
#                                                     @ComputerModel, ` 
#                                                     @NumberProcessors, ` 
#                                                     @TotalPhysicalMemory, ` 
#                                                     @CompInfoEntryDate); ` 
#                                   SET @NewCompPKID = SCOPE_IDENTITY();" 
#$cmd.Connection = $conn 
#$CompInfoEntryDate = Get-Date 
#$cmd.Parameters.AddWithValue("@Name", $property.Name) | Out-Null 
#$cmd.Parameters.AddWithValue("@ComputerDescription", $property.Description) | Out-Null 
#$cmd.Parameters.AddWithValue("@ComputerSystemType", $property.SystemType) | Out-Null 
#$cmd.Parameters.AddWithValue("@ComputerManufacturer", $property.Manufacturer) | Out-Null 
#$cmd.Parameters.AddWithValue("@ComputerModel", $property.Model) | Out-Null 
#$cmd.Parameters.AddWithValue("@NumberProcessors", [Int32]$property.NumberOfProcessors) | Out-Null 
#$cmd.Parameters.AddWithValue("@TotalPhysicalMemory", [Int64]$property.TotalPhysicalMemory) | Out-Null 
#$cmd.Parameters.AddWithValue("@CompInfoEntryDate", $CompInfoEntryDate) | Out-Null 
#$cmd.Parameters.Add("@NewCompPKID", [System.Data.SqlDbType]"Int").Direction = [System.Data.ParameterDirection]::Output 
#$cmd.ExecuteNonQuery() | Out-Null 
#$NewCompPKID = $cmd.Parameters.("@NewCompPKID").Value } 
#$conn.Close() 
#Write-Host "------" 
#Return $NewCompPKID
#Chad Miller
#Basic Member
#
#Posts:198
#21 Jul 2009 05:17 AM
#I think the problem is this line: 
#$NewCompPKID = $cmd.Parameters.("@NewCompPKID").Value 
#should be 
#$NewCompPKID = $cmd.Parameters["@NewCompPKID"].value
#geedeearr
#New Member
#
#Posts:7
#22 Jul 2009 04:57 AM
#Thank you, but that errors with this message: 
#Cannot convert value "" to type "System.Int32". Error: "Object cannot be cast from DBNull to other types.".
#So it's still not returning the PK? 
#I have found that 
#$NewCompPKID = [Int32]$cmd.ExecuteScalar() 
#will return the proper PK and the Output parameter is not needed. 
#I have also changed 
#SET @NewCompPKID = SCOPE_IDENTITY() 
#to 
#SELECT SCOPE_IDENTITY() 
#But that doesn't change the error(s) though. 
#Thank you again. 
#gdr
#Chad Miller
#Basic Member
#
#Posts:198
#22 Jul 2009 06:38 AM
#Here's what I did to test and this works:
#--Create test table with identity column in SQL Server Management Studio
#CREATE TABLE [dbo].[test](
# [id] [int] IDENTITY(1,1) NOT NULL,
# [c1] [nchar](10) NOT NULL
#);
## Execute the following Powershell commands from Powershell
##My instance name is SQLEXPRESS an database name is dbutility
#$conn = New-Object System.Data.SqlClient.SqlConnection
#$conn.ConnectionString = "Server=$env:computername\SQLEXPRESS; Database=dbautility; Integrated Security=true" 
#$conn.Open() 
#$cmd = New-Object System.Data.SqlClient.SqlCommand 
#$cmd.CommandText = "INSERT INTO Test(c1) VALUES (@Name); SET @NewCompPKID = SCOPE_IDENTITY();" 
#$cmd.Connection = $conn 
#$Name = 'test'
#$cmd.Parameters.AddWithValue("@Name", $Name)
#$cmd.Parameters.Add("@NewCompPKID", [System.Data.SqlDbType]"Int").Direction = [System.Data.ParameterDirection]::Output 
#$cmd.ExecuteNonQuery()
#$cmd.Parameters["@NewCompPKID"].Value
#$conn.Close()
#geedeearr
#New Member
#
#Posts:7
#29 Jul 2009 10:36 AM
#Thank you. 
#Sorry for the delay in getting back to this. I've had other "fires" and was out of "computer contact" for 4 glorious days. 
#I see the differences and will give this a try at first chance. Thanks again. 
#gdr
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Text file attachement in body of mail and CC
#Last Post 27 Jul 2009 06:45 AM by Chad Miller. 5 Replies.
#AuthorMessages
#ananda
#New Member
#
#Posts:28
#22 Jul 2009 09:45 PM
#Hi Friends,
#I am new member of  powershellcommunity, 
#Auto send email alert when sql server services stopped unexpected. this script is working fine. but i could not able to attachement body of email in text file. In "D" drive i have created bodymsg.txt, can anyone help me how to add text file and send email CC copy to different mailid.
#$servers=get-content "D:\services\servers.txt" 
#foreach($server in $servers) {
# # go to each server and return the name and state of services 
## that are like "SQLAgent" and where their state is stopped
# # return the output as a string 
#$body=get-wmiobject win32_service -computername $server |
#select name,state | where {
#($_.name -like "MSSQLSERVER" -or $_.name -like "SQLSERVERAGENT*") ` -and $_.state -match "Stopped"} 
#if ($body.Length -gt 0) {
# #Create a .net mail client $smtp = new-object Net.Mail.SmtpClient("10.4.54.22")
# $subject="Microsoft SQL Service & SQL Agent Service is down on " + $server 
#$msg.body = (D:\services\BodyMsg.txt) 
#$smtp.Send("JERPCOKER@RIL.COM", "ananda.murugesan@ril.com", $subject, $body,$msg.body ) 
#"message sent" }
# } 
#Error :
#Property 'body' cannot be found on this object; make sure it exists and is settable. At D:\services\servicescheck1.ps1:21 char:8 + $msg. <<<< body = (D:\services\BodyMsg.txt) Cannot find an overload for "Send" and the argument count: "5". At D:\services\servicescheck1.ps1:22 char:13 + $smtp.Send <<<< ("JERPCOKER@RIL.COM", "ananda.murugesan@ril.com", $subject, $body,$msg.body) message sent
#Thanks
#Chad Miller
#Basic Member
#
#Posts:198
#23 Jul 2009 04:45 AM
#Looks like you are trying to use a MailMessage object, but forgot to create one in your code where you reference $msg.body. In order to send an attachment through the smtpClient you need to use a System.Net.Mail.MailMessage object. It often helps to read the MSDN document, look at the C# or VB.NET code samples and translate them to Powershell.
#http://msdn.microsoft.com/en-us/lib...ssage.aspx
#Here's what I came up with by doing just that. The code hasn't been tested...
#$from = new-object System.Net.Mail.MailAddress 'JERPCOKER@RIL.COM' 
#$to = new-object System.Net.Mail.MailAddress 'ananda.murugesan@ril.com'
#$msg New-Object System.Net.Mail.MailMessage ($from,$to) 
#$subject="Microsoft SQL Service & SQL Agent Service is down on " + $server 
#$msg.Subject = $subject 
#$attachment = New-Object System.Net.Mail.Attachment "D:\services\BodyMsg.txt" 
#$msg.Attachments.Add($attachment) 
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$smtp.Send($msg
#ananda
#New Member
#
#Posts:28
#25 Jul 2009 02:49 AM
#Hi, 
#Thanks for your reply.. 
#Your script attachement was working fine, but i need one more help from you. 
#Email Body out-string messages has comming, but i need out-string result with body message, please givel me how tto do? 
#$servers=get-content "D:\services\servers.txt" 
#foreach($server in $servers) 
#{ 
#$body=get-wmiobject win32_service -computername $server | 
#select name,state | 
#where {($_.name -like "MSSQLSERVER" -or $_.name -like "SQLSERVERAGENT*") ` 
#-and $_.state -match "Stopped"} | Out-String 
#--> here i want message like - 
#$txt= @*Message from JerpCoker Test Setup Server DFG12343, Microsoft SQLSERVER Services unexpected stopped, Please kindly check it ASAP and avoid downtime SQLSERVER. This is an auto generated mail notification from Micosoft SQLSERVER2005, Please do not reply.*@ 
#if ($body.Length -gt 0) 
#{ 
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="Microsoft SQL Service & SQL Agent Service is down on " + $server 
#$from="JerpCoker@ril.com" 
#$msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.To.add("ananda.murugesan@ril.com") 
#$msg.Subject = $subject 
#$msg.Body = $body 
#$Attachment = New-Object System.Net.Mail.Attachment "D:\services\BodyMsg.txt" 
#$msg.Attachments.Add($Attachment) 
#$msg.txt= $txt 
#$smtp.Send($msg) 
#} 
#} 
#Thanks 
#Chad Miller
#Basic Member
#
#Posts:198
#25 Jul 2009 05:34 AM
#Looking at the MailMessage class documentation there isn't a txt property i.e. $msg.txt in your script. Sounds like you want to set the body property to something like the example you've provided. You could do something like this:
#$servers=get-content "D:\services\servers.txt" 
#foreach($server in $servers) 
#{ 
#$body=get-wmiobject win32_service -computername $server |  
#where {($_.name -like "MSSQLSERVER" -or $_.name -like "SQLSERVERAGENT*") `
#-and $_.state -match "Stopped"} | select SystemName, Name
#}
#foreach ($item in $body)
#{ 
#$txt = @"
#*Message from JerpCoker Test Setup Server $($item.SystemName), Microsoft $($item.name) Services unexpected stopped, Please kindly check it ASAP and avoid downtime $($item.name). This is an auto generated mail notification from Micosoft SQLSERVER2005, Please do not reply.* 
#"@
#$smtp = new-object Net.Mail.SmtpClient("10.4.54.22") 
#$subject="Microsoft SQL Service & SQL Agent Service is down on " + $server 
#$from="JerpCoker@ril.com" 
#$msg = New-Object system.net.mail.mailmessage 
#$msg.From = $from 
#$msg.To.add("ananda.murugesan@ril.com") 
#$msg.Subject = $subject 
#$msg.Body = $txt
#$Attachment = New-Object System.Net.Mail.Attachment "D:\services\BodyMsg.txt" 
#$msg.Attachments.Add($Attachment) 
#$smtp.Send($msg) 
#} 
#ananda
#New Member
#
#Posts:28
#27 Jul 2009 01:24 AM
#Hi cmille19 thanks a lots, the above scripts is working fine.
#i created one batch file like 'servicecheck.bat', 
#this contain powershell.exe -command D:\services\FinalServiceCheck.ps1 and batch file configured at system schedule task when system starup event and batch file running always the shedule task.
#If whenever sql services stop and  batch file sending contunious email, i need recevied mail one time when service stop, so please give me suggestion how to control sequence mail alert and how to shedule batch file?
#Thanks.
#ananda
#Chad Miller
#Basic Member
#
#Posts:198
#27 Jul 2009 06:45 AM
#There are a few different ways to implement Alert suppression. Probably the easiest is to touch an empty file and then compare the LastWriteTime to whatever time threshold. Here's an example which assumes you've already created the lastupdate.txt file and sets the threshold to 60 minutes.
#$threshold = 60 
#foreach ($item in $body)
# ... 
#if ($(new-timespan $(get-childitem D:\services\lastupdate.txt).LastWriteTime $(get-date)).Minutes -gt $threshold) 
#{ 
#$smpt = new-object ... 
#$( get-childitem d:\services\lastupdate.txt).LastWriteTime = get-date
#$smpt.Send($msg) 
#}
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How to get SQL DB config details remotely?
#Last Post 23 Jun 2009 08:50 AM by Chad Miller. 3 Replies.
#AuthorMessages
#MattG
#New Member
#
#Posts:27
#23 Feb 2009 07:37 AM
#I have 2 Remote SQL 2000 servers that I want to get the following config info from:
#All running DB names
#DB filename/path
#Log File name/path
#DB/Log size
#Date Last backed up
#I have installed SQL 2008 Management Studio on my Powershell machine.
#Is there a way to get this info remotely from SQL 2000 servers with Powershell?   If not,  is this available remotely via SQL 2005/2008?
#Thanks,
#-MattG
#Chad Miller
#Basic Member
#
#Posts:198
#23 Feb 2009 08:58 AM
#You could use SQL Powershell Extensions (SQLPSX): http://www.codeplex.com/sqlpsx 
#$dbs = Get-SqlDatabase Z002 
#$dbs | Select Select Name, LastBackupDate 
#$dbs | Get-SqlDataFile 
#$dbs | Get-SqlLogFile 
#The call to Get-SqlDatabase will return a collection of all databases other than system databases for the server named Z002, the next three lines return the information you are requesting. 
#There are several of ways of getting this information in addition to using SQLPSX. You can issue T-SQL calls from Powershell, use the SMO classes directly, or use the SQL Server 2008 Provider to get the same information. If you'd like to use an alternative approach let me know and I'll post the code.
#HopeFoley
#New Member
#
#Posts:1
#23 Jun 2009 08:29 AM
#I have written my scripts generically enough to go against both 2000 and 2005 since I have both in several of my environments.  I have written one that loops through a text file that lists all the instances I want it to check.  Then here's a piece that grabs the number of databases and last backup date.  
#param 
#(
#  [string] $filename 
#)
#[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
#$computers = get-content $filename
#foreach ($computer in $computers) 
#{$con = "server=$computer;database=master;Integrated Security=sspi"
#  $cmdd = "SELECT COUNT(*) from sys.databases"
#  $db = new-object System.Data.SqlClient.SqlDataAdapter ($cmdd, $con)
#  $du = new-object System.Data.DataTable
#  $db.fill($du) | out-null
#$value2 = $du.Rows[0][0] 
#write-host "Number of databases: " $value2
#write-host "-----------------------------------"
#write-host " "
#write-host "Databases and Last Backup Info: "
#write-host "-----------------------------------"
#write-host " "
#$Server.Databases | Select-Object @{Name = '$computer';Expression = {$Server.name}}, name, lastbackupdate
#}
#Chad Miller
#Basic Member
#
#Posts:198
#23 Jun 2009 08:50 AM
#This is good use of Powershell, one suggestion
#You could get rid of your select count query by using the cmdlet measure-object to return number of databases:
#$measure = $Server.Databases | measure-object
#"Number of database: $($measure.count)"
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#How to get return value from a SQL store procedure
#Last Post 21 Jun 2009 04:33 AM by Gary. 2 Replies.
#AuthorMessages
#Gary
#New Member
#
#Posts:2
#17 Jun 2009 06:44 PM
#Hi, all 
#I am new to powershell, and practicing to use .net object in Powershell. 
#Now I can select/update/insert into SQL tables, but cannot get the return value, and output parameter from a store procedure. 
#Could someone please give me a sample script for these? 
#Thanks a lot, 
#Gary
#Chad Miller
#Basic Member
#
#Posts:198
#18 Jun 2009 12:13 PM
#Getting output and return parameters is a slightly more difficult, but here's an example: 
#I created procedure call InsertCategory in the Northwind database as follows: 
#CREATE PROCEDURE dbo.InsertCategory 
#@CategoryName nvarchar(15) 
#,@Identity int OUT 
#AS 
#SET NOCOUNT ON 
#INSERT INTO Categories (CategoryName) VALUES(@CategoryName) 
#SET @Identity = SCOPE_IDENTITY() 
#RETURN @@ROWCOUNT 
#And this is the Powershell script to call the procedure and obtain the output parameter and return values (change the serverName variable for your environment): 
#$serverName='Z002\SQL2K8' 
#$databaseName='Northwind' 
#$query='InsertCategory' 
#$catName='Test' 
#$connString = "Server=$serverName;Database=$databaseName;Integrated Security=SSPI;" 
#$conn = new-object System.Data.SqlClient.SqlConnection $connString 
#$conn.Open() 
#$cmd = new-object System.Data.SqlClient.SqlCommand("$query", $conn) 
#$cmd.CommandType = [System.Data.CommandType]"StoredProcedure" 
#$cmd.Parameters.Add("@RowCount", [System.Data.SqlDbType]"Int") 
#$cmd.Parameters["@RowCount"].Direction = [System.Data.ParameterDirection]"ReturnValue" 
#$cmd.Parameters.Add("@CategoryName", [System.Data.SqlDbType]"NChar", 15) 
#$cmd.Parameters["@CategoryName"].Value = $catName 
#$cmd.Parameters.Add("@Identity", [System.Data.SqlDbType]"Int") 
#$cmd.Parameters["@Identity"].Direction = [System.Data.ParameterDirection]"Output" 
#$cmd.ExecuteNonQuery() 
#$conn.Close() 
#$cmd.Parameters["@RowCount"].Value 
#$cmd.Parameters["@Identity"].Value
#Gary
#New Member
#
#Posts:2
#21 Jun 2009 04:33 AM
#Thank you so much, it works like a charm.
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Query SQL 2000 from Powershell V1
#Last Post 14 Jan 2009 09:25 AM by Shay Levy. 5 Replies.
#AuthorMessages
#SynJunkie
#Basic Member
#
#Posts:126
#14 Jan 2009 04:16 AM
#Hi
#I am trying to automate my leaver process and one of the last things I need to do is remove a record from a SQL table. I have found the following script on the web and I am able to use it to query a SQL database successfully  (as shown in example 1) but it will not delete a record using the syntax as shown in example 2.
#Example 1
#$Username = "ALFKI"
#$SqlServer = "sqlserver"
#$SqlCatalog = "Northwind"
#$SqlQuery = "Select * from dbo.customers where customerID='$Username'"
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True"
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
#$SqlCmd.CommandText = $SqlQuery
#$SqlCmd.Connection = $SqlConnection
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
#$SqlAdapter.SelectCommand = $SqlCmd
#$DataSet = New-Object System.Data.DataSet
#$SqlAdapter.Fill($DataSet)
#$SqlConnection.Close()
#Clear
#$DataSet.Tables[0]
#Example 2
#$Username = "ALFKI"
#$SqlServer = "sqlserver"
#$SqlCatalog = "Northwind"
#$SqlQuery = "Delete from dbo.customers where customerID='$Username'"
#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True"
#$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
#$SqlCmd.CommandText = $SqlQuery
#$SqlCmd.Connection = $SqlConnection
#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
#$SqlAdapter.SelectCommand = $SqlCmd
#$DataSet = New-Object System.Data.DataSet
#$SqlAdapter.Fill($DataSet)
#$SqlConnection.Close()
#Clear
#$DataSet.Tables[0]
#The error I recieve is:
#Unable to index into an object of type System.Data.DataTableCollection.
#At C:\scripts\SQL-TEST.ps1:17 char:17
#+ $DataSet.Tables[0 <<<< ]
#Does anyone know why one query would work but not another?
#Thanks
#Lee
#Shay Levy
#PowerShell MVP, Admin
#Veteran Member
#
#Posts:1362
#14 Jan 2009 05:53 AM
#I don;t have the time right now to delve into it but try this, it is much simpler: 
#$Username = "ALFKI" 
#$SqlServer = "sqlserver" 
#$SqlCatalog = "Northwind" 
#$SqlQuery = "Delete from dbo.customers where customerID='$Username'" 
#$connString = "Data Source=$sqlServer; Initial Catalog=$SqlCatalog; Integrated Security=SSPI" 
#$conn = New-Object System.Data.SqlClient.SqlConnection $connString 
#$sqlCommand = New-Object System.Data.SqlClient.sqlCommand $SqlQuery,$conn 
#$conn.open() 
#$cmd.ExecuteNonQuery() 
#$sqlCommand.ExecuteNonQuery() 
#Shay Levy
#Windows PowerShell MVP
#http://PowerShay.com
#PowerShell Community Toolbar
#Twitter: @ShayLevy
#Chad Miller
#Basic Member
#
#Posts:198
#14 Jan 2009 07:00 AM
#As to the reason why, the delete query does not return a DataTable (no result set). You would see a similar error message if you referenced an non-existent array element i.e. $z[0]. I've tested your delete statement and it does complete using your original code, the $DataSet.Tables[0] line causes an error, however the delete completes. 
#As Shay pointed out, the preferred method is to use ExecuteNonQuery for queries which do not return a result set. 
#SynJunkie
#Basic Member
#
#Posts:126
#14 Jan 2009 08:36 AM
#Thanks for the suggestions but I still recieve an error.
#You cannot call a method on a null-valued expression.
#At C:\scripts\sqlv2.ps1:11 char:21
#+ $cmd.ExecuteNonQuery( <<<< )
#Any other ideas?
#Chad Miller
#Basic Member
#
#Posts:198
#14 Jan 2009 09:11 AM
#There is an error on this line:
#$cmd.ExecuteNonQuery()
#it should be:
#$sqlcommand.ExecuteNonQuery()
# 
#Shay Levy
#PowerShell MVP, Admin
#Veteran Member
#
#Posts:1362
#14 Jan 2009 09:25 AM
#Thanks Chad, bad paste :-)
#Shay Levy
#Windows PowerShell MVP
#http://PowerShay.com
#PowerShell Community Toolbar
#Twitter: @ShayLevy
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
#####################
# 
#Forums > Using PowerShell > SQL Server
#Using SMO with PowerShell
#Last Post 15 Dec 2008 04:46 PM by halr9000. 3 Replies.
#AuthorMessages
#tfl
#Director
#Senior Member
#
#Posts:7
#24 Nov 2008 10:12 AM
#I'm glad Hal has created a SQL Forum. I've been looking into the SMO objects and can't quite get to grips with them. 
#All clues are welcome!
#Chad Miller
#Basic Member
#
#Posts:198
#24 Nov 2008 11:28 AM
#I've done a lot work with SMO + Powershell posting the scripts on CodePlex. Check out http://www.codeplex.com/SQLPSX
#Paul Chen
#New Member
#
#Posts:6
#15 Dec 2008 02:34 PM
#Posted By cmille19 on 24 Nov 2008 12:28 PM 
#... Check out http://www.codeplex.com/SQLPSX
#Here in his blog (http://chadwickmiller.spaces.live.c...ult.aspx), introduces his new release 1.3 (SQLPSX) and provides a few example of working with SQL Server Replication through RMO. Cheers
#halr9000
#PowerShell MVP, Site Admin
#Advanced Member
#
#Posts:565
#15 Dec 2008 04:46 PM
#Also check out when we interviewd Chad (cmille19) on the podcast. 
#http://powerscripting.wordpress.com...6-sql-psx/
#Community Director, PowerShellCommunity.org
#Co-host, PowerScripting Podcast
#Author, TechProsaic
#Forums > Using PowerShell > SQL Server
# 
#Active Forums 4.3
#  
