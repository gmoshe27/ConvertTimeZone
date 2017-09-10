![Build status](https://ci.appveyor.com/api/github/webhook?id=59sf1j8r9mp0vyta/branch/master?svg=true)

[![Build status](https://ci.appveyor.com/api/projects/status/00kurvfj7ih1vat0/branch/master?svg=true
)](https://ci.appveyor.com/project/gmoshe27/powershell/branch/master)

# LocalToUtc

This module makes it easy to get the current local time in UTC. It was built for my specific use case where
I work with machines that register events in UTC time stamps, but I experience their failures in my local time.
Using this script it is possible to return the current time in UTC, and query for a time in the past or future 
in UTC as well.

## Usage
There are two functions, `Convert-LocalTimeToUtc` and `Convert-UtcToLocalTime`, which will return an object that
contains the `LocalTime`, `UtcTime`, and current `TimeZone`. The `LocalTime` defaults to the system local time, unless 
it is modified with the `-TimeZone` parameter.

Return Parameter | Description
---|---
LocalTime | A DateTime object that respresents the local time after any modifications
UtcTime | A DateTime object that represents the UTC time based on the local DateTime
TimeZone | A TimeZone object that represents the timezone used for all conversions

```powershell
Convert-LocalToUtc

LocalTime            TimeZone                               UtcTime
---------            --------                               -------
9/5/2017 10:08:57 PM (UTC-05:00) Eastern Time (US & Canada) 9/6/2017 2:08:57 AM

Convert-UtcToLocal

LocalTime            TimeZone                               UtcTime
---------            --------                               -------
9/5/2017 10:09:14 PM (UTC-05:00) Eastern Time (US & Canada) 9/6/2017 2:09:14 AM
```

If you want to know the local time and utc time for a specific timezone, then use the `-Timezone` parameter with
either function. To see a list of valid time zones that the system is aware of, use `Get-TimeZone -ListAvailable | Select Id`.

```powershell
Convert-UTCtoLocal -TimeZone "Israel Standard Time"

LocalTime           TimeZone              UtcTime
---------           --------              -------
9/6/2017 5:09:36 AM (UTC+02:00) Jerusalem 9/6/2017 2:09:36 AM
```

Both functions also take an ISO 8601 formatted string to set a time of interest.

```powershell
Convert-LocalToUTC -LocalTime "2017-09-04 20:33:00" -TimeZone "Pacific Standard Time"

LocalTime           TimeZone                               UtcTime
---------           --------                               -------
9/4/2017 8:33:00 PM (UTC-08:00) Pacific Time (US & Canada) 9/5/2017 3:33:00 AM
```

And lastly you can modify the days, hours, and minutes with either function.

```powershell
Convert-UtcToLocal -LocalTime "2017-09-04 08:24:00" -AddDays 2 -AddHours -3 -AddMinutes 6 -TimeZone "Eastern Standard Time"

LocalTime           TimeZone                               UtcTime
---------           --------                               -------
9/7/2017 7:16:19 PM (UTC-05:00) Eastern Time (US & Canada) 9/7/2017 11:16:19 PM
```

## Versions

### 1.2.0

* Switched to using tzutil when Get-TimeZone is not available
* Replaced [System.DateTime]::Parse with Get-Date

### 1.1.0

* Moved the TimeZone to the second position in the unnamed parameters
* Only returning the converted time unless a -Verbose switch is used

### 1.0.0

* Added Convert-LocalTimeToUtc and Convert-UtcToLocalTime functions to module
* Added Pester test script
* Added Manifest
* Added Readme
