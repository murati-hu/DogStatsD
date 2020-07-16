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
.EXAMPLE
    1..20000 | Send-DataDogMetric -Type Counter -Name 'incrementing.value' -Value { $_ }
.EXAMPLE
    Get-AppStatistics | Send-DataDogMetric -Type Gauge -Name 'appco.active_users' -Value { $_.ActiveUsers }
.EXAMPLE
    Get-Process |
        Send-DataDogMetric -Name 'server.process.handles' -Type Counter -Value { $_.Handles } -Tag { @("process:$($_.ProcessName)","pid:$($_.Id)") }
#>
function Send-DataDogMetric {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('MetricName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('MetricValue')]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('MetricType')]
        [ValidateSet('Counter','Gauge','Histogram','Timer','Set','Distribution')]
        [string]$Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter()]
        [ValidateRange(1,65535)]
        [int]$Port,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('MetricSampleRate')]
        [string]$SampleRate='1',

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('MetricTag')]
        [Alias('MetricTags')]
        [string[]]$Tag=@()
    )

    Begin {
        $statsdParams = @{
            Verbose = $VerbosePreference -as [bool]
            Debug = $DebugPreference -as [bool]
        }
        if ($ComputerName) {
            $statsdParams.ComputerName = $ComputerName
        }
        if ($Port) {
            $statsdParams.Port = $Port
        }

        # start a steppable pipeline for Send-StatsD so we can ensure we use a single UDP socket across the pipeline
        $sendStatsD = { Send-StatsD @statsdParams }.GetSteppablePipeline($MyInvocation.CommandOrigin)
        $sendStatsD.Begin($true)
    }

    Process {
        $ddType = if ($Type -eq 'Timer') {
            'ms'
        }
        else {
            $Type.ToLower()[0]
        }

        $tagData = [string]::Join(',', $Tag)
        $data = "${Name}:${Value}|${ddType}|@${SampleRate}|#${tagData}"

        if ($PSCmdlet.ShouldProcess($data)) {
            $sendStatsD.Process($data)
        }
    }

    End {
        $sendStatsD.End()
    }
}
