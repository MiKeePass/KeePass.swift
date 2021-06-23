// Header.swift
// This file is part of KeePass.swift
//
// Copyright © 2021 Maxime Epain. All rights reserved.
//
// KeePass.swift is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// KeePass.swift is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with KeePass.swift. If not, see <https://www.gnu.org/licenses/>.

import Binary
import Crypto
import Foundation

typealias Header<T, L> = [TLV<T, L>] where L: BinaryInteger

enum OuterHeader: UInt8, Streamable, Endable {
    case end = 0
    case comment = 1
    case cipherID = 2
    case compressionFlags = 3
    case masterSeed = 4
    case transformSeed = 5
    case transformRounds = 6
    case initialVector = 7
    case protectedStreamKey = 8
    case streamStartBytes = 9
    case innerRandomStreamID = 10
    case kdfParameters = 11
    case publicCustomData = 12

    public static var endValue: OuterHeader { .end }
}

enum InnerHeader: UInt8, Streamable, Endable {
    case end = 0
    case innerRandomStreamID = 1
    case innerRandomStreamKey = 2
    case binary = 3

    public static var endValue: InnerHeader { .end }
}

enum Compression: UInt32, LosslessBytesConvertible {
    case none = 0
    case gzip = 1
    case count = 2
}

enum RandomStream: UInt32, LosslessBytesConvertible {
    case none = 0
    case arc4 = 1
    case salsa20 = 2
    case chacha20 = 3
    case count = 4
}

extension Array where Element: TypeLenghtValue, Element.Type_ == OuterHeader, Element.Value == Bytes {

    func cipher(key: Bytes) throws -> Cipher {
        guard
            let uuid: UUID = self[.cipherID],
            let iv: Bytes = self[.initialVector]
        else { throw KDBXError.corruptedDatabase }

        switch uuid {
        case AESCipher.UUID:
            return try AESCipher(key: key, iv: iv)
        case Twofish.UUID:
            return try Twofish(key: key, iv: iv)
        case ChaCha20.UUID:
            return try ChaCha20(key: key, iv: iv)
        default:
            throw KDBXError.unsupportedCipher
        }
    }

    func masterKey(from compositeKey: CompositeKey) throws -> Bytes {
        guard
            let masterSeed: Bytes = self[.masterSeed]
        else { throw KDBXError.corruptedDatabase }

        let key = try compositeKey.serialize()

        // Key Derivation
        let derivedKey = try kdf().derive(key: key)

        return masterSeed + derivedKey
    }

    func kdf() throws -> KeyDerivation {

        if let seed: Bytes = self[.transformSeed], let rounds: UInt64 = self[.transformRounds] {
            return try AESKeyDerivation(seed: seed, rounds: rounds)
        }

        guard
            let parameters: KeyDerivationParameters = self[.kdfParameters],
            let uuid: UUID = try parameters["$UUID"]?.unwrap()
        else { throw KDBXError.corruptedDatabase }

        switch uuid {
        case Argon2.UUID:
            return try Argon2(parameters: parameters)
        case AESKeyDerivation.UUID:
            return try AESKeyDerivation(parameters: parameters)
        default:
            throw KDBXError.unsupportedKeyDerivation
        }
    }
}
