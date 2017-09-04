#Requires -Module Pester

if ((Get-Module).Name -contains 'LocalToUtc') {
    Remove-Module -Name LocalToUtc
}

Import-Module "$PSScriptRoot\LocalToUtc.psm1"

Describe 'LocalToUtc' {
    $testTime= "2017-09-04 08:25:00"
    
    It 'Parses ISO8601 properly' {
        $result = Convert-LocalToUTC -LocalTime $testTime
        $expected = [System.DateTime]::Parse($testTime)
        $result.LocalTime | Should Be $expected
    }

    It 'Converts local time to UTC time correctly' {
        $result = Convert-LocalToUTC -LocalTime $testTime -TimeZone "Eastern Standard Time"
        $expected = [System.DateTime]::Parse($testTime).AddHours(4)
        $result.UtcTime | Should Be $expected
    }

    It 'Adds hours, minutes, seconds correclty' {
        $result = Convert-LocalToUTC -LocalTime $testTime -AddDays 1 -AddHours 2 -AddMinutes 3
        $expected = [System.DateTime]::Parse($testTime).AddDays(1).AddHours(2).AddMinutes(3)
        $result.LocalTime | Should Be $expected
    }
}

Describe 'UtcToLocal' {
    $testTime= "2017-09-04 08:25:00"
    
    It 'Parses ISO8601 properly' {
        $result = Convert-UTCToLocal -UTCTime $testTime
        $expected = [System.DateTime]::Parse($testTime)
        $result.UTCTime | Should Be $expected
    }

    It 'Converts UTC time to local time correctly' {
        $result = Convert-UTCToLocal -UTCTime $testTime -TimeZone "Eastern Standard Time"
        $expected = [System.DateTime]::Parse($testTime).AddHours(-4)
        $result.LocalTime | Should Be $expected
    }

    It 'Adds hours, minutes, seconds correclty' {
        $result = Convert-UTCToLocal -UTCTime $testTime -AddDays 1 -AddHours 2 -AddMinutes 3
        $expected = [System.DateTime]::Parse($testTime).AddDays(1).AddHours(2).AddMinutes(3)
        $result.UTCTime | Should Be $expected
    }
}

Remove-Module -Name LocalToUtc