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
.EXAMPLE
    Send-DataDogMetric -Type Histogram -Name 'command.duration' -Value 12 -Tag @("command:my_command_name")
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
    Send-StatsD "$($Name):$($Value)|$ddType|@$SampleRate|#$([string]::Join(',',$Tag))"
}
