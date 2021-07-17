import Foundation
import LocalAuthentication

/// Used for internal unit tests, but also available for your testing
public final class MockContext: ContextProtocol {
    private let mockBiometryType: LABiometryType

    /// The value of this property is used to produce the auth/non-auth response for evaluatePolicy function
    public var mockEvaluateReply: (Bool, Error?) = (false, nil)

    public var biometryType: LABiometryType {
        mockBiometryType
    }

    public var localizedCancelTitle: String?

    /// Create a mock context object for testing purposes
    /// - Parameters:
    ///   - mockBiometryType: Indicate the type of biometry to use. Default is none
    ///   - isAuthenticated: Indicate if the user should be authenticated. Default value is false
    public init(mockBiometryType: LABiometryType = .none,
                isAuthenticated: Bool = false) {
        self.mockBiometryType = mockBiometryType
        if isAuthenticated {
            mockEvaluateReply = (true, nil)
        }
    }

    /// Returns a `Bool` indicating `mockBiometryType != .none`
    /// - Parameters:
    ///   - : Ignored
    ///   - _: Ignored
    /// - Returns: Indicates if `mockBiometryType != .none`
    public func canEvaluatePolicy(_: LAPolicy,
                                  error _: NSErrorPointer) -> Bool {
        mockBiometryType != .none
    }

    /// Returns the result of `mockEvaluateReply`.
    ///
    /// The ``LAPolicy`` and `localizedReason` parameters are ignored
    /// with the value of `mockEvaluateReply` used to populate `reply`
    ///
    /// - Parameters:
    ///   - : Ignored
    ///   - _: Ignored
    ///   - reply: Contents of `mockEvaluateReply`
    public func evaluatePolicy(_: LAPolicy,
                               localizedReason _: String,
                               reply: @escaping (Bool, Error?) -> Void) {
        reply(mockEvaluateReply.0, mockEvaluateReply.1)
    }
}
