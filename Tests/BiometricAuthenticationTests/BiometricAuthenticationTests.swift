import Combine
import XCTest

@testable import BiometricAuthentication

final class BiometricAuthenticationTests: XCTestCase {
    private let timeout: TimeInterval = 2.0
    private let dispatchDelay = 0.05

    private var cancelleables = Set<AnyCancellable>()

    func testNoBiometricsDefault() {
        let mockContext = MockContext()
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.biometryType, .none)
        XCTAssertFalse(ba.isBiometricsSupported)
    }

    func testFaceID() {
        let mockContext = MockContext(mockBiometryType: .faceID)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.biometryType, .faceID)
        XCTAssertTrue(ba.isBiometricsSupported)
    }

    func testTouchID() {
        let mockContext = MockContext(mockBiometryType: .touchID)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.biometryType, .touchID)
        XCTAssertTrue(ba.isBiometricsSupported)
    }

    func testLoginNoID() {
        let mockContext = MockContext()
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")
        ba.$authenticationAction
            .dropFirst()
            .sink { action in
                switch action {
                case let .error(error):
                    switch error {
                    case .unsupportedHardware:
                        expect.fulfill()

                    default:
                        XCTFail("Unexpected result")
                    }

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testLoginFaceID() {
        let mockContext = MockContext(mockBiometryType: .faceID,
                                      isAuthenticated: true)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")

        ba.$authenticationAction
            .dropFirst()
            .sink { action in
                switch action {
                case .authenticated:
                    expect.fulfill()

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testLoginTouchID() {
        let mockContext = MockContext(mockBiometryType: .touchID,
                                      isAuthenticated: true)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")
        ba.$authenticationAction
            .dropFirst()
            .sink { action in
                switch action {
                case .authenticated:
                    expect.fulfill()

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testRepeatLoginTouchID() {
        let mockContext = MockContext(mockBiometryType: .touchID,
                                      isAuthenticated: true)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")
        ba.$authenticationAction
            .dropFirst(3)
            .sink { action in
                switch action {
                case .authenticated:
                    expect.fulfill()

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()
        // The response to `login()` is queued on main and requires
        // a small delay to complete before a follow up is made.
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchDelay) {
            ba.login()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testLoginFaceIDFailed() {
        let mockContext = MockContext(mockBiometryType: .faceID)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")
        ba.$authenticationAction
            .dropFirst()
            .sink { action in
                switch action {
                case let .error(error):
                    switch error {
                    case .authenticationFailed:
                        expect.fulfill()

                    default:
                        XCTFail("Unexpected result")
                    }

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()

        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Verifies that a user state is changed to non authenticated
    func testSignOut() {
        let mockContext = MockContext(mockBiometryType: .touchID,
                                      isAuthenticated: true)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        let expect = expectation(description: "expect")
        ba.$authenticationAction
            .dropFirst(2)
            .sink { action in
                switch action {
                case .notAuthenticated:
                    expect.fulfill()

                default:
                    XCTFail("Unexpected result")
                }
            }
            .store(in: &cancelleables)

        ba.login()
        // The response to `login()` is queued on main and requires
        // a small delay to complete before a follow up is made.
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchDelay) {
            ba.logout()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Ensures that there is no update to the authenticationAction
    /// since the user starts in the non authenticated state
    func testSignOutFailed() {
        let mockContext = MockContext(mockBiometryType: .touchID)
        let ba = BiometricAuthentication(context: mockContext,
                                         cancelTitle: "cancel",
                                         reason: "reason")
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)

        ba.$authenticationAction
            .dropFirst()
            .sink { _ in
                XCTFail("Unexpected result")
            }
            .store(in: &cancelleables)

        ba.logout()
        XCTAssertEqual(ba.authenticationAction, .notAuthenticated)
    }
}
