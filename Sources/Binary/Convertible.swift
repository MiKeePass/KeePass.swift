// Convertible.swift
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

/// A type with a customized bytes representation.
public protocol CustomBytesConvertible {

    /// A bytes representation of this instance.
    var bytes: Bytes { get }
}

public protocol LosslessBytesConvertible: CustomBytesConvertible {

    /// Instantiates an instance of the conforming type from bytes
    /// representation.
    init(_ bytes: Bytes) throws
}

// MARK: - Streamable Boolean Bytes

extension Bool: LosslessBytesConvertible {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes($0) }
    }
}

// MARK: - Streamable Integer

extension LosslessBytesConvertible where Self: BinaryInteger {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes($0) }
    }
}

extension Int: LosslessBytesConvertible {}

extension Int8: LosslessBytesConvertible {}

extension Int16: LosslessBytesConvertible {}

extension Int32: LosslessBytesConvertible {}

extension Int64: LosslessBytesConvertible {}

extension UInt: LosslessBytesConvertible {}

extension UInt8: LosslessBytesConvertible {}

extension UInt16: LosslessBytesConvertible {}

extension UInt32: LosslessBytesConvertible {}

extension UInt64: LosslessBytesConvertible {}

// MARK: - Streamable Floating Point

extension LosslessBytesConvertible where Self: FloatingPoint {

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<Self>.size else { throw BinaryError.invalidLenght }
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var bytes: Bytes {
        withUnsafeBytes(of: self) { Bytes($0) }
    }
}

extension Double: LosslessBytesConvertible {}

extension Float: LosslessBytesConvertible {}

// MARK: - RawRepresentable Bytes

extension LosslessBytesConvertible where Self: RawRepresentable, RawValue: LosslessBytesConvertible {

    public init(_ bytes: Bytes) throws {
        let rawValue = try RawValue(bytes)
        guard let value = Self(rawValue: rawValue) else { throw BinaryError.invalidValue }
        self = value
    }

    public var bytes: Bytes { rawValue.bytes }
}

// MARK: - Bytes

extension Bytes: LosslessBytesConvertible {

    public init(_ bytes: Bytes) throws {
        self = bytes
    }

    public var bytes: Bytes { self }
}

// MARK: - Bytes Array

extension Array where Element == Bytes {

    subscript<T>(_ index: Int) -> T? where T: LosslessBytesConvertible {
        try? T(self[index])
    }
}

// MARK: - Bytes Dictionary

extension Dictionary where Value == Bytes {

    subscript<T>(_ key: Key) -> T? where T: LosslessBytesConvertible {
        guard let bytes = self[key] else { return nil }
        return try? T(bytes)
    }
}

// MARK: - String Bytes

extension String: LosslessBytesConvertible {

    public var bytes: Bytes { bytes(using: .utf8) ?? [] }

    public init(_ bytes: Bytes) throws {
        guard let string = String(bytes: bytes, encoding: .utf8) else { throw BinaryError.invalidValue }
        self = string
    }
}

// MARK: - Data Bytes

extension Data: LosslessBytesConvertible {

    public var bytes: Bytes { Bytes(data: self) }

    public init(_ bytes: Bytes) throws {
        self = Data(bytes.rawValue)
    }
}

// MARK: - UUID Bytes

extension UUID: LosslessBytesConvertible {

    public var bytes: Bytes {
        withUnsafeBytes(of: uuid) { Bytes($0) }
    }

    public init(_ bytes: Bytes) throws {
        guard bytes.lenght == MemoryLayout<uuid_t>.size else { throw BinaryError.invalidLenght }
        let uuid = bytes.withUnsafeBytes { $0.load(as: uuid_t.self) }
        self = UUID(uuid: uuid)
    }
}

extension Optional where Wrapped: LosslessBytesConvertible {

    public init(_ bytes: Bytes?) {
        if let bytes = bytes, let wrapped = try? Wrapped(bytes) {
            self = .some(wrapped)
        } else {
            self = .none
        }
    }
}
