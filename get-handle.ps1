$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
&"$scriptRoot\handle.exe" | foreach {
              if ($_ -match '^(?<program>\S*)\s*pid: (?<pid>\d*)\s*(?<user>.*)$') {
                $matches | %{$id = $_.pid; $program = $_.program; $user = $_.user}}
                if ($_ -match '^\s*(?<handle>[\da-z]*): File  \((?<attr>...)\)\s*(?<file>(\\\\)|([a-z]:).*)') { 
                 $matches | select @{n="Pid";e={$id}}, @{n="Program";e={$program}}, @{n="User";e={$user}}, @{n="Handle";e={$_.handle}}, @{n="attr";e={$_.attr}}, @{n="FullName";e={$_.file}}}} 
