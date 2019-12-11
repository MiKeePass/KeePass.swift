// TLV.swift
// This file is part of MiKee.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// MiKee is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MiKee is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MiKee. If not, see <https://www.gnu.org/licenses/>.

import Foundation

public protocol TLVProtocol {

    associatedtype `Type`

    associatedtype Lenght: BinaryInteger

    associatedtype Value

    var type: Type { get }

    var value: Value { get set }
}

public struct TLV<Type, Lenght>: TLVProtocol where Lenght: BinaryInteger {

    public let type: Type

    public var value: Bytes

    public init(type: Type, value: Bytes) {
        self.type = type
        self.value = value
    }

    public func get<T>() throws -> T where T: BytesRepresentable {
        return try T(value)
    }

    public mutating func set<T>(_ value: T?) throws where T: BytesRepresentable {
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

extension Sequence where Element: TLVProtocol, Element.`Type`: Equatable, Element.Value == Bytes {

    public func first<T>(valueOf type: Element.`Type`) throws -> T? where T: BytesRepresentable {
        return try first(where: { $0.type == type }).map { try T($0.value) }
    }

    public func first<T>(where type: Element.`Type`, _ predicate: (T) throws -> Bool) throws -> Element? where T: BytesRepresentable {
        return try first(where: { try predicate(try T($0.value)) })
    }

    public func sorted<T>(field: Element.`Type`, by areInIncreasingOrder: (T, T) throws -> Bool) throws -> [Self.Element] where T: BytesRepresentable {
        return try sorted(by: { try areInIncreasingOrder(try T($0.value), try T($1.value)) })
    }

    public subscript<T>(_ type: Element.`Type`) -> T? where T: BytesRepresentable {
        try? first(valueOf: type)
    }
}

extension RangeReplaceableCollection where Element: TLVProtocol, Element.`Type`: Equatable {

    public mutating func removeAll(_ type: Element.`Type`) {
        removeAll(where: { $0.type == type })
    }

}

extension TLV: CustomDebugStringConvertible {

    public var debugDescription: String {
        "(T:\(type) L:\(value.lenght))"
    }

}
