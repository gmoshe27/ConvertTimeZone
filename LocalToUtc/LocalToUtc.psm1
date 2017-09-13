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
    [String] $Time,
    [String] $TimeZone,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes
    )

    Process {
        $utc = Get-UtcTime
        $local = Get-LocalTime $utc
        $tzone = Invoke-GetTimeZone

        if ($Time) { $utc = Get-Date $Time }
        if ($AddDays) { $utc = $utc.AddDays($AddDays) }
        if ($AddHours) { $utc = $utc.AddHours($AddHours) }
        if ($AddMinutes) { $utc = $utc.AddMinutes($AddMinutes) }
        if ($TimeZone) {
            $tz = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            $local = [TimeZoneInfo]::ConvertTimeFromUTC($utc, $tz)
            $tzone = $tz
        } else {
            $local = Get-LocalTime $utc
        }

        $IsVerbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent

        if ($IsVerbose -eq $true) {
            $converted = New-Object psobject -Property @{ UtcTime=$utc; LocalTime=$local; TimeZone=$tzone }
            return $converted
        }

        return $local
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
    [String] $Time,
    [String] $TimeZone,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes
    )

    Process {
        $utc = Get-UtcTime
        $local = Get-LocalTime $utc
        $tzone = Invoke-GetTimeZone

        if ($Time) { $local = Get-Date $Time }
        if ($AddDays) { $local = $local.AddDays($AddDays); $utc = $utc.AddDays($AddDays) }
        if ($AddHours) { $local = $local.AddHours($AddHours); $utc = $utc.AddHours($AddHours) }
        if ($AddMinutes) { $local = $local.AddMinutes($AddMinutes); $utc = $utc.AddMinutes($AddMinutes) }
        if ($TimeZone) {
            $tzDst = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            if ($Time) {
                # if a specific time is specified, then get the UTC time for that DateTime in
                # the given time zone.
                $tzTime = [System.DateTime]::SpecifyKind($local, [System.DateTimeKind]::Unspecified)
                $utc = [TimeZoneInfo]::ConvertTimeToUtc($tzTime, $tzDst)
            } else {
                # if we are using the system time as the local time, then convert the system time
                # to the destination's time zone first. 
                # Ex: if the system time is EST and the specified time is PST
                #     $local is DateTime.Now. Convert it to PST and return the new local time and utc
                $local = [TimeZoneInfo]::ConvertTime($local, $tzone, $tzDst)
                $utc = [TimeZoneInfo]::ConvertTimeToUtc($local, $tzDst)
            }
            $tzone = $tzDst
        } else {
            $utc = $local.ToUniversalTime()
        }

        $IsVerbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
        
        if ($IsVerbose -eq $true) {
            $converted = New-Object psobject -Property @{ UtcTime=$utc; LocalTime=$local; TimeZone=$tzone }
            return $converted
        }

        return $utc
    }
}

function Convert-TimeZone
{
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String] $Time,
        [String] $ToTimeZone,
        [String] $FromTimeZone
    )

    Process {
        # always start with the current utc time if $Time is not set
        $fromTimeUtc = Get-UtcTime

        # if from time zone is not specified, use the current system timezone
        $fromTz = Invoke-GetTimeZone
        if ($FromTimeZone) {
            $fromTz = [TimeZoneInfo]::FindSystemTimeZoneById($FromTimeZone)
        }

        $toTz = [TimeZoneInfo]::FindSystemTimeZoneById($ToTimeZone)

        # convert the input time to utc using the FromTimeZone
        if ($Time) {
            $fromTimeKind = [System.DateTime]::SpecifyKind($Time, [System.DateTimeKind]::Unspecified)
            $fromTimeUtc = [TimeZoneInfo]::ConvertTimeToUTC($fromTimeKind, $fromTz)
        }

        # use the current utc time to find the time in the destination timezone
        $toTimeKind = [System.DateTime]::SpecifyKind($fromTimeUtc, [System.DateTimeKind]::Unspecified)
        $toTime = [TimeZoneInfo]::ConvertTimeFromUTC($toTimeKind, $toTz)
        
        return $toTime
    }
}

# overloaded to help with testing
function Get-UtcTime { return [System.DateTime]::UtcNow }
function Get-LocalTime ($time) { return $time.ToLocalTime() }
function Invoke-GetTimeZone {
    if (Get-Command Get-TimeZone -errorAction SilentlyContinue) {
        return Get-TimeZone
    }
    
    return tzutil /g
}
