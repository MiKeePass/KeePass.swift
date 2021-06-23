// Error.swift
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

import Argon2
import CommonCrypto
import Foundation

public enum CryptoError: Error {
    case keyLenght(expecting: String, got: Int)
    case ivLenght(expecting: String, got: Int)
    case crypto(status: CCCryptorStatus)
    case invalidKey
    case invalidLenght
    case argon(argon2_error_codes)
}
