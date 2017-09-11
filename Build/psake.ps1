
Properties {
    $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
    $PSVersion = $PSVersionTable.PSVersion.Major
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = "----------------------------------------------------------------------"
    $newLine = "`n"
}

Task Default -Depends Test

Task Test {
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

    $IsTagged = $env:APPVEYOR_REPO_TAG -eq $true
    $HostIsAppveyor = $env:APPVEYOR -eq $true

    "Deploying to powershell gallery due to tag - $env:APPVEYOR_REPO_TAG_NAME"
    Publish-Module -Path $ProjectRoot\LocalToUtc -NugetApiKey $ENV:NugetApiKey

    $newLine
}