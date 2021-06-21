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
        guard let password = Bytes(string: password, using: .utf8) else {
            throw KDBXError.invalidPassword
        }

        if password.isEmpty, key.isEmpty {
            throw KDBXError.emptyCompositeKey
        }

        let hash = SHA256()

        if !password.isEmpty {
            hash.update(SHA256.hash(password))
        }

        if !key.isEmpty {
            hash.update(key)
        }

        return hash.final
    }
}
