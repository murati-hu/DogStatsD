DogStatsD PowerShell module
===============================

[![Build status](https://ci.appveyor.com/api/projects/status/kdc6a75b8wludjq6?svg=true)](https://ci.appveyor.com/project/muratiakos/DogStatsD)
[![Join the chat at https://gitter.im/murati-hu/DogStatsD](https://badges.gitter.im/murati-hu/DogStatsD.svg)](https://gitter.im/murati-hu/DogStatsD?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

DogStatsD module provides a simple way to send events and metrics or other
messages to [DataDog][datadog] from PowerShell via [DogStatsD][dogstatsd] UDP protocol.

## Installation
DogStatsD is available via [PowerShellGallery][PowerShellGallery] and via
[PsGet][psget], so you can simply install it with the following command:
```powershell
Install-Module DogStatsD
```

## Usage and some example
```powershell
Import-Module DogStatsD

# Send Datadog Info Events
Send-DataDogEvent -Title "Test Event" -Text 'This is a detail text for a info event'

# Send Datadog Error Events
Send-DataDogEvent -Title "Failure Event" -Text 'Error details can come here' -AlertType error

# Send a Histogram metric for an example command duration
Send-DataDogMetric -Type Histogram -Name 'command.duration' -Value 12 -Tag @("command:my_command_name")
```

## Documentation
Cmdlets and functions for DogStatsD have their own help PowerShell help, which
you can read with `help <cmdlet-name>`.

## Versioning
DogStatsD aims to adhere to [Semantic Versioning 2.0.0][semver].

## Issues
In case of any issues, raise an [issue ticket][issues] in this repository and/or
feel free to contribute to this project if you have a possible fix for it.

## Development
* Source hosted at [Github.com][repo]
* Report issues/questions/feature requests on [Github Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the [repo][repo]
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors
Created and maintained by [Akos Murati][muratiakos] (<akos@murati.hu>)

## License
Apache License, Version 2.0 (see [LICENSE][LICENSE])

[repo]: https://github.com/murati-hu/DogStatsD
[issues]: https://github.com/murati-hu/DogStatsD/issues
[muratiakos]: http://murati.hu
[license]: LICENSE
[semver]: http://semver.org/
[psget]: http://psget.net/
[download]: https://github.com/murati-hu/DogStatsD/archive/latest.zip
[PowerShellGallery]: https://www.powershellgallery.com
[datadog]: https://www.datadoghq.com/
[dogstatsd]: http://docs.datadoghq.com/guides/dogstatsd/
