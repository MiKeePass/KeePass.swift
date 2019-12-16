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

import Foundation
import Binary

let MetaEntryBinaryDescription   = "bin-stream"
let MetaEntryTitle               = "Meta-Info"
let MetaEntryUsername            = "SYSTEM"
let MetaEntryURL                 = "$"

let MetaEntryUIState                         = "Simple UI State"
let MetaEntryDefaultUsername                 = "Default User Name"
let MetaEntrySearchHistoryItem               = "Search History Item"
let MetaEntryCustomKVP                       = "Custom KVP"
let MetaEntryDatabaseColor                   = "Database Color"
let MetaEntryKeePassXCustomIcon              = "KPX_CUSTOM_ICONS_2"
let MetaEntryKeePassXCustomIcon2             = "KPX_CUSTOM_ICONS_4"
let MetaEntryKeePassXGroupTreeState          = "KPX_GROUP_TREE_STATE"
let MetaEntryKeePassKitGroupUUIDs            = "KeePassKit Group UUIDs"
let MetaEntryKeePassKitDeletedObjects        = "KeePassKit Deleted Objects"
let MetaEntryKeePassKitDatabaseName          = "KeePassKit Database Name"
let MetaEntryKeePassKitDatabaseDescription   = "KeePassKit Database Description"
let MetaEntryKeePassKitTrash                 = "KeePassKit Trash"
let MetaEntryKeePassKitUserTemplates         = "KeePassKit User Templates"

public final class Entry: Row, Streamable {

    public static let End = Type.end

    public enum `Type`: UInt16, Streamable {
        case reserved           = 0x0000
        case uuid               = 0x0001
        case groupID            = 0x0002
        case iconID             = 0x0003
        case title              = 0x0004
        case url                = 0x0005
        case username           = 0x0006
        case password           = 0x0007
        case notes              = 0x0008
        case creationTime       = 0x0009
        case lastModifiedTime   = 0x000A
        case lastAccessTime     = 0x000B
        case expirationTime     = 0x000C
        case binaryDesc         = 0x000D
        case binaryData         = 0x000E
        case end                = 0xFFFF
    }

    var parent: Group?

    public var properties: [Property<Type>]

    public required init() {
        properties = []
    }    
}

extension Entry {

    public var creationDate: Date {
        date(at: .creationTime) ?? Date.distantPast
    }

    public var lastModifiedDate: Date {
        get { date(at: .lastModifiedTime) ?? Date.distantPast }
        set { set(newValue, at: .lastModifiedTime) }
    }

    public var lastAccessDate: Date {
        get { date(at: .lastAccessTime) ?? Date.distantPast }
        set { set(newValue, at: .lastAccessTime) }
    }

    var isMetaEntry: Bool {
        return false
    }

    public func removeFromParent() {
        parent?.entries.removeAll(where: { $0 == self })
        self[.groupID] = -1
    }
}

extension Entry: Hashable {

    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        guard let lhs = lhs[.uuid], let rhs = rhs[.uuid] else { return false }
        return lhs == rhs
    }

    public func hash(into hasher: inout Hasher) {
        if let uuid = self[.uuid] { hasher.combine(uuid) }
        else if let title = self[.title] { hasher.combine(title) }
    }

}
