## 1.6.2

- Updated plugin_platform_interface and bump example dependencies

## 1.6.1

- Updated iOS SDK
  to [4.4.1](https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/releases/tag/4.4.1)
- Updated Android SDK
  to [4.1.1](https://github.com/Keyri-Co/keyri-android-whitelabel-sdk-source/releases/tag/4.1.1)
- Fixed nullable publicUserId in `login` and `register` methods on Android
- Updated proguard-rules to keep `LoginObject` and `RegisterObject` on Android
- Fixed passing `appKey` on iOS initialize
- Completely refactored Scanner and `easyKeyriAuth` function on iOS
- Improved logging on iOS

## 1.6.0

- Added `login` and `register` methods
- Updated Android SDK
  to [4.1.0](https://github.com/Keyri-Co/keyri-android-whitelabel-sdk/releases/tag/4.1.0)
- Updated iOS SDK
  to [4.3.0](https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/releases/tag/4.3.0)

## 1.5.0

- Changed Swift bridge implementation to Objective-C
- Fixed **Lexical or Preprocessor Issue (Xcode): 'keyri_v3-Swift.h' file not found** error

## 1.4.7

- Added more logs on Android

## 1.4.6

- Fixed example

## 1.4.5

- Fixed FlutterMethodNotImplemented log

## 1.4.4

- Updated handling arguments on Android and iOS bridges
- Extended example app

## 1.4.3

- Fixed parsing publicUserId argument on iOS

## 1.4.2

- Added constraints to Android and iOS SDK-s

## 1.4.1

- Updated Android SDK
  to [4.0.2](https://github.com/Keyri-Co/keyri-android-whitelabel-sdk/releases/tag/4.0.2)
- Updated iOS SDK
  to [4.2.5](https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/releases/tag/4.2.5)
- Improved iOS error handling
- Fixed channel types

## 1.4.0

- Added docs
- Updated Android SDK to 4.0.0 version
- Refactored Keyri methods types, removed redundant nullable values
- Hide channel interface code

## 1.3.0

- Updated Keyri Android and iOS SDKs to latest

## 1.2.0

- Updated Keyri Android SDK, added fraud events
