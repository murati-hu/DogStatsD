. (Join-Path $PSScriptRoot '../TestCommon.ps1')

$scriptSources = Get-ChildItem -Path $script:FunctionPath -Filter '*.ps1' -Recurse
$excludeRuleList = @()

if (-Not (Get-Module PSScriptAnalyzer -ListAvailable)) {
    try {
        Write-Verbose "Trying to install PSScriptAnalyzer.."
        PowershellGet\Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
    } catch {
        Write-Error $_
    }
}

if (-Not (Get-Module PSScriptAnalyzer -ListAvailable)) {
    Write-Warning "PSScriptAnalyzer module is not available. Skipping tests."
    return
}

Describe "Script Source analysis" {
    Import-Module PSScriptAnalyzer

    $scriptSources | ForEach-Object {
        Context "Source $($_.FullName)" {
            $results = Invoke-ScriptAnalyzer -Path $_.FullName -ErrorVariable $errors -ExcludeRule $excludeRuleList

            it "should have no errors" {
                $errors | Should BeNullOrEmpty
            }

            it "should not have warnings" {
                $results |
                Where-Object Severity -eq "Warning" |
                Should BeNullOrEmpty
            }

        }
    }
}
