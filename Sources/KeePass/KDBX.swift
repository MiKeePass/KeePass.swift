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

import Foundation
import Binary
import XML
import KDBX

extension KDBX.File: Database {
    public var root: Element { database.document.root }
}

extension Element {
    private var this: XML.Element { self as XML.Element }
}

extension XML.Element {

    convenience init(_ field: Field) {
        self.init(name: field.name, value: field.value, attributes: [:])
    }

}

extension Field {

    init(_ element: XML.Element) {
        name = element.name
        value = element.value
        isProtected = false
        isReadeOnly = false
    }
}

extension XML.Element: Entry {

    public func set(_ field: Field) {
        allDescendants(where: { $0.name == field.name })
            .forEach { $0.removeFromParent() }
        addChild( XML.Element(field) )
    }

    public subscript(position: Int) -> Field {
        Field( children[position] )
    }

    public func index(after i: Int) -> Int {
        children.index(after: i)
    }

    public var startIndex: Int {
        children.startIndex
    }

    public var endIndex: Int {
        children.endIndex
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
        allDescendants(where: { $0.name == "Entry"})
    }

    public var groups: [Element] {
        allDescendants(where: { $0.name == "Group"})
    }

}
