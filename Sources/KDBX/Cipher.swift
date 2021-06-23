// Cipher.swift
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

import Crypto
import Foundation

extension AESCipher {

    static let UUID = Foundation.UUID(uuid: (0x31, 0xC1, 0xF2, 0xE6, 0xBF, 0x71, 0x43, 0x50,
                                             0xBE, 0x58, 0x05, 0x21, 0x6A, 0xFC, 0x5A, 0xFF))
}

extension ChaCha20 {

    static let UUID = Foundation.UUID(uuid: (0xD6, 0x03, 0x8A, 0x2B, 0x8B, 0x6F, 0x4C, 0xB5,
                                             0xA5, 0x24, 0x33, 0x9A, 0x31, 0xDB, 0xB5, 0x9A))
}

extension Twofish {

    static let UUID = Foundation.UUID(uuid: (0xAD, 0x68, 0xF2, 0x9F, 0x57, 0x6F, 0x4B, 0xB9,
                                             0xA3, 0x6A, 0xD4, 0x7A, 0xF9, 0x65, 0x34, 0x6C))
}
