// Entry.swift
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

import Binary
import Foundation

public final class Entry: Row, Streamable {

    public typealias Property = TLV<Column, UInt32>

    public enum Column: UInt16, Streamable, Endable {
        case reserved = 0x0000
        case uuid = 0x0001
        case groupID = 0x0002
        case iconID = 0x0003
        case title = 0x0004
        case url = 0x0005
        case username = 0x0006
        case password = 0x0007
        case notes = 0x0008
        case creationTime = 0x0009
        case lastModifiedTime = 0x000A
        case lastAccessTime = 0x000B
        case expirationTime = 0x000C
        case binaryDesc = 0x000D
        case binaryData = 0x000E
        case end = 0xFFFF

        public static var endValue: Self { .end }
    }

    public internal(set) weak var parent: Group?

    public var properties: [Property]

    public init() {
        properties = []
    }

    public init(from input: Input) throws {
        properties = try input.read()
    }
}

extension Entry {

    public func removeFromParent() {
        parent?.entries.removeAll(where: { $0 == self })
        self[.groupID] = -1
        parent = nil
    }
}

extension Entry: Hashable {

    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs[.uuid] == rhs[.uuid]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[.uuid])
    }
}
