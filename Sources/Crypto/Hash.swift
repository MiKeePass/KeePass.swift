// Hash.swift
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
import Sodium

public final class SHA256 {

    public static let Lenght = Int(crypto_hash_sha256_BYTES)

    private var state: crypto_hash_sha256_state

    public var final: Bytes {
        var out = Bytes(lenght: SHA256.Lenght)
        crypto_hash_sha256_final(&state, &out.rawValue)
        return out
    }

    public init() {
        state = crypto_hash_sha256_state()
        crypto_hash_sha256_init(&state)
    }

    public func update(_ bytes: Bytes) {
        crypto_hash_sha256_update(&state, bytes.rawValue, lenght(bytes));
    }

    public static func hash(_ bytes: Bytes) -> Bytes {
        var out = Bytes(lenght: SHA256.Lenght)
        crypto_hash_sha256(&out.rawValue, bytes.rawValue, lenght(bytes))
        return out
    }

}

public final class SHA512 {

    public static let Lenght = Int(crypto_hash_sha512_BYTES)

    private var state: crypto_hash_sha512_state

    public var final: Bytes {
        var out = Bytes(lenght: SHA512.Lenght)
        crypto_hash_sha512_final(&state, &out.rawValue)
        return out
    }

    public init() {
        state = crypto_hash_sha512_state()
        crypto_hash_sha512_init(&state)
    }

    public func update(_ bytes: Bytes) {
        crypto_hash_sha512_update(&state, bytes.rawValue, lenght(bytes));
    }

    public static func hash(_ bytes: Bytes) -> Bytes {
        var out = Bytes(lenght: SHA512.Lenght)
        crypto_hash_sha512(&out.rawValue, bytes.rawValue, lenght(bytes))
        return out
    }

}

public final class HMACSHA256 {

    public static let Lenght = Int(crypto_auth_hmacsha256_BYTES)

    private var state: crypto_auth_hmacsha256_state

    public var final: Bytes {
        var out = Bytes(lenght: HMACSHA256.Lenght)
        crypto_auth_hmacsha256_final(&state, &out.rawValue)
        return out
    }

    public init(key: Bytes) {
        state = crypto_auth_hmacsha256_state()
        crypto_auth_hmacsha256_init(&state, key.rawValue, lenght(key))
    }

    public func update(_ bytes: Bytes) {
        crypto_auth_hmacsha256_update(&state, bytes.rawValue, lenght(bytes));
    }

    public static func authenticate(_ bytes: Bytes, key: Bytes) -> Bytes {
        let hmac = HMACSHA256(key: key)
        hmac.update(bytes)
        return hmac.final
    }

}
