//
//  GzipTests.swift
//  GzipTests
//
//  Created by 1024jp on 2015-05-11.

/*
 The MIT License (MIT)

 © 2015-2019 1024jp

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import XCTest
import Binary
import Gzip

final class GzipTests: XCTestCase {

    func testGZip() throws {

        for _ in 0..<10 {
            let testSentence = String.lorem(length: Int.random(in: 1..<100_000))

            let bytes = testSentence.bytes(using: .utf8)!
            let gzipped = try bytes.gzipped()
            let uncompressed = try gzipped.gunzipped()
            let uncompressedSentence = String(bytes: uncompressed, encoding: .utf8)

            XCTAssertNotEqual(gzipped, bytes)
            XCTAssertEqual(uncompressedSentence, testSentence)

            XCTAssertTrue(gzipped.isGzipped)
            XCTAssertFalse(bytes.isGzipped)
            XCTAssertFalse(uncompressed.isGzipped)
        }
    }


    func testZeroLength() throws {

        let zeroLengthBytes = Bytes()

        XCTAssertEqual(try zeroLengthBytes.gzipped(), zeroLengthBytes)
        XCTAssertEqual(try zeroLengthBytes.gunzipped(), zeroLengthBytes)
        XCTAssertFalse(zeroLengthBytes.isGzipped)
    }


    func testWrongUngzip() {

        // data not compressed
        let bytes = "testString".bytes(using: .utf8)!

        var uncompressed: Bytes?
        do {
            uncompressed = try bytes.gunzipped()

        } catch let error as GzipError where error.kind == .data {
            XCTAssertEqual(error.message, "incorrect header check")
            XCTAssertEqual(error.message, error.localizedDescription)

        } catch _ {
            XCTFail("Caught incorrect error.")
        }

        XCTAssertNil(uncompressed)
    }


    func testCompressionLevel() throws {

        let bytes = String.lorem(length: 100_000).bytes(using: .utf8)!

        XCTAssertGreaterThan(try bytes.gzipped(level: .bestSpeed).count,
                             try bytes.gzipped(level: .bestCompression).count)
    }


    func testFileDecompression() throws {

        let url = self.bundleFile(name: "test.txt.gz")
        let bytes = try Bytes(contentsOf: url)
        let uncompressed = try bytes.gunzipped()

        XCTAssertTrue(bytes.isGzipped)
        XCTAssertEqual(String(bytes: uncompressed, encoding: .utf8), "test")
    }

}

private extension XCTestCase {

    /// Create URL for bundled test file considering platform.
    ///
    /// - Parameter name: The file name to load in resources.
    func bundleFile(name: String) -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: nil) else {
            fatalError("can't find resource named: '\(name)'")
        }

        return url
    }
}

private extension String {

    /// Generate random letters string for test.
    static func lorem(length: Int) -> String {

        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

        return (0..<length).reduce(into: "") { (string, _) in
            string.append(letters.randomElement()!)
        }
    }

}
