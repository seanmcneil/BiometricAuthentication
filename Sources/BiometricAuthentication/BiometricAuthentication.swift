import LocalAuthentication
import SwiftUI

/// Provides an indication of the current state of authentication
public enum AuthenticationAction: Equatable {
    case authenticated
    case notAuthenticated
    case error(BiometricError)
}

/// Support for error states that may be encountered while authenticating
public enum BiometricError: Swift.Error {
    case unsupportedHardware
    case authenticationFailed
}

public final class BiometricAuthentication: ObservableObject {
    private let cancelTitle: String
    private let reason: String

    private var context: ContextProtocol

    /// Provides indication to the user of the current state of authentication
    ///
    /// This will provide updates when ``AuthenticationAction`` changes between
    /// `AuthenticationAction.authenticated` and
    /// `AuthenticationAction.notAuthenticated` as well as errors
    /// which will arrive as `AuthenticationAction.error(BiometricError)`
    ///
    /// - Note: Normally, you will just observe changes to this to get the status
    ///         of the user's authentication attempts.
    @Published public private(set) var authenticationAction: AuthenticationAction {
        didSet {
            switch authenticationAction {
            case .notAuthenticated:
                // Each authentication requires a new context
                // However, a mock for unit testing is fine to reuse
                // So if this is a non-mock, generate a new context
                // when the user is notAuthenticated.
                if !(context is MockContext) {
                    context = LAContext()
                }
                context.localizedCancelTitle = cancelTitle

            default:
                break
            }
        }
    }

    /// Indicates what biometrics are supported by the current device
    ///
    /// Options are of type ``LABiometryType``:
    /// - `.none`
    /// - `.touchID`
    /// - `.faceID`
    public var biometryType: LABiometryType {
        context.biometryType
    }

    /// Indicates if biometrics are supported
    ///
    /// This will return `true` when `touchID` or `faceID` is available
    public var isBiometricsSupported: Bool {
        context.biometryType != .none
    }

    /// Initialize object for processing biometrics
    ///
    /// If the current device supports biometrics, this will enable
    /// your app to utilize biometrics for authentication.
    ///
    /// Please note that when using `faceID`, you must also request
    /// permission through the **info.plist** to access Face ID.
    ///
    /// ```swift
    /// // Default use
    /// BiometricAuthentication(cancelTitle: "Cancel",
    ///                         reason: "Please allow access")
    /// ```
    ///
    /// ```swift
    /// // Testing use
    /// let mockContext = MockContext()
    /// BiometricAuthentication(context: mockContext,
    ///                         cancelTitle: "Cancel",
    ///                         reason: "Please allow access")
    /// ```
    ///
    /// - Note: You will only need to provide a `context` for testing
    ///
    /// - Parameters:
    ///   - context: ContextProtocol to use for biometrics
    ///   - cancelTitle: String representing cancel title
    ///   - reason: String representing reason request title
    public init(context: ContextProtocol = LAContext(),
                cancelTitle: String,
                reason: String) {
        self.context = context
        self.cancelTitle = cancelTitle
        self.reason = reason

        // This check must be run so that the context can then
        // set the biometryType
        context.canEvaluatePolicy(.deviceOwnerAuthentication,
                                  error: nil)

        authenticationAction = .notAuthenticated
    }

    /// Attempt to authenticate the user with biometrics
    ///
    /// Will update `authenticationAction` with the results of
    /// this login attempt.
    public func login() {
        var error: NSError?
        // Will first determine if the device supports biometrics
        // If the device does not, an error is returned and the login stops
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication,
                                        error: &error) else {
            authenticationAction = .error(.unsupportedHardware)

            return
        }

        // This ensures that a new context is provided for authentication
        // Otherwise, the previously used one will always fail to re-auth
        if authenticationAction == .authenticated {
            authenticationAction = .notAuthenticated
        }

        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: reason) { [weak self] success, _ in
            // The API makes no guarantee on what thread this will use
            // so ensure that the action is updated on main thread
            DispatchQueue.main.async {
                if success {
                    self?.authenticationAction = .authenticated
                } else {
                    self?.authenticationAction = .error(.authenticationFailed)
                }
            }
        }
    }

    /// Log out the user, if they are already authenticated
    ///
    /// If the user is not `authenticated`, then no changes
    /// will occur.
    public func logout() {
        if authenticationAction == .authenticated {
            authenticationAction = .notAuthenticated
        }
    }
}
