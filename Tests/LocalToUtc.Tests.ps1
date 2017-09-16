﻿#Requires -Module Pester

if ((Get-Module).Name -contains 'LocalToUtc') {
    Remove-Module -Name LocalToUtc
}

Remove-Module -Name LocalToUtc -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\LocalToUtc\LocalToUtc.psm1"

Describe 'LocalToUtc' {
    $testTime = "2017-09-04 08:25:00"

    Context 'Time Conversion' {
        It 'Parses ISO8601 properly' {
            $result = Convert-LocalToUTC -Time $testTime -Verbose
            $expected = Get-Date $testTime
            $result.LocalTime | Should Be $expected
        }

        It 'Converts local time to UTC time when the local time is defined' {
            $result = Convert-LocalToUTC -Time $testTime -TimeZone "Eastern Standard Time" -Verbose
            $expectedUtc = (Get-Date $testTime).AddHours(4)
            $expectedLocal = Get-Date $testTime
            $result.UtcTime | Should Be $expectedUtc
            $result.LocalTime | Should Be $expectedLocal
        }

        It 'Treats the current local time as the specified timezone local time' {
            # UTC is "2017-09-04 08:25:00"
            # CST is "2017-09-04 03:25:00" -5
            # PST is "2017-09-04 01:25:00" -7

            Mock -ModuleName LocalToUtc Invoke-GetTimeZone {
                return "Central Standard Time"
            }
            Mock -ModuleName LocalToUtc Get-UtcTime {
                $utcTime = Get-Date "2017-09-04 08:25:00"
                $utc = [System.DateTime]::SpecifyKind($utcTime, [System.DateTimeKind]::Utc)
                return $utc
            }
            Mock -ModuleName LocalToUtc Get-LocalTime {
                $cstTime = "2017-09-04 03:25:00"
                $localTime = Get-Date $cstTime
                return $localTime
            }

            # TODO - When not setting $Time, convert the current time to the timezone
            # local time.
            
            $utcTime = "2017-09-04 08:25:00"
            $pstTime = "2017-09-04 01:25:00" # PDT is 7 hours behind UTC (daylight savings)
            $expectedUtc = Get-Date $utcTime
            $expectedLocal = Get-Date $pstTime

            $result = Convert-LocalToUTC -TimeZone "Pacific Standard Time" -Verbose
            $result.UtcTime | Should Be $expectedUtc
            $result.LocalTime | Should Be $expectedLocal
        }

        It 'Adds hours, minutes, seconds correctly' {
            $result = Convert-LocalToUTC $testTime -AddDays 1 -AddHours 2 -AddMinutes 3 -Verbose
            $expected = (Get-Date $testTime).AddDays(1).AddHours(2).AddMinutes(3)
            $result.LocalTime | Should Be $expected
        }
    }

    Context 'Parameters' {
        It 'Has the timezone as the first unnamed parameter' {
            $localTime = Get-Date $testTime
            $utc = (Get-Date $testTime).AddHours(4) # 4 hours ahead for EDT
            $result = Convert-LocalToUtc $localTime "Eastern Standard Time"
            $result | Should Be $utc
        }
    }

    Context 'Pipeline support' {
        It 'Converts pipeline value' {
            $result = (Get-Date $testTime) | Convert-LocalToUtc -TimeZone "Pacific Standard Time"
            $result | Should Be (Get-Date $testTime).AddHours(7)
        }

        It 'Converts named LocalTime' {
            $local = Get-Date $testTime
            New-Object psobject -Property @{ Name = "hello"; LocalTime=$local; SomeField=123456 }
            $result = (Get-Date $testTime) | Convert-LocalToUtc -TimeZone "Pacific Standard Time"
            $result | Should Be (Get-Date $testTime).AddHours(7)
        }
    }
}

Describe 'UtcToLocal' {
    $testTime= "2017-09-04 08:25:00"

    Context 'Time Conversion' {
        It 'Parses ISO8601 properly' {
            $result = Convert-UtcToLocal -Time $testTime -Verbose
            $expected = Get-Date $testTime
            $result.UtcTime | Should Be $expected
        }

        It 'Converts UTC time to local time correctly' {
            $result = Convert-UtcToLocal -Time $testTime -TimeZone "Eastern Standard Time"
            $expected = (Get-Date $testTime).AddHours(-4)
            $result | Should Be $expected
        }

        It 'Adds hours, minutes, seconds correclty' {
            $result = Convert-UtcToLocal $testTime "Eastern Standard Time" -AddDays 1 -AddHours 2 -AddMinutes 3 -Verbose
            $expected = (Get-Date $testTime).AddDays(1).AddHours(2).AddMinutes(3)
            $result.UtcTime | Should Be $expected
        }
    }

    Context 'Parameters' {
        It 'Has the timezone as the first unnamed parameter' {
            $utc = Get-Date $testTime
            $local = (Get-Date $testTime).AddHours(-4) # 4 hours behind for EDT
            $result = Convert-UtcToLocal $utc "Eastern Standard Time"
            $result | Should Be $local
        }
    }

    Context 'CmdletBinding Support' {
        It 'Verbose returns the full object' {
            $pst = Get-TimeZone "Pacific Standard Time"
            $result = Convert-UtcToLocal (Get-Date $testTime) "Pacific Standard Time" -Verbose
            $utc = Get-Date $testTime
            $local = $utc.AddHours(-7)
            $result.LocalTime | Should Be $local
            $result.UtcTime | Should Be $utc
            $result.TimeZone | Should Be $pst
        }
    }

    Context 'Pipeline Support' {
        It 'Converts pipeline value' {
            $result = (Get-Date $testTime) | Convert-UtcToLocal -TimeZone "Pacific Standard Time"
            $result | Should Be (Get-Date $testTime).AddHours(-7)
        }
        
        It 'Converts named UtcTime' {
            $utc = Get-Date $testTime
            New-Object psobject -Property @{ Name = "hello"; UtcTime=$utc; SomeField=123456 }
            $result = (Get-Date $testTime) | Convert-UtcToLocal -TimeZone "Pacific Standard Time"
            $result | Should Be (Get-Date $testTime).AddHours(-7)
        }
    }
}

Describe 'Convert-TimeZone' {
}
