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

extension CompositeKey: KDB.CompositeKey { }

extension KDB.Database: Database {}

extension TLV where Type == KDB.Entry.Column {

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
        set { self[.iconID] =  newValue }
    }

    public var groups: [KDB.Group] { childs }
}

extension KDB.Entry: Entry {

    public var times: Timestamp {
         return self
    }

    public var fields: [Field] {
        properties.compactMap { Field($0) }
    }

    public func set(_ field: Field) {
        guard let field = TLV<Column, UInt32>(field) else { return }
        set(field)
    }

}

extension KDB.Entry: Timestamp {

    public var creationDate: Date {
        date(at: .creationTime) ?? Date.distantPast
    }

    public var lastModifiedDate: Date {
        get { date(at: .lastModifiedTime) ?? Date.distantPast }
        set { set(newValue, at: .lastModifiedTime) }
    }

    public var lastAccessDate: Date {
        get { date(at: .lastAccessTime) ?? Date.distantPast }
        set { set(newValue, at: .lastAccessTime) }
    }

    public var expirationDate: Date? {
        get { nil }
        set { }
    }

}

extension Field {

    init?(_ field: TLV<KDB.Entry.Column, UInt32>) {

        switch field.type {
        case .title:
            name = EntryFieldTitle
        case .url:
            name = EntryFieldURL
        case .username:
            name = EntryFieldUserName
        case .password:
            name = EntryFieldPassword
        case .notes:
            name = EntryFieldNotes
        default:
            return nil
        }

        value = try? field.get()
        isProtected = field.type == .password
    }
}
