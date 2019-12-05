// BytesRepresentable.swift
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

// MARK: - Bytes Representatble Protocol

public protocol BytesRepresentable {

    init(_ bytes: Bytes) throws

    var bytes: Bytes { get }
}

// MARK: - Streamable Boolean Bytes

extension Bool: BytesRepresentable {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes($0) }
    }

}

// MARK: - Streamable Integer

extension BytesRepresentable where Self: BinaryInteger {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes($0) }
    }

}

extension Int: BytesRepresentable { }

extension Int8: BytesRepresentable { }

extension Int16: BytesRepresentable { }

extension Int32: BytesRepresentable { }

extension Int64: BytesRepresentable { }

extension UInt: BytesRepresentable { }

extension UInt8: BytesRepresentable { }

extension UInt16: BytesRepresentable { }

extension UInt32: BytesRepresentable { }

extension UInt64: BytesRepresentable { }

// MARK: - Streamable Floating Point

extension BytesRepresentable where Self: FloatingPoint {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes(rawValue: Array($0)) }
    }

}

extension Double: BytesRepresentable { }

extension Float: BytesRepresentable { }

// MARK: - RawRepresentable Bytes

extension BytesRepresentable where Self: RawRepresentable, RawValue: BytesRepresentable {

    public init(_ bytes: Bytes) throws {
        let rawValue = try RawValue(bytes)
        guard let value = Self(rawValue: rawValue) else { throw BinaryError.invalidValue }
        self = value
    }

    public var bytes: Bytes { rawValue.bytes }
}

// MARK: - Bytes

extension Bytes: BytesRepresentable {

    public init(_ bytes: Bytes) throws {
        self = bytes
    }

    public var bytes: Bytes { self }
}

// MARK: - Bytes Array

extension Array where Element == Bytes {

    subscript<T>(_ index: Int) -> T? where T: BytesRepresentable {
        return try? T(self[index])
    }
}

// MARK: - Bytes Dictionary

extension Dictionary where Value == Bytes {

    subscript<T>(_ key: Key) -> T? where T: BytesRepresentable {
        guard let bytes = self[key] else { return nil }
        return try? T(bytes)
    }
}

// MARK: - String Bytes

extension String: BytesRepresentable {

    public var bytes: Bytes { bytes(using: .utf8) ?? [] }

    public init(_ bytes: Bytes) throws {
        guard let string = String(bytes: bytes, encoding: .utf8) else { throw BinaryError.invalidValue }
        self = string
    }

}

// MARK: - Data Bytes

extension Data: BytesRepresentable {

    public var bytes: Bytes { Bytes(data: self) }

    public init(_ bytes: Bytes) throws {
        self = Data(bytes.rawValue)
    }

}

// MARK: - UUID Bytes

extension UUID: BytesRepresentable {

    public var bytes: Bytes {
        withUnsafeBytes(of: uuid) { Bytes($0) }
    }

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<uuid_t>.size else { throw BinaryError.invalidLenght }
        let uuid = bytes.withUnsafeBytes { $0.load(as: uuid_t.self) }
        self = UUID(uuid: uuid)
    }

}
