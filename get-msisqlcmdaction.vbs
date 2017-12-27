Option Explicit
Const msiOpenDatabaseModeReadOnly = 0
Dim installer : Set installer = Nothing
Dim WshShell : Set WshShell = CreateObject("Wscript.Shell")
Dim szMSI : szMSI = WScript.Arguments.Item(0)
Dim folder : folder = WshShell.CurrentDirectory
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") 
Dim database : Set database = installer.OpenDatabase(szMSI, msiOpenDatabaseModeReadOnly) 
Dim View, Record
Set View = database.OpenView("SELECT Target FROM CustomAction WHERE Action = 'sqlcmd.cmd'")
View.Execute
Do
 Set Record = View.Fetch
 If Record Is Nothing Then Exit Do
 Wscript.Echo Record.StringData(1)
Loop
Set View = Nothing
Wscript.Quit(0)
