# Taken from https://github.com/RamblingCookieMonster/PSDepend/blob/master/psake.ps1

param ($Task = 'Default', [switch] $ForceDeploy)

if ($env:APPVEYOR -eq $true) {
    # Grab nuget bits, install modules, set build variables, start build.
    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

    Install-Module Psake -force
    Install-Module Pester -Force -SkipPublisherCheck
    Import-Module Psake

    # Only deploy if the host is appveyor and the build was a result of a tag
    $IsTagged = $env:APPVEYOR_REPO_TAG -eq $true
    if ($HostIsAppveyor -and $IsTagged) {
        $Task = "Deploy"
    }
}

Invoke-psake -buildFile $PSScriptRoot\psake.ps1 -taskList $Task -nologo
exit ( [int]( -not $psake.build_success ) )