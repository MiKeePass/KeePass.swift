// TwofishTests.swift
// This file is part of KeePassKit.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// KeePassKit is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// KeePassKit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with KeePassKit. If not, see <https://www.gnu.org/licenses/>.

import Binary
import XCTest

@testable import Crypto

class TwofishTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testKey128_1() throws {
//        let key = Bytes(hex: "00000000000000000000000000000000")!
//        var pt = Bytes(hex: "00000000000000000000000000000000")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "9F589F5CF6122C32B6BFEC2F2AE8C35A", "Twofish: Encrypt Keysize=128 I=1 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "00000000000000000000000000000000", "Twofish: Decrypt Keysize=128 I=1 failed")
//    }
//
//    func testKey128_2() throws {
//        let key = Bytes(hex: "00000000000000000000000000000000")!
//        var pt = Bytes(hex: "9F589F5CF6122C32B6BFEC2F2AE8C35A")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "D491DB16E7B1C39E86CB086B789F5419", "Twofish: Encrypt Keysize=128 I=2 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "9F589F5CF6122C32B6BFEC2F2AE8C35A", "Twofish: Decrypt Keysize=128 I=2 failed")
//    }
//
//    func testKey128_3() throws {
//        let key = Bytes(hex: "9F589F5CF6122C32B6BFEC2F2AE8C35A")!
//        var pt = Bytes(hex: "D491DB16E7B1C39E86CB086B789F5419")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "019F9809DE1711858FAAC3A3BA20FBC3", "Twofish: Encrypt Keysize=128 I=3 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "D491DB16E7B1C39E86CB086B789F5419", "Twofish: Decrypt Keysize=128 I=3 failed")
//    }
//
//    func testKey128_4() throws {
//        let key = Bytes(hex: "D491DB16E7B1C39E86CB086B789F5419")!
//        var pt = Bytes(hex: "019F9809DE1711858FAAC3A3BA20FBC3")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "6363977DE839486297E661C6C9D668EB", "Twofish: Encrypt Keysize=128 I=4 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "019F9809DE1711858FAAC3A3BA20FBC3", "Twofish: Decrypt Keysize=128 I=4 failed")
//    }
//
//    func testKey128_5() throws {
//        let key = Bytes(hex: "019F9809DE1711858FAAC3A3BA20FBC3")!
//        var pt = Bytes(hex: "6363977DE839486297E661C6C9D668EB")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "816D5BD0FAE35342BF2A7412C246F752", "Twofish: Encrypt Keysize=128 I=5 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "6363977DE839486297E661C6C9D668EB", "Twofish: Decrypt Keysize=128 I=5 failed")
//    }
//
//    func testKey128_6() throws {
//        let key = Bytes(hex: "6363977DE839486297E661C6C9D668EB")!
//        var pt = Bytes(hex: "816D5BD0FAE35342BF2A7412C246F752")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "5449ECA008FF5921155F598AF4CED4D0", "Twofish: Encrypt Keysize=128 I=6 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "816D5BD0FAE35342BF2A7412C246F752", "Twofish: Decrypt Keysize=128 I=6 failed")
//    }
//
//    func testKey128_7() throws {
//        let key = Bytes(hex: "816D5BD0FAE35342BF2A7412C246F752")!
//        var pt = Bytes(hex: "5449ECA008FF5921155F598AF4CED4D0")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "6600522E97AEB3094ED5F92AFCBCDD10", "Twofish: Encrypt Keysize=128 I=7 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "5449ECA008FF5921155F598AF4CED4D0", "Twofish: Decrypt Keysize=128 I=7 failed")
//    }
//
//    func testKey128_8() throws {
//        let key = Bytes(hex: "5449ECA008FF5921155F598AF4CED4D0")!
//        var pt = Bytes(hex: "6600522E97AEB3094ED5F92AFCBCDD10")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "34C8A5FB2D3D08A170D120AC6D26DBFA", "Twofish: Encrypt Keysize=128 I=8 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "6600522E97AEB3094ED5F92AFCBCDD10", "Twofish: Decrypt Keysize=128 I=8 failed")
//    }
//
//    func testKey128_9() throws {
//        let key = Bytes(hex: "6600522E97AEB3094ED5F92AFCBCDD10")!
//        var pt = Bytes(hex: "34C8A5FB2D3D08A170D120AC6D26DBFA")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "28530B358C1B42EF277DE6D4407FC591", "Twofish: Encrypt Keysize=128 I=9 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "34C8A5FB2D3D08A170D120AC6D26DBFA", "Twofish: Decrypt Keysize=128 I=9 failed")
//    }
//
//    func testKey128_10() throws {
//        let key = Bytes(hex: "34C8A5FB2D3D08A170D120AC6D26DBFA")!
//        var pt = Bytes(hex: "28530B358C1B42EF277DE6D4407FC591")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "8A8AB983310ED78C8C0ECDE030B8DCA4", "Twofish: Encrypt Keysize=128 I=10 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "28530B358C1B42EF277DE6D4407FC591", "Twofish: Decrypt Keysize=128 I=10 failed")
//    }
//
//    func testKey192_1() throws {
//        let key = Bytes(hex: "000000000000000000000000000000000000000000000000")!
//        var pt = Bytes(hex: "00000000000000000000000000000000")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "EFA71F788965BD4453F860178FC19101", "Twofish: Encrypt Keysize=192 I=1 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "00000000000000000000000000000000", "Twofish: Decrypt Keysize=192 I=1 failed")
//    }
//
//    func testKey192_2() throws {
//        let key = Bytes(hex: "000000000000000000000000000000000000000000000000")!
//        var pt = Bytes(hex: "EFA71F788965BD4453F860178FC19101")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "88B2B2706B105E36B446BB6D731A1E88", "Twofish: Encrypt Keysize=192 I=2 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "EFA71F788965BD4453F860178FC19101", "Twofish: Decrypt Keysize=192 I=2 failed")
//    }
//
//    func testKey192_3() throws {
//        let key = Bytes(hex: "EFA71F788965BD4453F860178FC191010000000000000000")!
//        var pt = Bytes(hex: "88B2B2706B105E36B446BB6D731A1E88")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "39DA69D6BA4997D585B6DC073CA341B2", "Twofish: Encrypt Keysize=192 I=3 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "88B2B2706B105E36B446BB6D731A1E88", "Twofish: Decrypt Keysize=192 I=3 failed")
//    }
//
//    func testKey192_4() throws {
//        let key = Bytes(hex: "88B2B2706B105E36B446BB6D731A1E88EFA71F788965BD44")!
//        var pt = Bytes(hex: "39DA69D6BA4997D585B6DC073CA341B2")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "182B02D81497EA45F9DAACDC29193A65", "Twofish: Encrypt Keysize=192 I=4 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "39DA69D6BA4997D585B6DC073CA341B2", "Twofish: Decrypt Keysize=192 I=4 failed")
//    }
//
//    func testKey192_5() throws {
//        let key = Bytes(hex: "39DA69D6BA4997D585B6DC073CA341B288B2B2706B105E36")!
//        var pt = Bytes(hex: "182B02D81497EA45F9DAACDC29193A65")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "7AFF7A70CA2FF28AC31DD8AE5DAAAB63", "Twofish: Encrypt Keysize=192 I=5 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "182B02D81497EA45F9DAACDC29193A65", "Twofish: Decrypt Keysize=192 I=5 failed")
//    }
//
//    func testKey192_6() throws {
//        let key = Bytes(hex: "182B02D81497EA45F9DAACDC29193A6539DA69D6BA4997D5")!
//        var pt = Bytes(hex: "7AFF7A70CA2FF28AC31DD8AE5DAAAB63")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "D1079B789F666649B6BD7D1629F1F77E", "Twofish: Encrypt Keysize=192 I=6 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "7AFF7A70CA2FF28AC31DD8AE5DAAAB63", "Twofish: Decrypt Keysize=192 I=6 failed")
//    }
//
//    func testKey192_7() throws {
//        let key = Bytes(hex: "7AFF7A70CA2FF28AC31DD8AE5DAAAB63182B02D81497EA45")!
//        var pt = Bytes(hex: "D1079B789F666649B6BD7D1629F1F77E")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "3AF6F7CE5BD35EF18BEC6FA787AB506B", "Twofish: Encrypt Keysize=192 I=7 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "D1079B789F666649B6BD7D1629F1F77E", "Twofish: Decrypt Keysize=192 I=7 failed")
//    }
//
//    func testKey192_8() throws {
//        let key = Bytes(hex: "D1079B789F666649B6BD7D1629F1F77E7AFF7A70CA2FF28A")!
//        var pt = Bytes(hex: "3AF6F7CE5BD35EF18BEC6FA787AB506B")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "AE8109BFDA85C1F2C5038B34ED691BFF", "Twofish: Encrypt Keysize=192 I=8 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "3AF6F7CE5BD35EF18BEC6FA787AB506B", "Twofish: Decrypt Keysize=192 I=8 failed")
//    }
//
//    func testKey192_9() throws {
//        let key = Bytes(hex: "3AF6F7CE5BD35EF18BEC6FA787AB506BD1079B789F666649")!
//        var pt = Bytes(hex: "AE8109BFDA85C1F2C5038B34ED691BFF")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "893FD67B98C550073571BD631263FC78", "Twofish: Encrypt Keysize=192 I=9 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "AE8109BFDA85C1F2C5038B34ED691BFF", "Twofish: Decrypt Keysize=192 I=9 failed")
//    }
//
//    func testKey192_10() throws {
//        let key = Bytes(hex: "AE8109BFDA85C1F2C5038B34ED691BFF3AF6F7CE5BD35EF1")!
//        var pt = Bytes(hex: "893FD67B98C550073571BD631263FC78")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "16434FC9C8841A63D58700B5578E8F67", "Twofish: Encrypt Keysize=192 I=10 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "893FD67B98C550073571BD631263FC78", "Twofish: Decrypt Keysize=192 I=10 failed")
//    }
//
//    func testKey256_1() throws {
//        let key = Bytes(hex: "0000000000000000000000000000000000000000000000000000000000000000")!
//        var pt = Bytes(hex: "00000000000000000000000000000000")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "57FF739D4DC92C1BD7FC01700CC8216F", "Twofish: Encrypt Keysize=256 I=1 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "00000000000000000000000000000000", "Twofish: Decrypt Keysize=256 I=1 failed")
//    }
//
//    func testKey256_2() throws {
//        let key = Bytes(hex: "0000000000000000000000000000000000000000000000000000000000000000")!
//        var pt = Bytes(hex: "57FF739D4DC92C1BD7FC01700CC8216F")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "D43BB7556EA32E46F2A282B7D45B4E0D", "Twofish: Encrypt Keysize=256 I=2 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "57FF739D4DC92C1BD7FC01700CC8216F", "Twofish: Decrypt Keysize=256 I=2 failed")
//    }
//
//    func testKey256_3() throws {
//        let key = Bytes(hex: "57FF739D4DC92C1BD7FC01700CC8216F00000000000000000000000000000000")!
//        var pt = Bytes(hex: "D43BB7556EA32E46F2A282B7D45B4E0D")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "90AFE91BB288544F2C32DC239B2635E6", "Twofish: Encrypt Keysize=256 I=3 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "D43BB7556EA32E46F2A282B7D45B4E0D", "Twofish: Decrypt Keysize=256 I=3 failed")
//    }
//
//    func testKey256_4() throws {
//        let key = Bytes(hex: "D43BB7556EA32E46F2A282B7D45B4E0D57FF739D4DC92C1BD7FC01700CC8216F")!
//        var pt = Bytes(hex: "90AFE91BB288544F2C32DC239B2635E6")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "6CB4561C40BF0A9705931CB6D408E7FA", "Twofish: Encrypt Keysize=256 I=4 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "90AFE91BB288544F2C32DC239B2635E6", "Twofish: Decrypt Keysize=256 I=4 failed")
//    }
//
//    func testKey256_5() throws {
//        let key = Bytes(hex: "90AFE91BB288544F2C32DC239B2635E6D43BB7556EA32E46F2A282B7D45B4E0D")!
//        var pt = Bytes(hex: "6CB4561C40BF0A9705931CB6D408E7FA")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "3059D6D61753B958D92F4781C8640E58", "Twofish: Encrypt Keysize=256 I=5 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "6CB4561C40BF0A9705931CB6D408E7FA", "Twofish: Decrypt Keysize=256 I=5 failed")
//    }
//
//    func testKey256_6() throws {
//        let key = Bytes(hex: "6CB4561C40BF0A9705931CB6D408E7FA90AFE91BB288544F2C32DC239B2635E6")!
//        var pt = Bytes(hex: "3059D6D61753B958D92F4781C8640E58")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "E69465770505D7F80EF68CA38AB3A3D6", "Twofish: Encrypt Keysize=256 I=6 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "3059D6D61753B958D92F4781C8640E58", "Twofish: Decrypt Keysize=256 I=6 failed")
//    }
//
//    func testKey256_7() throws {
//        let key = Bytes(hex: "3059D6D61753B958D92F4781C8640E586CB4561C40BF0A9705931CB6D408E7FA")!
//        var pt = Bytes(hex: "E69465770505D7F80EF68CA38AB3A3D6")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "5AB67A5F8539A4A5FD9F0373BA463466", "Twofish: Encrypt Keysize=256 I=7 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "E69465770505D7F80EF68CA38AB3A3D6", "Twofish: Decrypt Keysize=256 I=7 failed")
//    }
//
//    func testKey256_8() throws {
//        let key = Bytes(hex: "E69465770505D7F80EF68CA38AB3A3D63059D6D61753B958D92F4781C8640E58")!
//        var pt = Bytes(hex: "5AB67A5F8539A4A5FD9F0373BA463466")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "DC096BCD99FC72F79936D4C748E75AF7", "Twofish: Encrypt Keysize=256 I=8 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "5AB67A5F8539A4A5FD9F0373BA463466", "Twofish: Decrypt Keysize=256 I=8 failed")
//    }
//
//    func testKey256_9() throws {
//        let key = Bytes(hex: "5AB67A5F8539A4A5FD9F0373BA463466E69465770505D7F80EF68CA38AB3A3D6")!
//        var pt = Bytes(hex: "DC096BCD99FC72F79936D4C748E75AF7")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "C5A3E7CEE0F1B7260528A68FB4EA05F2", "Twofish: Encrypt Keysize=256 I=9 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "DC096BCD99FC72F79936D4C748E75AF7", "Twofish: Decrypt Keysize=256 I=9 failed")
//    }
//
//    func testKey256_10() throws {
//        let key = Bytes(hex: "DC096BCD99FC72F79936D4C748E75AF75AB67A5F8539A4A5FD9F0373BA463466")!
//        var pt = Bytes(hex: "C5A3E7CEE0F1B7260528A68FB4EA05F2")!
//        let ct = try Twofish(key: key).encrypt(data: pt)
//        XCTAssertEqual(ct.hexa.uppercased(), "43D5CEC327B24AB90AD34A79D0469151", "Twofish: Encrypt Keysize=256 I=10 failed")
//
//        pt = try Twofish(key: key).decrypt(data: ct)
//        XCTAssertEqual(pt.hexa.uppercased(), "C5A3E7CEE0F1B7260528A68FB4EA05F2", "Twofish: Decrypt Keysize=256 I=10 failed")
//    }
}
