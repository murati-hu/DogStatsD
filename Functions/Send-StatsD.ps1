<#
.SYNOPSIS
    Sends data to a statsd UDP service endpoint
.DESCRIPTION
    PowerShell function to send UDP data to a statsd endpoint,
    like DogStatsD service in a ASCII encoded byte-format.

    The function supports the basic -Verbose and -Debug
    cmdletbindings.
.PARAMETER Data
    Mandatory - String data to be sent to the statsD service
.PARAMETER ComputerName
    Optional - ComputerName (Hostname or IPaddress) of the
    target statsd service
        Default is 127.0.0.1 for localhost
.PARAMETER Port
    Optional - Port for the target statsd service
        Default is 8125
.EXAMPLE
    Send-StatsD -Data 'sample_gauge:1985|g'
.EXAMPLE
    'sample_gauge:1985|g' | Send-StatsD
.EXAMPLE
    Send-StatsD -Data 'sample_histogram:12|h' -ComputerName '192.168.0.20'
.EXAMPLE
    Send-StatsD -Data 'sample_histogram:12|h' -ComputerName '192.168.0.20' -Port 8128
#>

function Send-StatsD {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Data,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName='127.0.0.1',

        [Parameter()]
        [ValidateRange(1,65535)]
        [int]$Port=8125
    )

    Write-Verbose "Targeting $($ComputerName):$Port UDP endpoint.."
    $UdpClient = New-Object System.Net.Sockets.UdpClient($ComputerName, $Port)

    try {
        Write-Debug "Encoding data:`n$Data"
        $bytes=[System.Text.Encoding]::ASCII.GetBytes($Data)

        Write-Debug "Sending Encoded Data: `n$bytes"
        if ($PSCmdlet.ShouldProcess($ComputerName, "Sending $($bytes.Count) bytes.")) {
            $sent=$UdpClient.Send($bytes,$bytes.length)
            Write-Debug "Data Length sent: $sent"
        }
        $UdpClient.Close()
    } catch {
        Write-Error $_
    } finally {
        $UdpClient.Dispose()
    }

    $UdpClient = $null
}
