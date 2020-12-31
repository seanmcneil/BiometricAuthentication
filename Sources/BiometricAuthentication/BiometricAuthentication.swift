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
    @Published public private(set) var authenticationAction: AuthenticationAction {
        didSet {
            switch authenticationAction {
            case .notAuthenticated:
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
    /// Options are:
    /// - None
    /// - Touch ID
    /// - Face ID
    public var biometryType: LABiometryType {
        context.biometryType
    }

    /// Indicates if biometrics are supported
    public var isBiometricsSupported: Bool {
        context.biometryType != .none
    }

    /// Initialize object for processing biometrics, if supported by the device
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
            if success {
                self?.authenticationAction = .authenticated
            } else {
                self?.authenticationAction = .error(.authenticationFailed)
            }
        }
    }

    /// Log out the user, if they are already authenticated
    public func logout() {
        if authenticationAction == .authenticated {
            authenticationAction = .notAuthenticated
        }
    }
}
