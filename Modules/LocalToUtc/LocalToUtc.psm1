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
    Convert-UtcToLocalTime -AddHours -3 -UtcTime "2017-08-01 03:00:00"
.Example
    Convert-UtcToLocalTime -TimeZone "Pacific Standard Time"
#>

    param(
    [String] $UtcTime,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes,
    [String] $TimeZone
    )

    $utc = Get-UtcTime
    $local = Get-LocalTime $utc
    $tzone = Invoke-GetTimeZone

    if ($UtcTime) { $utc = [System.DateTime]::Parse($UtcTime) }
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

    $converted = New-Object psobject -Property @{ UtcTime=$utc; LocalTime=$local; TimeZone=$tzone }
    return $converted
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
    Convert-LocalTimeToUtc -AddHours 5
.Example
    Convert-LocalTimeToUtc -TimeZone "Pacific Standard Time"
#>

    param(
    [String] $LocalTime,
    [Int] $AddDays,
    [Int] $AddHours,
    [Int] $AddMinutes,
    [String] $TimeZone
    )

    $utc = Get-UtcTime
    $local = Get-LocalTime $utc
    $tzone = Invoke-GetTimeZone

    write-host "get-utctime" $utc
    write-host "get-localtime" $local
    write-host "get-timezone" $tzone

    if ($LocalTime) { $local = [System.DateTime]::Parse($LocalTime) }
    if ($AddDays) { $local = $local.AddDays($AddDays); $utc = $utc.AddDays($AddDays) }
    if ($AddHours) { $local = $local.AddHours($AddHours); $utc = $utc.AddHours($AddHours) }
    if ($AddMinutes) { $local = $local.AddMinutes($AddMinutes); $utc = $utc.AddMinutes($AddMinutes) }
    if ($TimeZone) {
        $tzDst = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
        if ($LocalTime) {
            # if a specific time is specified, then get the UTC time for that DateTime in
            # the given time zone.
            $tzTime = [System.DateTime]::SpecifyKind($local, [System.DateTimeKind]::Unspecified)
            $utc = [TimeZoneInfo]::ConvertTimeToUtc($tzTime, $tzDst)
        } else {
            # if we are using the system time as the local time, then convert the system time
            # to the destination's time zone first. 
            # Ex: if the system time is EST and the specified time is PST
            #     $local is DateTime.Now. Convert it to PST and return the new local time and utc
            write-host "tzone - " $tzone
            write-host "tzDst - " $tzDst
            write-host "local - " $local "utc - " $utc
            $local = [TimeZoneInfo]::ConvertTime($local, $tzone, $tzDst)
            $utc = [TimeZoneInfo]::ConvertTimeToUtc($local, $tzDst)
            write-host "local - " $local "utc - " $utc
        }
        $tzone = $tzDst
    } else {
        $utc = $local.ToUniversalTime()
    }

    $converted = New-Object psobject -Property @{ UtcTime=$utc; LocalTime=$local; TimeZone=$tzone }
    return $converted
}

# overloaded to help with testing
function Get-UtcTime { return [System.DateTime]::UtcNow }
function Get-LocalTime ($time) { return $time.ToLocalTime() }
function Invoke-GetTimeZone { return Get-TimeZone }