
Properties {
    $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
    $PSVersion = $PSVersionTable.PSVersion.Major
    $lines = "----------------------------------------------------------------------"
    $newLine = "`n"
}

Task Default -Depends Test

Task Test {
    $lines
    "STATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru

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

    "Deploying to powershell gallery due to tag - $env:APPVEYOR_REPO_TAG_NAME"
    Publish-Module -Path $ProjectRoot\LocalToUtc -NugetApiKey $ENV:NugetApiKey

    $newLine
}