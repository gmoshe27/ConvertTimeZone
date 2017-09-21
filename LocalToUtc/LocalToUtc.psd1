# Module manifest for module 'LocalToUtc'
# Generated by: Gad Berger
# Generated on: 9/3/2017

@{

# Script module or binary module file associated with this manifest.
RootModule = 'LocalToUtc.psm1'

# Version number of this module.
ModuleVersion = '1.5.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '095bff97-0127-4740-a991-9865169c356a'

# Author of this module
Author = 'Gad Berger'

# Company or vendor of this module
CompanyName = 'https://github.com/gmoshe27/ConvertTimeZone'

# Copyright statement for this module
Copyright = '(c) 2017 Gad Berger. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Provides functions to convert between time zones, as well as between the local system time and UTC.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
DotNetFrameworkVersion = '3.5'

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Convert-UtcToLocal', 'Convert-LocalToUtc', 'Convert-TimeZone'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = 'LocalToUtc.psd1', 'LocalToUtc.psm1, TimeZone-Completer.ps1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'time', 'timezone', 'utc', 'convert'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/gmoshe27/ConvertTimeZone/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/gmoshe27/ConvertTimeZone'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes =
        '
        1.5.0
        * Added argument completers for -TimeZone, -FromTimeZone and -ToTimeZone parameters
        * Argument completers are only available on powershell >= 5.0
        * Fixed a bug when not sending a time parameter to Convert-UtcToLocal

        1.4.0
        * Added a generic Convert-TimeZone function
        * Updated Convert-LocalToUtc and Convert-UtcToLocal to use Convert-TimeZone
        * Breaking Changes
          - Renamed the -LocalTime parameter to -Time for Convert-LocalToUtc
          - Renamed the -UtcTime parameter to -Time for Convert-UtcToLocal

        1.3.1
        * Lowered the required version of PS to 4.0

        1.3.0
        * Intorduced pipeline support!
        
        1.2.0
        * Switched to using tzutil when Get-TimeZone is not available
        * Replaced [System.DateTime]::Parse with Get-Date
        
        1.1.0
        * Moved the TimeZone to the second position in the unnamed parameters
        * Only returning the converted time unless a -Verbose switch is used
        
        1.0.0
        * Initial release of Convert-LocalToUtc and Convert-UtcToLocal
        '
    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

