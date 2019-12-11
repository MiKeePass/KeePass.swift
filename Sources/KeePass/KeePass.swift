// KeePass.swift
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
import KDB
import KDBX

public let FileSignature: UInt32 = 0x9AA2D903

public enum FileFormat: UInt32, Streamable {
    case kdb        = 0xB54BFB65
    case prekdbx    = 0xB54BFB66
    case kdbx       = 0xB54BFB67
}

public class KeePass {

    public static func open(contentOf url: URL, compositeKey: CompositeKey) throws -> AnyDatabase {

        let bytes = try Bytes(contentsOf: url)
        let stream = Input(bytes: bytes)

        guard try stream.read() == FileSignature else {
            throw KeePassError.invalidFileFormat
        }

        let format = try stream.read() as FileFormat

        switch format {
        case .kdb:
            return AnyDatabase( try KDB.Database(from: stream, compositeKey: compositeKey) )
        case .prekdbx, .kdbx:
            return AnyDatabase ( try KDBX.File(from: stream, compositeKey: compositeKey) )
        }
    }

}
