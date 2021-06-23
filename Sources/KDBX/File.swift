// File.swift
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

public let FileSignature: UInt32 = 0x9AA2_D903
public let BetaFileFormat: UInt32 = 0xB54B_FB66
public let FileFormat: UInt32 = 0xB54B_FB67

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
        try output.write(FileFormat)
        try output.write(version)
        try database.write(to: output, compositeKey: compositeKey)
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
