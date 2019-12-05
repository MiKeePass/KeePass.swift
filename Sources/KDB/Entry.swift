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

    public static let End = Field.end

    public enum Field: UInt16, Streamable {
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

    public var fields: [TLV<Field, UInt32>]

    public required init() {
        fields = []
    }
    
}

extension Entry {

    var isMetaEntry: Bool {
        return false
    }
}
