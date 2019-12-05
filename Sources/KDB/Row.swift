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

public protocol Row {
    associatedtype Field: Streamable, Equatable

    init()

    var fields: [TLV<Field, UInt32>] { get set }

    static var End: Field { get }
}

extension Row {

    public subscript (_ field: Field) -> Bytes? {
        get { fields.first(where: { $0.type == field })?.value }
        set {
            fields.removeAll(where: { $0.type == field })
            guard let value = newValue else { return }
            let tlv = TLV<Field, UInt32>(type: field, value: value)
            fields.insert(tlv, at: 0)
        }
    }

    public subscript <T>(_ field: Field) -> T? where T: BytesRepresentable {
        get {
            guard let bytes = self[field] else { return nil }
            return try? T(bytes)
        }
        set { self[field] = newValue?.bytes }
    }
}

extension Readable where Self: Row {

    public init(from input: Input) throws {
        self.init()
        while true {
            let field: TLV<Field, UInt32> = try input.read()
            guard field.type != Self.End else { break }
            fields.append(field)
        }
    }

}

extension Writable where Self: Row {

    public func write(to output: Output) throws {
        try output.write(fields)
        let end = TLV<Field, UInt32>(type: Self.End, value: [])
        try output.write(end)
    }
    
}

extension Sequence where Element: Row {

    public func first<T>(where field: Element.Field, _ predicate: (T) throws -> Bool) throws -> Element? where T: BytesRepresentable {
        return try first(where: {
            guard let bytes = $0[field] else { return false }
            return try predicate(try T(bytes))
        })
    }

    public func sorted<T>(field: Element.Field, by areInIncreasingOrder: (T, T) throws -> Bool) throws -> [Self.Element] where T: BytesRepresentable {
        return try sorted(by: {
            guard let rhs = $0[field], let lhs = $1[field] else { return false }
            return try areInIncreasingOrder(try T(rhs), try T(lhs))
        })
    }

    
}
