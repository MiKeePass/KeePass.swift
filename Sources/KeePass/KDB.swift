// KDB.swift
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
import Binary
import KDB

extension KDB.Database: Database {

}

extension KDB.Field where Type == KDB.Entry.`Type` {

    init?(_ field: Field) {

        let type: Type
        let value = field.value?.bytes ?? []

        switch field.name {
        case EntryFieldTitle:
            type = .title
        case EntryFieldURL:
            type = .url
        case EntryFieldUserName:
            type = .username
        case EntryFieldPassword:
            type = .password
        case EntryFieldNotes:
            type = .notes
        default:
            return nil
        }

        self.init(type: type, value: value)
    }
}

extension KDB.Group: Group {

    public var title: String {
        get { self[.name] ?? "" }
        set { self[.name] = newValue }
    }

    public var icon: Int {
        get { self[.iconID] ?? 0 }
        set { self[.iconID] = newValue }
    }

    public var groups: [KDB.Group] { childs }
}

extension KDB.Entry: Entry {

    public subscript(position: Int) -> Field {
        Field( fields[position] )
    }

    public var startIndex: Int {
        fields.startIndex
    }

    public var endIndex: Int {
        fields.endIndex
    }

    public func index(after i: Int) -> Int {
        fields.index(after: i)
    }

    public func set(_ field: Field) {
        guard let field = KDB.Field(field) else { return }
        set(field)
    }

}

extension Field {

    init(_ field: KDB.Field<KDB.Entry.`Type`>) {

        switch field.type {
        case .title:
            name = EntryFieldTitle
            isReadeOnly = false
            isProtected = false
        case .url:
            name = EntryFieldURL
            isReadeOnly = false
            isProtected = false
        case .username:
            name = EntryFieldUserName
            isReadeOnly = false
            isProtected = false
        case .password:
            name = EntryFieldPassword
            isReadeOnly = false
            isProtected = true
        case .notes:
            name = EntryFieldNotes
            isReadeOnly = false
            isProtected = false
        default:
            name = ""
            isReadeOnly = true
            isProtected = false
        }

        value = try? field.get()
    }
}
