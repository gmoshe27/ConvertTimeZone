[![Build status](https://ci.appveyor.com/api/projects/status/00kurvfj7ih1vat0/branch/master?svg=true
)](https://ci.appveyor.com/project/gmoshe27/powershell/branch/master)

# LocalToUtc

This module makes it easy to get the current local time in UTC, as well as convert between time zones. It was 
built for my specific use case where I work with machines that register events in UTC time stamps, but I 
experience their failures in my local time. Using this script it is possible to return the current time in UTC, 
and query for a time in the past or future in UTC as well.

There are three functions in the module,
- Convert-TimeZone
- Convert-LocalTimeToUtc
- Convert-UtcToLocalTime

`Convert-TimeZone` is a generic function that can convert a time from any time zone to any other time zone.  
`Convert-LocalToUtc` and `Convert-UtcToLocal` convert times to and from UTC.

## Usage
### Convert-TimeZone
```powershell
Convert-TimeZone [[-Time] <string>] [[-ToTimeZone] <string>] [[-FromTimeZone] <string>]  [<CommonParameters>]
```

`Covnert-TimeZone` can convert a time between two time zones. 

Parameter |  Description
----------|-------------
Time |(optional) The time used to convert from the `FromTimeZone` to the `ToTimeZone`. If left unspecified, the time will be the current local system time.
ToTimeZone | (required) The name of the time zone to convert to.
FromTimeZone | (optional) The name of the time zone to convert from. If left unspecified, the time zone will be the current local system time zone.

If `-Verbose` is added to the `Convert-TimeZone` function, it will return an object that contains details about the conversion.

Return Parameter | Description
---|---
Time | The input to the time zone conversions, either the `-Time` time, or the local system time
FromTimeZone | A TimeZone object describing the time zone that the `Time` was converted from
ToTimeZone | A TimeZone object describing the time zone that the `Time` was converted to
ToTime | The resulting time from the time zone conversion

### Convert-LocalToUtc and Convert-UtcToLocal
```powershell
Convert-LocalToUtc [[-Time] <String>] [[-TimeZone] <String>] [[-AddDays] <Int32>] [[-AddHours] <Int32>] [[-AddMinutes] <Int32>] [<CommonParameters>]

Convert-UtcToLocal [[-Time] <String>] [[-TimeZone] <String>] [[-AddDays] <Int32>] [[-AddHours] <Int32>] [[-AddMinutes] <Int32>] [<CommonParameters>]
```

`Convert-LocalToUtc` and `ConvertUtcToLocal` converts the local system time to and from UTC.

Parameter |  Description
----------|-------------
Time | (optional) The time to use for the conversion. If left unspecied, the time will be the current local system time.
TimeZone | (optional) The name of the time zone to convert from. If left unspecified, the time zone will be the current local system time zone.
AddDays | (optional) The number of days to add (ex: 5) or subtract (ex: -3) from the time to convert
AddHours | (optional) The number of hours to add (ex: 5) or subtract (ex: -3) from the time to convert
AddMinutes | (optional) The number of minutes to add (ex: 5) or subtract (ex: -3) from the time to convert

If `-Verbose` is appended to either function, it will return an object that contains details about the conversion.

Return Parameter | Description
---|---
LocalTime | A DateTime object that respresents the local time after any modifications
UtcTime | A DateTime object that represents the UTC time based on the local DateTime
TimeZone | A TimeZone object that represents the timezone used for all conversions

### Examples
Call `Convert-TimeZone` to convert between any two named time zones.

```powershell
Get-Date "2017-09-17 03:28:00" | Convert-TimeZone -FromTimeZone "Eastern Standard Time" -ToTimeZone "W. Europe Standard Time" -Verbose


Time                FromTimeZone                           ToTime               ToTimeZone
----                ------------                           ------               ----------
09/17/2017 03:28:00 (UTC-05:00) Eastern Time (US & Canada) 9/17/2017 9:28:00 AM (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
```


Call `Convert-LocalToUtc` or `Convert-UtcToLocal` to convert the times using the local system time. 
Add `-Verbose` to see the time zone that was used in the conversion.

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

In the example below, the local system time (Eastern Standard Time) is used to get the time in UTC, and the
the local time in Israel Standard Time is what is returned.

```powershell
Get-Date
Sunday, September 17, 2017 3:12:32 PM

Convert-UtctoLocal -TimeZone "Israel Standard Time" -Verbose

LocalTime             TimeZone              UtcTime
---------             --------              -------
9/17/2017 10:12:35 PM (UTC+02:00) Jerusalem 9/17/2017 7:12:35 PM
```

Both functions take a DateTime or DateTime string as the first unnamed parameter, which
can also be passed in as part of a pipeline. This allows you to override the use of the 
local system time and use a time of your choosing.

```powershell
Convert-LocalToUtc "2017-09-04 20:33:00" "Pacific Standard Time" -Verbose

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

### 1.5.0
* Added argument completers for -TimeZone, -FromTimeZone and -ToTimeZone parameters
* Argument completers are only available on powershell >= 5.0
* Fixed a bug when not sending a time parameter to Convert-UtcToLocal

### 1.4.0
* Added a generic Convert-TimeZone function
* Updated Convert-LocalToUtc and Convert-UtcToLocal to use Convert-TimeZone
* Breaking Changes
  - Renamed the -LocalTime parameter to -Time for Convert-LocalToUtc
  - Renamed the -UtcTime parameter to -Time for Convert-UtcToLocal

### 1.3.1
* Lowered the required version of PS to 4.0

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
