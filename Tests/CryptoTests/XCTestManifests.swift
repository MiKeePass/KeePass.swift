import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Chacha20Tests.allTests),
        testCase(Salsa20Tests.allTests),
    ]
}
#endif
