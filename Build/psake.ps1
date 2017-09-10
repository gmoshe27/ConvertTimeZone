
Properties {
    $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
    $PSVersion = $PSVersionTable.PSVersion.Major
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = "----------------------------------------------------------------------"
    $newLine = "`n"
}

Task Default -Depends Deploy

Task Init {
    $lines
    "init"
    
    $newLine
}

Task Test -Depends Init {
    $lines
    "STATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
    
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }

    $newLine
}

Task Deploy -Depends Test {
    $lines

    # we only build if we are on appveyor and the build was a result of a tag
    $deploy = $env:APPVEYOR_REPO_TAG -eq $true

    # Only deploy if we are on AppVeyor
    if ($env:APPVEYOR -eq $true -and $deploy) {
        Publish-Module -Name LocalToUtc -NugetApiKey $ENV:NugetApiKey
    }

    $newLine
}