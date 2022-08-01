<#
.SYNOPSIS
    Ping multiple machines simultaneously.
.DESCRIPTION
    This function uses the .Net SendPingAsync method to ping a list of computers, and then return an object containing the name given, the address that name resolved to, and the status of the ping.
.EXAMPLE
    PS C:\> $list = @("leonw6testwk001","leonw6testwk002")
    PS C:\> test-asyncping $list
    An array of hostnames is saved as an array, and passed as the first input to test-asyncping.
.EXAMPLE
    PS C:\> @("leonw6testwk001","leonw6testwk002") | test-asyncping -onlineonly
    An array of hostnames is piped to test-asyncping, which will return an object containing only entries for hosts that responded to ping.
.INPUTS
    A string array of hostnames.
.OUTPUTS
    An array of objects with Name, Address, and Status properties.
#>
function Test-AsyncPing {
    [CmdletBinding()]
    param (
        # A list of hostnames to ping.
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [string[]]
        $Address,
        # Switch to filter out any results that did not respond to ping.
        [switch]
        $OnlineOnly
    )
    begin{
        $results = @()
        $tasklist = @()
    }
    process{
        foreach ($hostname in $address) {
            Write-Verbose "Pinging $hostname"
            $Tasklist += [PSCustomObject]@{
                Name = $hostname;
                Ping = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($hostname)
            }
        }
    }
    end{
        Write-Verbose "Waiting on tasks to finish."
        [Threading.Tasks.Task]::WaitAll()
        foreach ($task in $tasklist) {
            Write-Verbose "Retreiving results from $($task.name)"
            $results += [PSCustomObject]@{
                Name = $task.name;
                Address = $task.ping.result.address;
                Status = $task.ping.result.status
            }
        }
        if($OnlineOnly){$results = $results | ?{$_.status -eq "Success"}}
        $results

    }
    
}