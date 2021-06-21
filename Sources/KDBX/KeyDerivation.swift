// KeyDerivation.swift
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

import Crypto
import Foundation

typealias KeyDerivationParameters = [String: Variant]

extension AESKeyDerivation {

    static let UUID = Foundation.UUID(uuid: (0xC9, 0xD9, 0xF3, 0x9A, 0x62, 0x8A, 0x44, 0x60,
                                             0xBF, 0x74, 0x0D, 0x08, 0xC1, 0x8A, 0x4F, 0xEA))

    static let TransformSeedKey = "S"
    static let TransformRoundsKey = "R"

    convenience init(parameters: [String: Variant]) throws {
        guard
            let seed = parameters[AESKeyDerivation.TransformSeedKey],
            let rounds = parameters[AESKeyDerivation.TransformRoundsKey]
        else { throw KDBXError.corruptedDatabase }

        try self.init(seed: try seed.unwrap(),
                      rounds: try rounds.unwrap())
    }
}

extension Argon2 {

    static let UUID = Foundation.UUID(uuid: (0xEF, 0x63, 0x6D, 0xDF, 0x8C, 0x29, 0x44, 0x4B,
                                             0x91, 0xF7, 0xA9, 0xA4, 0x03, 0xE3, 0x0A, 0x0C))

    static let SaltKey = "S"
    static let ParallelismKey = "P"
    static let MemoryKey = "M"
    static let IterationsKey = "I"
    static let VersionKey = "V"

    convenience init(parameters: [String: Variant]) throws {
        guard
            let salt = parameters[Argon2.SaltKey],
            let parallelism = parameters[Argon2.ParallelismKey],
            let memory = parameters[Argon2.MemoryKey],
            let iterations = parameters[Argon2.IterationsKey],
            let version = parameters[Argon2.VersionKey]
        else { throw KDBXError.corruptedDatabase }

        self.init(salt: try salt.unwrap(),
                  parallelism: try parallelism.unwrap(),
                  memory: UInt32(try memory.unwrap() as UInt64) / 1024,
                  iterations: UInt32(try iterations.unwrap() as UInt64),
                  version: try version.unwrap())
    }
}
