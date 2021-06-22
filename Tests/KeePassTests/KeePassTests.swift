import Binary
@testable import KeePass
import XCTest

final class KeePassTests: XCTestCase {

    func testKDB() throws {
        let file = Bundle.module.url(forResource: "test-password-1234", withExtension: "kdb")!
        let key = CompositeKey(password: "1234")
        let db = try KeePass.open(contentOf: file, compositeKey: key)
        print(db)

        let stream = Output()
        try db.write(to: stream, compositeKey: key)
        print(stream.lenght)
    }

    func testKDBX3() throws {
        let file = Bundle.module.url(forResource: "test-password-1234", withExtension: "kdbx")!
        let key = CompositeKey(password: "1234")
        let db = try KeePass.open(contentOf: file, compositeKey: key)
        print(db)
    }

    func testKDBX4() throws {
        let file = Bundle.module.url(forResource: "argon2-kdf-AES-cipher", withExtension: "kdbx")!
        let key = CompositeKey(password: "test")
        let db = try KeePass.open(contentOf: file, compositeKey: key)
        print(db)
    }
}
