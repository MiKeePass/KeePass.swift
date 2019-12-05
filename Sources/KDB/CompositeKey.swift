// CompositeKey.swift
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

public protocol CompositeKey {

    var password: String { get }

    var key: Bytes { get }
}

extension CompositeKey {

    func serialize() throws -> Bytes {
        guard let password = Bytes(string: password, using: .isoLatin1) else {
            throw KDBError.invalidPassword
        }

        if password.isEmpty, key.isEmpty {
            throw KDBError.emptyCompositeKey
        }

        if key.isEmpty {
            return SHA256.hash(password)
        }

        if password.isEmpty {
            return key
        }

        return SHA256.hash( SHA256.hash(password) + key )
    }
}
