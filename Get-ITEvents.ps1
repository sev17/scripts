#######################
<#
.SYNOPSIS
Get IT Events calendar items.
.DESCRIPTION
The Get-ITEvents.ps1 script get IT event for one year in past and one year in future. Returns name and start datetime
.EXAMPLE
./get-itevents.ps1
.NOTES
Version History
v1.0   - Chad Miller - 3/30/2017 - Initial release
#>

Add-Type -AssemblyName Microsoft.Office.Interop.Outlook

$class = @”
using System;
using System.Collections;
using Microsoft.Office.Interop.Outlook;

public class MyOL
{
    public ArrayList GetCalendar(string userName)
    {
        Application oOutlook = new Application();
        NameSpace oNs = oOutlook.GetNamespace("MAPI");
        Recipient oRep = oNs.CreateRecipient(userName);
        MAPIFolder calendar = oNs.GetSharedDefaultFolder(oRep, OlDefaultFolders.olFolderCalendar);
        Items items = calendar.Items;
        items.IncludeRecurrences = true;
        items.Sort("[Start]");
        DateTime start = DateTime.Now.AddDays(-365);
        DateTime end = DateTime.Now.AddDays(365);
        string filter = "[Start] >= '" + start.ToString("g") + "' AND [Start] <= '" + end.ToString("g") + "'";
        Items restrictItems =  items.Restrict(filter);
        ArrayList list = new ArrayList();
        foreach( AppointmentItem item in restrictItems )
        {
         list.Add(item.Subject + '|' + item.Start);   
         
        }
        return list;
    }
}
“@

Add-Type $class -ReferencedAssemblies Microsoft.Office.Interop.Outlook
$outlook = New-Object MyOL
$calendar = $outlook.GetCalendar("IT Events")
$calendar | ConvertFrom-Csv -Header subject,start -Delimiter "|" | select subject, @{n='start';e={[datetime]$_.start}}