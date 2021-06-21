// Argon2.swift
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

import Argon2
import Binary
import Foundation

public final class Argon2: KeyDerivation {

    public let salt: Bytes
    public let parallelism: UInt32
    public let memory: UInt32
    public let iterations: UInt32
    public let version: UInt32

    public init(salt: Bytes, parallelism: UInt32, memory: UInt32, iterations: UInt32, version: UInt32) {
        self.salt = salt
        self.parallelism = parallelism
        self.memory = memory
        self.iterations = iterations
        self.version = version
    }

    public func derive(key: Bytes) throws -> Bytes {

        var out = Bytes(lenght: 32)
        let result = kp_argon2_hash(iterations,
                                    memory,
                                    parallelism,
                                    key.rawValue, key.lenght,
                                    salt.rawValue, salt.lenght,
                                    &out.rawValue, out.lenght,
                                    nil, 0,
                                    Argon2_d,
                                    version)

        let code = argon2_error_codes(result)

        guard code == ARGON2_OK else { throw CryptoError.argon(code) }

        return out
    }
}
