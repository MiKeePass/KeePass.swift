// Entry.swift
// This file is part of KeePass.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// KeePass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// KeePass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with KeePass. If not, see <https://www.gnu.org/licenses/>.

import Foundation

public let EntryFieldTitle = "Title"
public let EntryFieldUserName = "UserName"
public let EntryFieldPassword = "Password"
public let EntryFieldURL = "URL"
public let EntryFieldNotes = "Notes"

public let MetaEntryBinaryDescription = "bin-stream"
public let MetaEntryTitle = "Meta-Info"
public let MetaEntryUsername = "SYSTEM"
public let MetaEntryURL = "$"

public let MetaEntryUIState = "Simple UI State"
public let MetaEntryDefaultUsername = "Default User Name"
public let MetaEntrySearchHistoryItem = "Search History Item"
public let MetaEntryCustomKVP = "Custom KVP"
public let MetaEntryDatabaseColor = "Database Color"
public let MetaEntryKeePassXCustomIcon = "KPX_CUSTOM_ICONS_2"
public let MetaEntryKeePassXCustomIcon2 = "KPX_CUSTOM_ICONS_4"
public let MetaEntryKeePassXGroupTreeState = "KPX_GROUP_TREE_STATE"
public let MetaEntryKeePassKitGroupUUIDs = "KeePassKit Group UUIDs"
public let MetaEntryKeePassKitDeletedObjects = "KeePassKit Deleted Objects"
public let MetaEntryKeePassKitDatabaseName = "KeePassKit Database Name"
public let MetaEntryKeePassKitDatabaseDescription = "KeePassKit Database Description"
public let MetaEntryKeePassKitTrash = "KeePassKit Trash"
public let MetaEntryKeePassKitUserTemplates = "KeePassKit User Templates"

public protocol Entry {

    associatedtype Fields: RandomAccessCollection where Fields.Element == Field

    var times: Timestamp { get }

    var fields: Fields { get }

    mutating func set(_ field: Fields.Element)
}

extension Entry {

    subscript(_ field: String) -> Fields.Element? {
        return fields.first(where: { $0.name == field })
    }
}
