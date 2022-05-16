# BiometricAuthentication

This package is a light wrapper around the Apple framework for local authentication via device biometrics that easily supports integration with `SwiftUI` based apps.

While supporting common usage, this package also includes the ability to mock the authentication tools, making it easy to test this functionality in your apps.

## Requirements
- iOS 13
- macOS 10.15
- Xcode 12

## Installation

### Swift Package Manager

This package supports installation through Xcode's Swift Package Manager.

It can also be added as a dependency to an existing package:

```swift
.package(name: "BiometricAuthentication",
         url: "https://github.com/seanmcneil/BiometricAuthentication.git",
         from: "1.0.0"),
```

### Cocoapods

This package supports installation through the Cocoapods framework, starting with version 1.1.0.

```ruby
pod `AuthenticationBiometric`, '~> 1.1.1'
```

## Usage

### Initialize

First, initialize an instance of `BiometricAuthentication` with the `String` values you wish to use for the cancel and reason prompts that may be presented during your authentication flow. This object should be an instance property, otherwise it could go out of scope if used in a function.

```swift
let auth = BiometricAuthentication(cancelTitle: "Cancel Title", 
                                   reason: "Reason Title")
```

### Observing Status

You can observe a user's current status through the  `authenticationAction` property of `BiometricAuthentication`.

The following shows all potential values that `authenticationAction` can have:

```swift
switch action {
case .authenticated:
    // Handle authentication

case .notAuthenticated:
    // Handle sign out

case .error(let error):
    switch error {
    case .authenticationFailed:
        // User was denied access
        
    case .unsupportedHardware:
        // The device does not support biometrics
    }
}
```

### Login

To perform a login operation:

```swift
auth.login()
```

Upon a successful login, the `authenticationAction` value will be `authenticated`.

### Authentication Errors

If a user fails to properly authenticate, you will receive a `BiometricError`, published through the  `authenticationAction` property.

These are:
```swift
public enum BiometricError: Swift.Error {
    case unsupportedHardware
    case authenticationFailed
}
```

- `unsupportedHardware` will be encountered when the user's device does not support biometrics
- `authenticationFailed` will be encountered when the user failed to authenticate via biometrics

### Logout

To perform a logout operation:

```swift
auth.logout()
```
Upon a successful logout, the `authenticationAction` value will be `notAuthenticated`.

However, if the user is already `notAuthenticated`, then no change will occur.


## Enable Face ID with your app

For Face ID to work with your app, you must also place an entry for `NSFaceIDUsageDescription`  in your app's `info.plist` file, otherwise it will not work.

```
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID instead of a password to access your account.</string>
```
## Testing

If you wish to run tests against the package, you can utilize the `ContextProtocol` to mock the `LAContext` class. Examples of this are included with the package's tests.

Currently, the package is achieving a test coverage of 99%.

## Author

Sean McNeil

## License

BiometricAuthentication is available under the MIT license. See the LICENSE file for more info.
