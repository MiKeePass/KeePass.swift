import XCTest

import KeePassTests

var tests = [XCTestCaseEntry]()
tests += KeePassTests.allTests()
tests += CryptoTests.allTests()
tests += BinaryTests.allTests()
XCTMain(tests)
