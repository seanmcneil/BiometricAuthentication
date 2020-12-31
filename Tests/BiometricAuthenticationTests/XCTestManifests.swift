import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(BiometricAuthenticationTests.allTests),
        ]
    }
#endif
