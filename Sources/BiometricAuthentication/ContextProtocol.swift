import Foundation

import LocalAuthentication

/// Supports mocking of the ``LAContext`` type
public protocol ContextProtocol {
    var biometryType: LABiometryType { get }
    var localizedCancelTitle: String? { get set }

    @discardableResult
    func canEvaluatePolicy(_ policy: LAPolicy,
                           error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy,
                        localizedReason: String,
                        reply: @escaping (Bool, Error?) -> Void)
}

extension LAContext: ContextProtocol {}
