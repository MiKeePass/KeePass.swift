// Streamable.swift
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

/// A type that can write itself to a binary output.
public protocol Writable {

    /// Writes this value into the given output.
    ///
    /// This function throws an error if any values are invalid for the given format.
    ///
    /// - Parameter output: The output stream to write data to.
    func write(to output: Output) throws
}

/// A type that can read itself from an binary input.
public protocol Readable {

    /// Creates a new instance by reading from the input stream.
    ///
    /// This initializer throws an error if reading from the input fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter input: The input stream to read data from.
    init(from input: Input) throws
}

/// A type that can convert itself into and out of a binary stream.
///
/// `Binary` is a type alias for the `Writable` and `Readable` protocols.
/// When you use `Binary` as a type or a generic constraint, it matches
/// any type that conforms to both protocols.
public typealias Streamable = Readable & Writable

extension Readable where Self: BytesRepresentable {

    public init(from input: Input) throws {
        let bytes = try input.read(lenght: MemoryLayout<Self>.size)
        self = try Self(bytes)
    }

}

extension Writable where Self: BytesRepresentable {

    public func write(to output: Output) throws {
        try output.write(bytes)
    }

}

// MARK: - Streamable Boolean

extension Bool: Streamable { }

// MARK: - Streamable Integer

extension Int: Streamable { }

extension Int8: Streamable { }

extension Int16: Streamable { }

extension Int32: Streamable { }

extension Int64: Streamable { }

extension UInt: Streamable { }

extension UInt8: Streamable { }

extension UInt16: Streamable { }

extension UInt32: Streamable { }

extension UInt64: Streamable { }

// MARK: - Streamable Floating Point

extension Double: Streamable { }

extension Float: Streamable { }

// MARK: - Streamable RawRepresentable

extension Readable where Self: RawRepresentable, RawValue: Readable {

    public init(from input: Input) throws {
        let rawValue = try RawValue(from: input)
        guard let value = Self(rawValue: rawValue) else { throw BinaryError.invalidValue }
        self = value
    }

}

extension Writable where Self: RawRepresentable, RawValue: Writable {

    public func write(to output: Output) throws {
        try output.write(rawValue)
    }
}

// MARK: - Readable OptionSet

extension Readable where Self: OptionSet, RawValue: Readable {

    public init(from input: Input) throws {
        let rawValue = try RawValue(from: input)
        self = Self(rawValue: rawValue)
    }

}

// MARK: - Writable Array

extension Array: Writable where Element: Writable {

    public func write(to output: Output) throws {
        try forEach(output.write)
    }

}

// MARK: - Streamable String

extension String: Streamable {

    public init?(bytes: Bytes, encoding: String.Encoding = .utf8) {
        let data = Data(bytes.rawValue)
        self.init(data: data, encoding: encoding)
    }

    public func bytes(using encoding: String.Encoding = .utf8) -> Bytes? {
        data(using: encoding)?.bytes
    }

}

// MARK: - Streamable Data

extension Data: Streamable {

    public init(from input: Input) throws {
        let bytes = try input.read() as Bytes
        self = Data(bytes.rawValue)
    }

    public func write(to output: Output) throws {
        let bytes = Bytes(data: self)
        try output.write(bytes)
    }

}

// MARK: - Streamable UUID

extension UUID: Streamable { }

// MARK: - Streamable Bytes

extension Bytes: Streamable {

    public init(from input: Input) throws {
        self = try input.read(lenght: input.remaining.count)
    }

    public func write(to output: Output) throws {
        try output.write(self)
    }

}

