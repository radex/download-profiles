# download-profiles

A simple CLI tool for downloading iOS and Mac provisioning profiles and installing them in the system.

(Based on [Cupertino](https://github.com/nomad/cupertino))

## Requirements

download-profiles requires the [Xcode Command Line Tools](https://developer.apple.com/xcode/), which can be installed with the following command:

```
xcode-select --install
```

## Setup

To install:

```
gem install download-profiles
```

Before downloading profiles, you need to authenticate to Apple Developer Portal (you can also pass your login and password as parameters, but that's less convenient):

```
download-profiles login
```

_Credentials are saved in the Keychain. You will not be prompted for your username or password by commands while you are logged in. (Mac only)_

## Usage

```
download-profiles
```

Downloads and installs all valid provisioning profiles.

```
download-profiles --platform=mac
```

Installs all Mac profiles

```
download-profiles --platform=ios --type=distribution
```

Installs all iOS distribution (AdHoc) profiles.

For more info, check out `download-profiles --help`

## Contact

Radek Pietruszewski

- http://github.com/radex
- http://twitter.com/radexp
- this.is@radex.io

## License and credits

download-profiles is based on [Cupertino](https://github.com/nomad/cupertino) by [Mattt Thompson](https://github.com/mattt). I merely removed everything from the code that wasn't related to provisioning profiles, added support for Mac profiles and changed the behavior so that profiles are installed (copied into user's ~/Library) instead of downloaded into the working directory.

download-profiles is available under the MIT license. See the LICENSE file for more info.
