// Entry.swift
// This file is part of KeePass.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
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

public let EntryFieldTitle    = "Title"
public let EntryFieldUserName = "UserName"
public let EntryFieldPassword = "Password"
public let EntryFieldURL      = "URL"
public let EntryFieldNotes    = "Notes"

public protocol Entry {

    associatedtype Fields: RandomAccessCollection where Fields.Element == Field

    var times: Timestamp { get }

    var fields: Fields { get }
    
    mutating func set(_ field: Fields.Element)
}

extension Entry {

    subscript(_ field: String) -> Fields.Element? {
        return fields.first(where: { $0.name == field })
    }
}
