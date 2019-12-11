// Row.swift
// This file is part of KeePassKit.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// KeePassKit is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// KeePassKit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with KeePassKit. If not, see <https://www.gnu.org/licenses/>.

import Foundation
import Binary

public typealias Field<Type> = TLV<Type, UInt32>

public protocol Row: class {

    associatedtype `Type`: Streamable, Equatable

    static var End: Type { get }

    var fields: [Field<Type>] { get set }

    init()
}

extension Row {

    public subscript(_ type: Type) -> Bytes? {
        get { fields.first(where: { $0.type == type })?.value }
        set {
            fields.removeAll(where: { $0.type == type })
            guard let value = newValue else { return }
            let tlv = Field(type: type, value: value)
            fields.insert(tlv, at: 0)
        }
    }

    public func set(_ field: Field<Type>) {
        fields.removeAll(where: { $0.type == field.type })
        fields.insert(field, at: 0)
    }

    public subscript<T>(_ type: Type) -> T? where T: BytesRepresentable {
        get {
            guard let bytes = self[type] else { return nil }
            return try? T(bytes)
        }
        set { self[type] = newValue?.bytes }
    }

    public func remove(_ type: Type) {
        fields.removeAll(where: { $0.type == type })
    }
}

extension Readable where Self: Row {

    public init(from input: Input) throws {
        self.init()
        while true {
            let field = try input.read() as Field<Type>
            guard field.type != Self.End else { break }
            fields.append(field)
        }
    }

}

extension Writable where Self: Row {

    public func write(to output: Output) throws {
        try output.write(fields)
        let end = Field(type: Self.End, value: [])
        try output.write(end)
    }
    
}

extension Sequence where Element: Row {

    public func first<T>(where type: Element.`Type`, _ predicate: (T) throws -> Bool) throws -> Element? where T: BytesRepresentable {
        return try first(where: {
            guard let bytes = $0[type] else { return false }
            return try predicate(try T(bytes))
        })
    }

    public func sorted<T>(field: Element.`Type`, by areInIncreasingOrder: (T, T) throws -> Bool) throws -> [Self.Element] where T: BytesRepresentable {
        return try sorted(by: {
            guard let rhs = $0[field], let lhs = $1[field] else { return false }
            return try areInIncreasingOrder(try T(rhs), try T(lhs))
        })
    }

}
