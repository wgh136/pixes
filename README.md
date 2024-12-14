# pixes

[![flutter](https://img.shields.io/badge/flutter-3.27.0-blue)](https://flutter.dev/) 
[![License](https://img.shields.io/github/license/wgh136/pixes)](https://github.com/wgh136/pixes/blob/master/LICENSE)
[![Download](https://img.shields.io/github/v/release/wgh136/pixes)](https://github.com/wgh136/pixes)
[![stars](https://img.shields.io/github/stars/wgh136/pixes)](https://github.com/wgh136/pixes/stargazers)

Unofficial Pixiv app, support Windows, Android, iOS, macOS, linux

All main features are implemented.

## Download

Download from [Release](https://github.com/wgh136/pixes/releases)

## Build from source

### Install Flutter

View [Flutter Document](https://flutter.dev/docs/get-started/install)

### Build Android

Put your keystore file (`key.jks`, `key.properties`) in `android/`

Run `flutter build apk`

### Build iOS/Windows/macOS

Run `flutter build ios/windows/macos`

### Build Linux

Use`python3 debian/build.py` to build deb package

For other linux distributions, you can use `flutter build linux` to build. 
You must register the `pixiv` scheme in the `.desktop` file, otherwise the login will not work.

## Screenshots

<img src="screenshots/1.png" style="width: 400px">
<img src="screenshots/2.png" style="width: 400px">
<img src="screenshots/3.png" style="width: 400px">
<img src="screenshots/4.png" style="width: 400px">