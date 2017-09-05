#Requires -Module Pester

if ((Get-Module).Name -contains 'LocalToUtc') {
    Remove-Module -Name LocalToUtc
}

Import-Module "$PSScriptRoot\LocalToUtc.psm1"

Describe 'LocalToUtc' {
    $testTime = "2017-09-04 08:25:00"
    
    It 'Parses ISO8601 properly' {
        $result = Convert-LocalToUTC -LocalTime $testTime
        $expected = [System.DateTime]::Parse($testTime)
        $result.LocalTime | Should Be $expected
    }

    It 'Converts local time to UTC time when the local time is defined' {
        $result = Convert-LocalToUTC -LocalTime $testTime -TimeZone "Eastern Standard Time"
        $expectedUtc = [System.DateTime]::Parse($testTime).AddHours(4)
        $expectedLocal = [System.DateTime]::Parse($testTime)
        $result.UtcTime | Should Be $expectedUtc
        $result.LocalTime | Should Be $expectedLocal
    }

    It 'Treats the current local time as the specified timezone local time' {
        # UTC is "2017-09-04 08:25:00"
        # EST is "2017-09-04 04:25:00" -4
        # PST is "2017-09-04 01:25:00" -3

        $expectedUtc = [System.DateTime]::Parse($testTime)
        $expectedLocal = [System.DateTime]::Parse($testTime).AddHours(-7) # PDT is 7 hours behind UTC (daylight savings)

        Mock Get-TimeZone {
            $est = Get-TimeZone "Eastern Standard Time"
            return $est
        }
        Mock Get-UtcTime {
            $utcTime = [System.DateTime]::Parse($testTime)
            $utc = [System.DateTime]::SpecifyKind($utcTime, [System.DateTimeKind]::Utc)
            return $utc
        }

        $result = Convert-LocalToUTC -TimeZone "Pacific Standard Time"
        $result.UtcTime | Should Be $expectedUtc
        $result.LocalTime | Should Be $expectedLocal
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
        $result = Convert-UTCToLocal -UtcTime $testTime
        $expected = [System.DateTime]::Parse($testTime)
        $result.UtcTime | Should Be $expected
    }

    It 'Converts UTC time to local time correctly' {
        $result = Convert-UTCToLocal -UtcTime $testTime -TimeZone "Eastern Standard Time"
        $expected = [System.DateTime]::Parse($testTime).AddHours(-4)
        $result.LocalTime | Should Be $expected
    }

    It 'Adds hours, minutes, seconds correclty' {
        $result = Convert-UTCToLocal -UtcTime $testTime -AddDays 1 -AddHours 2 -AddMinutes 3
        $expected = [System.DateTime]::Parse($testTime).AddDays(1).AddHours(2).AddMinutes(3)
        $result.UtcTime | Should Be $expected
    }
}

Remove-Module -Name LocalToUtc