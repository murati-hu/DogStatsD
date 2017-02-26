
<#
.SYNOPSIS
    Sends an event to DataDog
.DESCRIPTION
    PowerShell cmdlet to send events to DataDog via DogStatsD
    UDP datagram. Format as per described at:
     - http://docs.datadoghq.com/guides/dogstatsd/#events-1

.PARAMETER Title
    Mandatory Title of the Event
.PARAMETER Text
    Optional Event body text
.PARAMETER AlertType
    Optional type of the event: 
        'info','success','warning','error'
    Default is info
.PARAMETER Priority
    Priority of the event: normal or low
.PARAMETER Tag
    List of tag definitions for the metric in "tagname:value" format
.EXAMPLE
    Send-DataDogEvent -Title 'My event' -Text 'Add any details' -Tag @("subsytem:my_test_tag1")
#>
function Send-DataDogEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter()]
        [string]$Text='',

        [Parameter()]
        [datetime]$DateTime=$(Get-Date),

        [Parameter()]
        [string]$ComputerName=$(hostname),

        [Parameter()]
        [ValidateSet('normal','low')]
        [string]$Priority='normal',

        [Parameter()]
        [string]$SourceType,

        [Parameter()]
        [ValidateSet('info','success','warning','error')]
        [string]$AlertType='info',

        [Parameter()]
        [string[]]$Tag=@()
    )
    Send-StatsD "_e{$($Title.Length),$($Text.Length)}:$Title|$Text|h:$ComputerName|p:$Priority|t:$AlertType|#$([string]::Join(',',$Tag))"
}