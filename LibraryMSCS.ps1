# ------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller 
### </Author>
### <Description>
### Defines functions for working with Microsoft Cluster Service (MSCS)
### </Description>
### <Usage>
### . ./LibraryMSCS.ps1
### </Usage>
### </Script>
# ------------------------------------------------------------------------

#######################
function Get-ClusterList
{
    $cmd = `cluster.exe /LIST`

    for ( $i=3; $i -le ($cmd.length - 1); $i++)
    {
        if ( $cmd[$i] -match '\w+' )
        { $cmd[$i].TrimEnd() }
    }

} #Get-ClusterList

#######################
function Get-ClusterToNode
{
    foreach ($cluster in $input) { 
        trap {Write-Error "Cannot connect to $i.";continue} 
        Get-WmiObject -class MSCluster_Node -namespace "root\mscluster" -computername $cluster |
        add-member noteproperty Cluster $cluster -pass | select Cluster, Name 
    }

} #Get-ClusterToNode

#######################
function Get-ClusterToVirtual
{
    foreach ($cluster in $input) { 

        $pv = '.*VirtualServerName\s+(?<virtual>\w+$)'
        $pi = '.*InstanceName\s+(?<instance>\w+$)'
        $seen = @()

        $cmd = cluster.exe $cluster res /Priv | select-string "VirtualServerName|InstanceName"

        for ( $i=0; $i -le ($cmd.length - 1); $i++)
        {
            if ( $cmd[$i] -match $pv )
            {
                $virtual = $matches.virtual
                
                $cmd[$i+1] -match $pi > $null
                $instance = $matches.instance 

                if (!($seen -contains $virtual))
                {
                    $seen += $virtual 
                    new-object psobject |
                    add-member -pass NoteProperty Cluster $cluster |
                    add-member -pass NoteProperty Virtual $virtual |
                    add-member -pass NoteProperty Instance $instance
                }


            }
        }   
    }

} #Get-ClusterToVirtual

#######################
function Get-ClusterPreferredNode
{
    param($cluster)

    # $prfHash = @{}
    # Get-ClusterPreferredNode "." | where {$_.order -eq 1} | foreach { $prfHash[$_.groupname] = $_.node }
    # $prfHash.keys | foreach { cluster . group "$_" /online:$prfHash."$_" /wait }
    #cluster . group /status
    
    #get-content ./clusters.txt | foreach {Get-ClusterPreferredNode $_}
    
    #get-content ./clusters.txt | foreach {Get-ClusterPreferredNode $_} | where {$_.order -eq 1}
    
    $pg = 'MSCluster_ResourceGroup.Name="(?<group>[^"]+)'
    $pn = 'MSCluster_Node.Name="(?<node>[^"]+)'

    get-wmiobject -class MSCluster_ResourceGroupToPreferredNode -namespace "root\mscluster" -computername $cluster |
        select groupcomponent, partcomponent | 
        foreach {   if ($_.GroupComponent -match $pg) {
                                                        add-member -in $_ -membertype noteproperty clustername $cluster
                                                        add-member -in $_ -membertype noteproperty groupname $matches.group
                                                        if ($grp -ne $matches.group)
                                                            { $i = 1; $grp = $matches.group}
                                                        else
                                                            { $i++ }
                                                        add-member -in $_ -membertype noteproperty order $i

                                                      } 
                    if ($_.PartComponent  -match $pn) {add-member -in $_ -membertype noteproperty node $matches.node -passthru}
                } | select clustername, order, groupname, node

} #Get-ClusterPreferredNode

#######################
function Get-ClusterGroup
{
    param($cluster)

    #$grpArray = @()
    #get-clustergroup . | where {$_.groupname  -notlike "Cluster*"} | foreach {$grpArray += $_.groupname}
    #$grpArray | foreach { cluster . group "$_" /offline /wait}
    #cluster . group /status

    $p = '(?<group>^\w+\s?\w*)\s+(?<node>\w+)\s+(?<status>\w+$)' 
    $cmd = `cluster $cluster group`

    for ( $i=8; $i -le ($cmd.length - 1); $i++)
    {
        if ( $cmd[$i] -match $p )
        {
            new-object psobject |
            add-member -pass NoteProperty groupname $matches.group.TrimEnd() |
            add-member -pass NoteProperty node $matches.node |
            add-member -pass NoteProperty status $matches.status
        }
    }

} #Get-ClusterGroup