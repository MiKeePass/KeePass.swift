// Group.swift
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

public protocol Group {

    associatedtype Entries: RandomAccessCollection where Entries.Element: Entry

    associatedtype Groups: RandomAccessCollection where Groups.Element: Group

    var title: String { get set }

    var icon: Int { get set }

    var entries: Entries { get }

    var groups: Groups { get }
}
