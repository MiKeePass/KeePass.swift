// AES.swift
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

import Foundation
import Binary
import CommonCrypto

public final class AESCipher: Cipher {

    public let key: Bytes

    public let iv: Bytes

    public init(key: Bytes, iv: Bytes) throws {

        guard key.lenght == kCCKeySizeAES256 else {
            throw CryptoError.keyLenght(expecting: "Equal \(kCCKeySizeAES256)", got: key.lenght)
        }

        guard iv.lenght == kCCBlockSizeAES128 else {
            throw CryptoError.ivLenght(expecting: "Equal \(kCCBlockSizeAES128)", got: iv.lenght)
        }

        self.key = key
        self.iv = iv
    }

    public func encrypt(data: Bytes) throws -> Bytes {

        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)

        var out = Bytes(lenght: data.lenght + kCCBlockSizeAES128)
        var count: Int = 0

        let status = CCCrypt(operation, algoritm, options,
                             key.rawValue, key.lenght,
                             iv.rawValue,
                             data.rawValue, data.lenght,
                             &out.rawValue, out.lenght,
                             &count)

        guard status == kCCSuccess else { throw CryptoError.crypto(status: status) }

        return out.prefix(count)
    }

    public func decrypt(data: Bytes) throws -> Bytes {
        guard data.lenght % kCCBlockSizeAES128 == 0 else { throw CryptoError.invalidLenght }

        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)

        var out = Bytes(lenght: data.lenght)
        var count: Int = 0

        let status = CCCrypt(operation, algoritm, options,
                             key.rawValue, key.lenght,
                             iv.rawValue,
                             data.rawValue, data.lenght,
                             &out.rawValue, out.lenght,
                             &count)

        guard status == kCCSuccess else { throw CryptoError.crypto(status: status) }

        return out.prefix(count)
    }

}

public final class AESKeyDerivation: KeyDerivation {

    public let seed: Bytes

    public let rounds: UInt64

    public init(seed: Bytes, rounds: UInt64) throws {
        guard seed.lenght == kCCKeySizeAES256 else { throw CryptoError.invalidLenght }
        self.seed = seed
        self.rounds = rounds
    }

    public func derive(key: Bytes) throws -> Bytes {
        guard key.lenght == kCCKeySizeAES256 else { throw CryptoError.invalidLenght }

        let cryptor = UnsafeMutablePointer<CCCryptorRef?>.allocate(capacity: 1)

        var status = CCCryptorCreate(CCOperation(kCCEncrypt),
                                     CCAlgorithm(kCCAlgorithmAES128),
                                     CCOptions(kCCOptionECBMode),
                                     key.rawValue,
                                     key.lenght,
                                     nil,
                                     cryptor)

        guard status == kCCSuccess else { throw CryptoError.crypto(status: status) }

        var out = key
        var count = rounds
        var dataOutMoved: Int = 0

        while count > 0 {
            status = CCCryptorUpdate(cryptor.pointee,
                                     out.rawValue,
                                     out.lenght,
                                     &out.rawValue,
                                     out.lenght,
                                     &dataOutMoved)

            guard status == kCCSuccess else { throw CryptoError.crypto(status: status) }
            count -= 1
        }

        CCCryptorRelease(cryptor.pointee)
        cryptor.deallocate()

        return SHA256.hash(out)
    }

}
