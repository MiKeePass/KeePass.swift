// TLV.swift
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

import Foundation

public protocol TypeLenghtValue {

    associatedtype Type_

    associatedtype Lenght: BinaryInteger

    associatedtype Value

    var type: Type_ { get }

    var value: Value { get }
}

public protocol Endable: Equatable {
    static var endValue: Self { get }
}

public struct TLV<Type, Lenght>: TypeLenghtValue where Lenght: BinaryInteger {

    public let type: Type

    public private(set) var value: Bytes

    public init(type: Type, value: Bytes) {
        self.type = type
        self.value = value
    }

    public func get<T>() throws -> T where T: LosslessBytesConvertible {
        try T(value)
    }

    public mutating func set<T>(_ value: T?) throws where T: LosslessBytesConvertible {
        self.value = value?.bytes ?? []
    }
}

extension TLV: Readable where Type: Readable, Lenght: Readable {

    public init(from input: Input) throws {
        type = try input.read()
        let lenght = try input.read() as Lenght
        value = try input.read(lenght: Int(lenght))
    }
}

extension TLV: Writable where Type: Writable, Lenght: Writable {

    public func write(to output: Output) throws {
        try output.write(type)
        try output.write(Lenght(value.lenght))
        try output.write(value)
    }
}

extension Sequence where Element: TypeLenghtValue, Element.Type_: Equatable, Element.Value == Bytes {

    public func first<T>(valueOf type: Element.Type_) throws -> T? where T: LosslessBytesConvertible {
        return try first(where: { $0.type == type }).map { try T($0.value) }
    }

    public func first<T>(where type: Element.Type_, _ predicate: (T) throws -> Bool) throws -> Element?
        where T: LosslessBytesConvertible {
        return try first(where: { try predicate(try T($0.value)) })
    }

    public func sorted<T>(field: Element.Type_,
                          by areInIncreasingOrder: (T, T) throws -> Bool) throws -> [Self.Element]
        where T: LosslessBytesConvertible {
        return try sorted(by: { try areInIncreasingOrder(try T($0.value), try T($1.value)) })
    }

    public subscript<T>(_ type: Element.Type_) -> T? where T: LosslessBytesConvertible {
        try? first(valueOf: type)
    }
}

extension RangeReplaceableCollection where Element: TypeLenghtValue, Element.Type_: Equatable {

    public mutating func removeAll(_ type: Element.Type_) {
        removeAll(where: { $0.type == type })
    }
}

extension TLV: CustomDebugStringConvertible {

    public var debugDescription: String {
        "(T:\(type)\nL:\(value.lenght)/nV:\(value.hexa)"
    }
}

extension Array: Readable where Element: TypeLenghtValue & Readable, Element.Type_: Endable {

    public init(from input: Input) throws {
        var fields: [Element] = []

        while true {
            let field: Element = try input.read()
            fields.append(field)
            if field.type == Element.Type_.endValue { break }
        }

        self = fields
    }
}
