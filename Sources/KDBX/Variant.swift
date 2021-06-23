// Variant.swift
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

public enum Variant {

    struct Version {
        let major: UInt8
        let minor: UInt8
    }

    case End
    case Bool(Bool)
    case UInt32(UInt32)
    case UInt64(UInt64)
    case Int32(Int32)
    case Int64(Int64)
    case String(String)
    case Bytes(Bytes)

    enum ID: UInt8, Streamable {
        case End = 0x00
        case Bool = 0x08
        case UInt32 = 0x04
        case UInt64 = 0x05
        case Int32 = 0x0C
        case Int64 = 0x0D
        case String = 0x18
        case Bytes = 0x42
    }

    var id: ID {
        switch self {
        case .End:
            return .End
        case .Bool:
            return .Bool
        case .UInt32:
            return .UInt32
        case .UInt64:
            return .UInt64
        case .Int32:
            return .Int32
        case .Int64:
            return .Int64
        case .String:
            return .String
        case .Bytes:
            return .Bytes
        }
    }

    init() {
        self = .End
    }

    init(_ value: Bool) {
        self = .Bool(value)
    }

    init(_ value: UInt32) {
        self = .UInt32(value)
    }

    init(_ value: UInt64) {
        self = .UInt64(value)
    }

    init(_ value: Int32) {
        self = .Int32(value)
    }

    init(_ value: Int64) {
        self = .Int64(value)
    }

    init(_ value: String) {
        self = .String(value)
    }

    init(_ value: Bytes) {
        self = .Bytes(value)
    }

    func unwrap() throws -> Bool {
        guard case let .Bool(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> UInt32 {
        guard case let .UInt32(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> UInt64 {
        guard case let .UInt64(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> Int32 {
        guard case let .Int32(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> Int64 {
        guard case let .Int64(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> String {
        guard case let .String(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap() throws -> Bytes {
        guard case let .Bytes(value) = self else { throw KDBXError.invalidValue }
        return value
    }

    func unwrap<T>() throws -> T where T: BytesRepresentable {
        guard case let .Bytes(bytes) = self else { throw KDBXError.invalidValue }
        return try T(bytes)
    }
}

extension Variant: Writable {

    init(id: ID, from input: Input) throws {
        let lenght: UInt32 = try input.read()

        switch id {
        case .Bool:
            guard lenght == MemoryLayout<Bool>.size else { throw KDBXError.invalidValue }
            self = .Bool(try input.read())

        case .UInt32:
            guard lenght == MemoryLayout<UInt32>.size else { throw KDBXError.invalidValue }
            self = .UInt32(try input.read())

        case .UInt64:
            guard lenght == MemoryLayout<UInt64>.size else { throw KDBXError.invalidValue }
            self = .UInt64(try input.read())

        case .Int32:
            guard lenght == MemoryLayout<Int32>.size else { throw KDBXError.invalidValue }
            self = .Int32(try input.read())

        case .Int64:
            guard lenght == MemoryLayout<Int64>.size else { throw KDBXError.invalidValue }
            self = .Int64(try input.read())

        case .String:
            self = .String(try input.read(lenght: Int(lenght)))

        case .Bytes:
            self = .Bytes(try input.read(lenght: Int(lenght)))

        default:
            throw KDBXError.invalidValue
        }
    }

    public func write(to output: Output) throws {
        switch self {

        case .End:
            try output.write(id)

        case let .Bool(value):
            try output.write(MemoryLayout<Bool>.size)
            try output.write(value)

        case let .UInt32(value):
            try output.write(MemoryLayout<UInt32>.size)
            try output.write(value)

        case let .UInt64(value):
            try output.write(MemoryLayout<UInt64>.size)
            try output.write(value)

        case let .Int32(value):
            try output.write(MemoryLayout<Int32>.size)
            try output.write(value)

        case let .Int64(value):
            try output.write(MemoryLayout<Int64>.size)
            try output.write(value)

        case let .String(value):
            try output.write(Swift.UInt32(value.count))
            try output.write(value)

        case let .Bytes(value):
            try output.write(Swift.UInt32(value.lenght))
            try output.write(value)
        }
    }
}

extension Variant.Version: Streamable {

    init(from input: Input) throws {
        minor = try input.read()
        major = try input.read()
    }

    func write(to output: Output) throws {
        try output.write(minor)
        try output.write(major)
    }
}

extension Dictionary: Streamable where Key == String, Value == Variant {

    public init(from input: Input) throws {
        self.init()

        let version: Variant.Version = try input.read()
        guard version.major > 0 else { throw KDBXError.invalidValue }

        while true {
            let id: Variant.ID = try input.read()

            if id == .End { break }

            let lenght: UInt32 = try input.read()
            let key: String = try input.read(lenght: Int(lenght))
            let value = try Variant(id: id, from: input)

            self[key] = value
        }
    }

    public func write(to output: Output) throws {
        let version = Variant.Version(major: 1, minor: 0)
        try output.write(version)

        try forEach {
            try output.write($0.value.id)
            try output.write(UInt32($0.key.count))
            try output.write($0.key)
            try output.write($0.value)
        }

        try output.write(Variant.End)
    }
}

extension Dictionary: BytesRepresentable where Key == String, Value == Variant {

    public init(_ bytes: Bytes) throws {
        let input = Input(bytes: bytes)
        try self.init(from: input)
    }

    public var bytes: Bytes {
        let output = Output()
        try? output.write(self)
        return output.bytes ?? []
    }
}
