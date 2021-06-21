// Header.swift
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
import Crypto
import Foundation

struct Header {
    let cipher: Flag
    let version: UInt32
    let masterSeed: Bytes
    let initialVector: Bytes
    var groups: UInt32
    var entries: UInt32
    var contentHash: Bytes
    let transformSeed: Bytes
    let transformRounds: UInt32
}

struct Flag: OptionSet, Streamable {
    let rawValue: UInt32

    static let sha2 = Flag(rawValue: 1 << 0)
    static let aes = Flag(rawValue: 1 << 1)
    static let arc4 = Flag(rawValue: 1 << 2)
    static let twofish = Flag(rawValue: 1 << 3)
}

extension Header: Streamable {

    init(from input: Input) throws {
        cipher = try input.read()
        version = try input.read()
        masterSeed = try input.read(lenght: 16)
        initialVector = try input.read(lenght: 16)
        groups = try input.read()
        entries = try input.read()
        contentHash = try input.read(lenght: 32)
        transformSeed = try input.read(lenght: 32)
        transformRounds = try input.read()
    }

    func write(to output: Output) throws {
        try output.write(cipher)
        try output.write(version)
        try output.write(masterSeed)
        try output.write(initialVector)
        try output.write(groups)
        try output.write(entries)
        try output.write(contentHash)
        try output.write(transformSeed)
        try output.write(transformRounds)
    }
}

extension Header {

    func cipher(key: Bytes) throws -> Cipher {
        if cipher.contains(.aes) {
            return try AESCipher(key: key, iv: initialVector)
        }

        if cipher.contains(.twofish) {
            return try Twofish(key: key, iv: initialVector)
        }

        throw KDBError.unsupportedCipher
    }

    func masterKey(from compositeKey: CompositeKey) throws -> Bytes {
        let key = try compositeKey.serialize()

        // Key Derivation
        let kdf = try AESKeyDerivation(seed: transformSeed, rounds: UInt64(transformRounds))
        let derivedKey = try kdf.derive(key: key)

        return SHA256.hash(masterSeed + derivedKey)
    }
}
