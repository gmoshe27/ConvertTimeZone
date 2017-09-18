function Convert-UtcToLocal
{
<#
.Synopsis
    Converts UTC time to the system local time.
.Description
    Converts the current UTC time to the local system time, using the local system's timezone.
    To override the UTC Time, enter an ISO 8601 string (ex: "2017-08-01 09:20:00") as a parameter.
    To override the Time Zone use any of the time zone strings listed in https://msdn.microsoft.com/en-us/library/cc749073.aspx
.Example
    Convert-UtcToLocal -AddHours -3 -UtcTime "2017-08-01 03:00:00"
.Example
    Convert-UtcToLocal -TimeZone "Pacific Standard Time"
#>
    [CmdletBinding()]
    
    param(
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [DateTime] $Time,
    [String] $TimeZone,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes
    )

    Process {
        $tzone = if ($TimeZone) { $TimeZone } else { Invoke-GetTimeZone }

        $t = Get-InputTime -Time:$Time -AddDays:$AddDays -AddHours:$AddHours -AddMinutes:$AddMinutes
        $result = Convert-TimeZone -Time:$t -ToTimeZone $tzone -FromTimeZone "UTC" -Verbose
        
        if (IsVerbose $Verbose) {
            $converted = New-Object psobject -Property @{
                UtcTime=$result.Time;
                LocalTime=$result.ToTime;
                TimeZone=$result.ToTimeZone
            }
            return $converted
        }

        return $result.ToTime
    }
}

function Convert-LocalToUtc
{
<#
.Synopsis
    Converts the local system time to UTC time
.Description
    Converts the current local system time to UTC time, using the local system's timezone.
    To override the local time, enter an ISO 8601 string (ex: "2017-08-01 09:20:00") as a parameter.
    To override the Time Zone use any of the strings listed in https://msdn.microsoft.com/en-us/library/cc749073.aspx
.Example
    Convert-LocalToUtc -AddHours 5
.Example
    Convert-LocalToUtc -TimeZone "Pacific Standard Time"
#>
    [CmdletBinding()]

    param(
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [DateTime] $Time,
    [String] $TimeZone,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes
    )

    Process {
        $tzone = if ($TimeZone) { $TimeZone } else { Invoke-GetTimeZone }

        $local = if ($Time) { $Time } else { Get-LocalTime (Get-UtcTime) }
        $local = Get-InputTime -Time:$local -AddDays:$AddDays -AddHours:$AddHours -AddMinutes:$AddMinutes
        
        # If a time is not defined, but a timezone is, then treat the
        # current local system time as the local time of the specified timezone
        if (! $Time -and $TimeZone) {
            $FromTimeZone = [TimeZoneInfo]::FindSystemTimeZoneById($tzone)
            $ToTimeZone = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            $local = [TimeZoneInfo]::ConvertTime($local, $FromTimeZone, $ToTimeZone)
        }

        $result = Convert-TimeZone -Time $local -FromTimeZone $tzone -ToTimeZone "UTC" -Verbose
        write-host $result.Time
        if (IsVerbose $Verbose) {
            $converted = New-Object psobject -Property @{
                UtcTime=$result.ToTime;
                LocalTime=$result.Time;
                TimeZone=$result.FromTimeZone
            }
                
            return $converted
        }

        return $result.ToTime
    }
}

function Convert-TimeZone
{
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [DateTime] $Time,
        [String] $ToTimeZone,
        [String] $FromTimeZone
    )

    Process {
        # always start with the current utc time if $Time is not set
        $fromTimeUtc = $inputTime = if ($Time) { $Time } else { Get-UtcTime }

        # if from time zone is not specified, use the current system timezone
        $fromTz = Invoke-GetTimeZone
        if ($FromTimeZone) {
            $fromTz = [TimeZoneInfo]::FindSystemTimeZoneById($FromTimeZone)
        } else {
            $fromTz = [TimeZoneInfo]::FindSystemTimeZoneById($fromTz)
        }

        if (! $ToTimeZone) { return }
        $toTz = [TimeZoneInfo]::FindSystemTimeZoneById($ToTimeZone)

        # convert the input time to utc using the FromTimeZone
        if ($Time) {
            $fromTimeKind = [System.DateTime]::SpecifyKind($Time, [System.DateTimeKind]::Unspecified)
            $fromTimeUtc = [TimeZoneInfo]::ConvertTimeToUTC($fromTimeKind, $fromTz)
        }

        # use the current utc time to find the time in the destination timezone
        $toTimeKind = [System.DateTime]::SpecifyKind($fromTimeUtc, [System.DateTimeKind]::Unspecified)
        $toTime = [TimeZoneInfo]::ConvertTimeFromUTC($toTimeKind, $toTz)

        if (IsVerbose $Verbose) {
            $result = New-Object psobject -Property @{
                Time=$inputTime;
                FromTimeZone=$fromTz;
                ToTimeZone=$toTz;
                ToTime=$toTime }
            return $result
        }

        return $toTime
    }
}

function IsVerbose ([Switch] $Verbose) {
    $IsVerbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
    return $IsVerbose -eq $true
}

function Get-InputTime {
    Param (
        [String] $Time,
        [Int] $AddDays,
        [Int] $AddHours,
        [Int] $AddMinutes
    )
    if ($Time) { $t = Get-Date $Time }
    if ($AddDays) { $t = $t.AddDays($AddDays) }
    if ($AddHours) { $t = $t.AddHours($AddHours) }
    if ($AddMinutes) { $t = $t.AddMinutes($AddMinutes) }
    return $t
}

# overloaded to help with testing
function Get-UtcTime { return [System.DateTime]::UtcNow }
function Get-LocalTime ($time) { return $time.ToLocalTime() }
function Invoke-GetTimeZone {
    if (Get-Command Get-TimeZone -errorAction SilentlyContinue) {
        return Get-TimeZone | Select-Object -ExpandProperty Id
    }
    
    return tzutil /g
}
