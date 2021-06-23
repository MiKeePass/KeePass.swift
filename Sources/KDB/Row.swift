// Row.swift
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

import Binary
import Foundation

public protocol Row: AnyObject {
    associatedtype Column

    var properties: [TLV<Column, UInt32>] { get set }
}

extension Row where Self: Writable, Column: Writable {

    public func write(to output: Output) throws {
        try output.write(properties)
    }
}

extension Row where Column: Equatable {

    public subscript(_ column: Column) -> Bytes? {
        get { properties.first(where: { $0.type == column })?.value }
        set {
            properties.removeAll(column)
            guard let value = newValue else { return }
            let tlv = TLV<Column, UInt32>(type: column, value: value)
            properties.insert(tlv, at: 0)
        }
    }

    public func set(_ property: TLV<Column, UInt32>) {
        properties.removeAll(property.type)
        properties.insert(property, at: 0)
    }

    public func set(_ date: Date, at column: Column) {
        self[column] = Database.bytes(from: date)
    }

    public func date(at column: Column) -> Date? {
        guard let bytes = self[column] else { return nil }
        return Database.date(from: bytes)
    }

    public subscript<T>(_ column: Column) -> T? where T: BytesRepresentable {
        get { T?(self[column]) }
        set { self[column] = newValue?.bytes }
    }

    public func remove(_ column: Column) {
        properties.removeAll(column)
    }
}

extension Sequence where Element: Row, Element.Column: Equatable {

    public func first<T>(column: Element.Column, where predicate: (T) throws -> Bool) throws -> Element?
        where T: BytesRepresentable {
        try first(where: {
            guard let bytes = $0[column] else { return false }
            return try predicate(T(bytes))
        })
    }

    public func sorted<T>(column: Element.Column, by areInIncreasingOrder: (T, T) throws -> Bool) throws -> [Element]
        where T: BytesRepresentable {
        try sorted(by: {
            guard let rhs = $0[column], let lhs = $1[column] else { return false }
            return try areInIncreasingOrder(T(rhs), T(lhs))
        })
    }
}
