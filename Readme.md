[![Build status](https://ci.appveyor.com/api/projects/status/00kurvfj7ih1vat0/branch/master?svg=true
)](https://ci.appveyor.com/project/gmoshe27/powershell/branch/master)

# LocalToUtc

This module makes it easy to get the current local time in UTC. It was built for my specific use case where
I work with machines that register events in UTC time stamps, but I experience their failures in my local time.
Using this script it is possible to return the current time in UTC, and query for a time in the past or future 
in UTC as well.

## Usage
There are two functions, `Convert-LocalTimeToUtc` and `Convert-UtcToLocalTime`, which will return the utc
time or local time after the conversion, respectively. If a `-Verbose` flag is passed to either function,
it will return an object that contains the `LocalTime`, `UtcTime`, and current `TimeZone`. 

With either function, the `LocalTime` defaults to the system local time, unless it is modified by
the `-TimeZone` parameter.

Return Parameter | Description
---|---
LocalTime | A DateTime object that respresents the local time after any modifications
UtcTime | A DateTime object that represents the UTC time based on the local DateTime
TimeZone | A TimeZone object that represents the timezone used for all conversions

```powershell
Convert-LocalToUtc

Sunday, September 10, 2017 10:18:45 PM

Convert-UtcToLocal -Verbose

LocalTime            TimeZone                               UtcTime
---------            --------                               -------
9/10/2017 6:19:06 PM (UTC-05:00) Eastern Time (US & Canada) 9/10/2017 10:19:06 PM
```

If you want to know the local time and utc time for a specific timezone, then use the `-Timezone` parameter with
either function. To see a list of valid time zones that the system is aware of, use :
- Powershell >= 5.1 - `Get-TimeZone -ListAvailable | Select Id`  
- Powershell < 5.1 - `tzutil /l`

```powershell
Convert-UTCtoLocal -TimeZone "Israel Standard Time" -Verbose

LocalTime           TimeZone              UtcTime
---------           --------              -------
9/6/2017 5:09:36 AM (UTC+02:00) Jerusalem 9/6/2017 2:09:36 AM
```

Both functions take a DateTime or DateTime string as the first unnamed parameter, which
can also be passed in as part of a pipeline.

```powershell
Convert-LocalToUTC "2017-09-04 20:33:00" "Pacific Standard Time" -Verbose

LocalTime           TimeZone                               UtcTime
---------           --------                               -------
9/4/2017 8:33:00 PM (UTC-08:00) Pacific Time (US & Canada) 9/5/2017 3:33:00 AM

Get-Date | Convert-LocalToUtc -TimeZone "Central Standard Time"

Sunday, September 10, 2017 11:24:12 PM
```

Finally, you can modify input time's days, hours, and minutes with either function. In
the following example, the time returned is the UTC time, based on the modified local system
time.

```powershell
Get-Date "2017-09-04 08:24:00" | Convert-UtcToLocal -TimeZone "Eastern Standard Time" -AddDays 2 -AddHours -3 -AddMinutes 6 -Verbose

LocalTime           TimeZone                               UtcTime
---------           --------                               -------
9/6/2017 1:30:00 AM (UTC-05:00) Eastern Time (US & Canada) 9/6/2017 5:30:00 AM
```

## Versions

### 1.3.0
* Intorduced pipeline support!

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
