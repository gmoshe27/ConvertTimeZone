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

    $utc = [System.DateTime]::UtcNow
    $local = $utc.ToLocalTime()
    $tzone = Get-TimeZone

    if ($UtcTime) { $utc = [System.DateTime]::Parse($UtcTime) }
    if ($AddDays) { $utc = $utc.AddDays($AddDays) }
    if ($AddHours) { $utc = $utc.AddHours($AddHours) }
    if ($AddMinutes) { $utc = $utc.AddMinutes($AddMinutes) }
    if ($TimeZone) {
        $tz = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
        $local = [TimeZoneInfo]::ConvertTimeFromUTC($utc, $tz)
        $tzone = $tz
    } else {
        $local = $utc.ToLocalTime()
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

    $utc = [System.DateTime]::UtcNow
    $local = $utc.ToLocalTime()
    $tzone = Get-TimeZone

    if ($LocalTime) { $local = [System.DateTime]::Parse($LocalTime) }
    if ($AddDays) { $local = $local.AddDays($AddDays) }
    if ($AddHours) { $local = $local.AddHours($AddHours) }
    if ($AddMinutes) { $local = $local.AddMinutes($AddMinutes) }
    if ($TimeZone) {
        # Get the time zone, get the local timezone time from UTC
        $tz = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
        $tzKind = [System.DateTime]::SpecifyKind($local, [System.DateTimeKind]::Unspecified)
        $local = [TimeZoneInfo]::ConvertTimeFromUtc($utc, $tz)
        $tzone = $tz
    } else {
        $utc = $local.ToUniversalTime()
    }

    $converted = New-Object psobject -Property @{ UtcTime=$utc; LocalTime=$local; TimeZone=$tzone }
    return $converted
}