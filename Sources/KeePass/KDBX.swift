// KDBX.swift
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

import Binary
import Foundation
import KDBX
import XML

let DateFormatter = ISO8601DateFormatter()

extension CompositeKey: KDBX.CompositeKey {}

extension KDBX.File: Database {

    public var root: Element { database.document.root.KeePassFile.Root }

    public func write(to output: Output, compositeKey: CompositeKey) throws {
        try write(to: output, compositeKey: compositeKey as KDBX.CompositeKey)
    }
}

extension Element {
    private var this: XML.Element { self }
}

extension XML.Element {

    convenience init(_ field: Field) {
        self.init(name: field.name, value: field.value, attributes: [:])
    }
}

extension Field {

    init?(_ element: XML.Element) {
        guard let key = element.Key.value else { return nil }
        name = key

        value = element.Value.value
        isProtected = element.Value.attributes["Protected"] == "True"
    }
}

extension XML.Element: Entry {

    public var times: Timestamp { Times }

    public var fields: [Field] {
        allDescendants(where: { $0.name == "String" }).compactMap { Field($0) }
    }

    public func set(_ field: Field) {
        allDescendants(where: { $0.name == field.name })
            .forEach { $0.removeFromParent() }
        addChild(XML.Element(field))
    }
}

extension XML.Element: Timestamp {

    public var creationDate: Date {
        CreationTime.date(formatter: DateFormatter) ?? .distantPast
    }

    public var lastModifiedDate: Date {
        get { LastModificationTime.date(formatter: DateFormatter) ?? .distantPast }
        set { LastModificationTime.value = DateFormatter.string(from: newValue) }
    }

    public var lastAccessDate: Date {
        get { LastAccessTime.date(formatter: DateFormatter) ?? .distantPast }
        set { LastAccessTime.value = DateFormatter.string(from: newValue) }
    }

    public var expirationDate: Date? {
        get { ExpiryTime.date(formatter: DateFormatter) }
        set {
            if let value = newValue {
                ExpiryTime.value = DateFormatter.string(from: value)
                addChild(name: "Expires", value: "True")
            } else {
                ExpiryTime.value = DateFormatter.string(from: Date.distantFuture)
                addChild(name: "Expires", value: "False")
            }
        }
    }
}

extension XML.Element: Group {

    public var title: String {
        get { attributes["Title"] ?? "" }
        set { attributes["Title"] = newValue }
    }

    public var icon: Int {
        get {
            guard let attr = attributes["Icon"], let icon = Int(attr) else { return 0 }
            return icon
        }
        set { attributes["Icon"] = "\(newValue)" }
    }

    public var entries: [Element] {
        allDescendants(where: { $0.name == "Entry" })
    }

    public var groups: [Element] {
        allDescendants(where: { $0.name == "Group" })
    }
}
