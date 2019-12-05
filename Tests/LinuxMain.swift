import XCTest

import KeePassTests

var tests = [XCTestCaseEntry]()
tests += KeePassTests.allTests()
tests += BinaryTests.allTests()
XCTMain(tests)
