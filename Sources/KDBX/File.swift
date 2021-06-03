// File.swift
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

public let FileSignature: UInt32 = 0x9AA2D903

public let BetaFileFormat: UInt32 = 0xB54BFB66

public let FileFormat: UInt32 = 0xB54BFB67

public struct Version {
    let major: UInt16
    let minor: UInt16
}

public class File {

    public let version: Version

    public let database: Database

    public required init(from input: Input) throws {
        version = Version(major: 0, minor: 0)
        database = try Database0(from: input)
    }

    public required init(from input: Input, compositeKey: CompositeKey) throws {
        version = try input.read()

        if version.major > 3 {
            database = try Database4(from: input, compositeKey: compositeKey)
        } else {
            database = try Database3(from: input, compositeKey: compositeKey)
        }
    }

    public convenience init(xml file: URL) throws {
        let bytes = try Bytes(contentsOf: file)
        let stream = Input(bytes: bytes)
        try self.init(from: stream)
    }

    public convenience init(from file: URL, compositeKey: CompositeKey) throws {

        let bytes = try Bytes(contentsOf: file)
        let stream = Input(bytes: bytes)

        guard try stream.read() == FileSignature else { throw KDBXError.invalidFileFormat }

        let format: UInt32 = try stream.read()
        guard
            format == BetaFileFormat ||
            format == FileFormat
        else { throw KDBXError.invalidFileFormat }

        try self.init(from: stream, compositeKey: compositeKey)
    }

    public func write(to output: Output, compositeKey: CompositeKey) throws {
        try output.write(FileSignature)
        try output.write(BetaFileFormat)
        try output.write(version)
    }

}

extension Version: Streamable {

    public init(from input: Input) throws {
        minor = try input.read()
        major = try input.read()
    }

    public func write(to output: Output) throws {
        try output.write(minor)
        try output.write(major)
    }

}
