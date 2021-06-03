// Twofish.swift
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
import Twofish

public final class Twofish: Cipher {

    private var context: twofish_context

    public init(key: Bytes, iv: Bytes) throws {

        guard key.lenght <= TWOFISH_KEYSIZE else {
            throw CryptoError.keyLenght(expecting: "Less or equal to \(TWOFISH_KEYSIZE)", got: key.lenght)
        }

        guard iv.lenght == TWOFISH_IVSIZE else {
            throw CryptoError.ivLenght(expecting: "Equal to \(TWOFISH_IVSIZE)", got: iv.lenght)
        }

        context = twofish_context()
        twofish_setup(&context, key.rawValue, iv.rawValue, twofish_options_default)
    }

    public func encrypt(data: Bytes) throws -> Bytes {
        let output_length = twofish_get_output_length(&context, lenght(data))
        var out = Bytes(lenght: Int(output_length))
        twofish_encrypt(&context, data.rawValue, lenght(data), &out.rawValue, output_length)
        return out
    }

    public func decrypt(data: Bytes) throws -> Bytes {
        var out = Bytes(lenght: data.lenght)
        var output_length = data.lenght
        twofish_decrypt(&context, data.rawValue, output_length, &out.rawValue, &output_length)
        return out.prefix(output_length)
    }
    
}
