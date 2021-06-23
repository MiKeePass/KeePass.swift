// CompositeKey.swift
// This file is part of KeePass.
//
// Copyright © 2021 Maxime Epain. All rights reserved.
//
// KeePass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// KeePass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with KeePass. If not, see <https://www.gnu.org/licenses/>.

import Binary
import Crypto
import Foundation
import XML

public struct CompositeKey {

    public static let KeyLength = 32

    public let password: String

    public let key: Bytes

    public init(password: String) {
        self.password = password
        key = []
    }

    public init(password: String, key: Data) {
        self.password = password

        if let xml = try? XML.Document(xml: key), let base64: String = try? xml.KeyFile.Key.Data.get(),
           let key = Bytes(base64Encoded: base64) {
            // KeePass 2 XML key file
            self.key = key

        } else if key.count == CompositeKey.KeyLength {
            // Fixed 32 byte binary
            self.key = Bytes(data: key)

        } else if key.count == 2 * CompositeKey.KeyLength, let hex = String(data: key, encoding: .ascii),
                  let key = Bytes(hex: hex) {
            // Fixed 32 byte ASCII hex-encoded binary
            self.key = key

        } else {
            // Arbitrary file
            let binary = Bytes(data: key)
            self.key = SHA256.hash(binary)
        }
    }

    public init(password: String, key url: URL) throws {
        let key = try Data(contentsOf: url)
        self.init(password: password, key: key)
    }
}
