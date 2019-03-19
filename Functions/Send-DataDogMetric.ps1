<#
.SYNOPSIS
    Sends a metric value to DataDog
.DESCRIPTION
    PowerShell cmdlet to send a metric value to DogStatsD
    in a DataDog specific format as per described at:
     - http://docs.datadoghq.com/guides/dogstatsd/#metrics-1

.PARAMETER Name
    Mandatory Name of the metric
.PARAMETER Value
    Mandatory metric value
.PARAMETER SampleRate
    Optional Sampling rate, default is 1
.PARAMETER Type
    Mandatory type of the data to be sent:
        'Counter','Gauge','Histogram','Timer','Set'
.PARAMETER Tag
    List of tag definitions for the metric in "tagname:value" format
.PARAMETER ComputerName
    Optional - ComputerName (Hostname or IPaddress) of the
    target statsd service
        Default is 127.0.0.1 for localhost
.PARAMETER Port
    Optional - Port for the target statsd service
        Default is 8125
.EXAMPLE
    Send-DataDogMetric -Type Histogram -Name 'command.duration' -Value 12 -Tag @("command:my_command_name")
.EXAMPLE
    Send-DataDogMetric -Type Gauge -Name 'random.value' -Value $randomvalue -ComputerName 192.168.0.1 -Port 8125
#>
function Send-DataDogMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory)]
        [ValidateSet('Counter','Gauge','Histogram','Timer','Set')]
        [string]$Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName=$(hostname),

        [Parameter()]
        [ValidateRange(1,65535)]
        [int]$Port=8125,

        [Parameter()]
        [string]$SampleRate='1',

        [Parameter()]
        [string[]]$Tag=@()

    )
    $ddType=($Type.ToLower())[0]
    switch ($Type) {
        'Timer' { $ddType = 'ms' }
        'Set' { $ddType = 's' }
    }
    if (-Not $ddType) { Write-Error "$Type is not a valid metricstype" }
    Send-StatsD -Data "$($Name):$($Value)|$ddType|@$SampleRate|#$([string]::Join(',',$Tag))" -ComputerName $ComputerName -Port $Port
}
