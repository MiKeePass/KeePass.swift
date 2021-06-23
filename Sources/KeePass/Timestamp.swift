// Timestamp.swift
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

import Foundation

public protocol Timestamp {
    var creationDate: Date { get }
    var lastModifiedDate: Date { get set }
    var lastAccessDate: Date { get set }
    var expirationDate: Date? { get set }
}
