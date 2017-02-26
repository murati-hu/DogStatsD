# Load module from the local filesystem, instead from the ModulePath
Remove-Module DogStatsD -Force -ErrorAction SilentlyContinue
Import-Module (Split-Path $PSScriptRoot -Parent)

$Script:ModuleName = 'DogStatsD'
$script:FunctionPath = Resolve-Path (Join-Path $PSScriptRoot '../Functions')
