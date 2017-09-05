# LocalToUtc

This module makes it easy to get the current local time in UTC. It was built for my specific use case where
I work with machines that register events in UTC time stamps, but I experience their failures in my local time.
Using this script it is possible to return the current time in UTC, and query for a time in the past or future 
in UTC as well.

## Usage
There are two functions, `Convert-LocalTimeToUtc` and `Convert-UtcToLocalTime`, which will return an object that
contains two properties, `LocalTime` and `UtcTime`. The `LocalTime` defaults to the system local time, unless it is
modified with the `-TimeZone` parameter.

```powershell
Convert-LocalToUtc

LocalTime           UTCTime
---------           -------
9/4/2017 8:22:10 PM 9/5/2017 12:22:10 AM

Convert-UtcToLocal

LocalTime           UtcTime
---------           -------
9/4/2017 8:24:59 PM 9/5/2017 12:24:59 AM
```

If you want to know the local time and utc time for a specific timezone, then use the `-Timezone` parameter with
either function. To see a list of valid time zones that the system is aware of, use `Get-TimeZone -ListAvailable | Select Id`.

```powershell
Convert-UTCtoLocal -TimeZone "Israel Standard Time"

LocalTime           UtcTime
---------           -------
9/5/2017 3:31:22 AM 9/5/2017 12:31:22 AM
```

Both functions also take an ISO 8601 formatted string to set a time of interest.

```powershell
Convert-LocalToUTC -LocalTime "2017-09-04 20:33:00" -TimeZone "Pacific Standard Time"

LocalTime           UtcTime
---------           -------
9/4/2017 8:33:00 PM 9/5/2017 3:33:00 AM
```

And lastly you can modify the days, hours, and minutes with either function.

```powershell
Convert-UtcToLocal -LocalTime "2017-09-04 08:24:00" -AddDays 2 -AddHours -3 -AddMinutes 6 -TimeZone "Eastern Standard Time"

LocalTime           UtcTime
---------           -------
9/6/2017 5:42:40 PM 9/6/2017 9:42:40 PM
```

## Versions

### 1.0.0

* Added Convert-LocalTimeToUtc and Convert-UtcToLocalTime functions to module
* Added Pester test script
* Added Manifest
* Added Readme