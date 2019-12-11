// Group.swift
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

public final class Group: Row, Streamable {

    public static let End = Type.end

    public enum `Type`: UInt16, Streamable {
        case reserved           = 0x0000
        case groupID            = 0x0001
        case name               = 0x0002
        case creationTime       = 0x0003
        case lastModifiedTime   = 0x0004
        case lastAccessTime     = 0x0005
        case expirationTime     = 0x0006
        case iconID             = 0x0007
        case groupLevel         = 0x0008
        case groupFlags         = 0x0009
        case end                = 0xFFFF
    }

    var parent: Group?

    public var fields: [Field<Type>]

    public var childs: [Group]

    public var entries: [Entry]

    public required init() {
        fields = []
        childs = []
        entries = []
    }
}

extension Group {

    public func removeFromParent() {
        parent?.childs.removeAll(where: { $0 == self })
    }

    public func add(_ entry: Entry) {
        entry.removeFromParent()
        entries.append(entry)
        entry[.groupID] = self[.groupID]
    }

    public func add(_ group: Group) {
        group.removeFromParent()
        childs.append(group)
    }
}

extension Group: Hashable {

    public static func == (lhs: Group, rhs: Group) -> Bool {
        guard let lhs = lhs[.groupLevel], let rhs = rhs[.groupLevel] else { return false }
        return lhs == rhs
    }

    public func hash(into hasher: inout Hasher) {
        if let groupLevel = self[.groupLevel] { hasher.combine(groupLevel) }
        if let groupFlags = self[.groupFlags] { hasher.combine(groupFlags) }
    }

}
