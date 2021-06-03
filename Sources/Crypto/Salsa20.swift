// Salsa20.swift
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

public final class Salsa20 {

    public let key: Bytes

    public let nonce: Bytes

    public init(key: Bytes, iv nonce: Bytes) throws {

        guard key.lenght == crypto_stream_salsa20_KEYBYTES else {
            throw CryptoError.keyLenght(expecting: "Equal \(crypto_stream_salsa20_KEYBYTES)", got: key.lenght)
        }

        guard nonce.lenght == crypto_stream_salsa20_NONCEBYTES else {
            throw CryptoError.ivLenght(expecting: "Equal \(crypto_stream_salsa20_NONCEBYTES)", got: nonce.lenght)
        }

        self.key = key
        self.nonce = nonce
    }
}

extension Salsa20: Cipher {

    public func encrypt(data: Bytes) throws -> Bytes {
        var out = Bytes(lenght: lenght(data))
        crypto_stream_salsa20_xor(&out.rawValue, data.rawValue, lenght(data), nonce.rawValue, key.rawValue);
        return out
    }

    public func decrypt(data: Bytes) throws -> Bytes {
        try encrypt(data: data)
    }

}
