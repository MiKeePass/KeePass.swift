// Group.swift
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

public final class Group: Row, Streamable {

    public enum Column: UInt16, Streamable, Endable {
        case reserved = 0x0000
        case groupID = 0x0001
        case name = 0x0002
        case creationTime = 0x0003
        case lastModifiedTime = 0x0004
        case lastAccessTime = 0x0005
        case expirationTime = 0x0006
        case iconID = 0x0007
        case groupLevel = 0x0008
        case groupFlags = 0x0009
        case end = 0xFFFF

        public static var endValue: Self { .end }
    }

    public internal(set) weak var parent: Group?

    public internal(set) var childs: [Group]

    public internal(set) var entries: [Entry]

    public var properties: [TLV<Column, UInt32>]

    public init() {
        properties = []
        childs = []
        entries = []
    }

    public init(from input: Input) throws {
        properties = try input.read()
        childs = []
        entries = []
    }
}

extension Group {

    public func removeFromParent() {
        parent?.childs.removeAll(where: { $0 == self })
        parent = nil
    }

    public func add(_ entry: Entry) {
        entry.removeFromParent()
        entries.append(entry)
        entry[.groupID] = self[.groupID]
        entry.parent = self
    }

    public func add(_ group: Group) {
        group.removeFromParent()
        childs.append(group)
        group[.groupLevel] = self[.groupLevel] ?? 0 + 1
        group.parent = self
    }
}

extension Group: Hashable {

    public static func == (lhs: Group, rhs: Group) -> Bool {
        lhs[.groupID] == rhs[.groupID] &&
            lhs[.groupLevel] == rhs[.groupLevel]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[.groupID])
        hasher.combine(self[.name])
        hasher.combine(self[.groupLevel])
    }
}
