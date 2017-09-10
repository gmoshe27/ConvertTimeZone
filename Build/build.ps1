# Taken from https://github.com/RamblingCookieMonster/PSDepend/blob/master/psake.ps1

param ($Task = 'Default', [switch] $ForceDeploy)

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module Psake -force
Install-Module Pester -Force -SkipPublisherCheck
Import-Module Psake

Invoke-psake -buildFile $PSScriptRoot\psake.ps1 -taskList $Task -nologo -parameters @{"ForceDeploy" = $ForceDeploy.IsPresent }
exit ( [int]( -not $psake.build_success ) )