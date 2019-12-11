// TypeErasure.swift
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

@inline(never)
internal func _abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Method must be overridden", file: file, line: line)
}

// MARK: - Database

internal class _AnyDatabaseBoxBase: Database {
    internal var root: AnyGroup { _abstract() }
}

internal final class _AnyDatabaseBox<Base>: _AnyDatabaseBoxBase where Base: Database {
    internal override var root: AnyGroup { AnyGroup( _base.root ) }
    internal var _base: Base
    internal init(_ base: Base) {
        self._base = base
    }
}

public class AnyDatabase: Database {

    public var root: AnyGroup { _box.root }

    internal let _box: _AnyDatabaseBoxBase
    internal init<T>(_ base: T) where T: Database {
        _box = _AnyDatabaseBox(base)
    }
    
}

// MARK: - Group

internal class _AnyGroupBoxBase: Group {

    internal var title: String {
        get { _abstract() }
        set { _abstract() }
    }

    internal var icon: Int {
        get { _abstract() }
        set { _abstract() }
    }

    internal var entries: AnyRandomAccessCollection<AnyEntry> { _abstract() }
    internal var groups: AnyRandomAccessCollection<AnyGroup> { _abstract() }
}

internal final class _AnyGroupBox<Base>: _AnyGroupBoxBase where Base: Group {

    internal override var title: String {
        get { _base.title }
        set { _base.title = newValue }
    }

    internal override var icon: Int {
        get { _base.icon }
        set { _base.icon = newValue }
    }

    internal override var entries: AnyRandomAccessCollection<AnyEntry> { AnyRandomAccessCollection<AnyEntry>(_base.entries.map { AnyEntry($0) }) }
    internal override var groups: AnyRandomAccessCollection<AnyGroup> { AnyRandomAccessCollection<AnyGroup>(_base.groups.map { AnyGroup($0) }) }

    internal var _base: Base
    internal init(_ base: Base) {
        self._base = base
    }
}

public class AnyGroup: Group {

    public var title: String {
        get { _box.title }
        set { _box.title = newValue }
    }

    public var icon: Int {
        get { _box.icon }
        set { _box.icon = newValue }
    }

    public var entries: AnyRandomAccessCollection<AnyEntry> { _box.entries }
    public var groups: AnyRandomAccessCollection<AnyGroup> { _box.groups }

    internal let _box: _AnyGroupBoxBase
    internal init<T>(_ base: T) where T: Group {
        _box = _AnyGroupBox(base)
    }

}

// MARK: - Entry

internal class _AnyEntryBoxBase: Entry {
    internal subscript(position: Int) -> Field { _abstract() }
    internal var startIndex: Int { _abstract() }
    internal var endIndex: Int { _abstract() }
    internal func index(after i: Int) -> Int { _abstract() }
    internal func index(before i: Int) -> Int { _abstract() }
    internal func set(_ field: Field) { _abstract() }
}

internal final class _AnyEntryBox<Base>: _AnyEntryBoxBase where Base: Entry {

    internal override subscript(position: Int) -> Element {
        _base[position]
    }

    internal override var startIndex: Int {
        _base.startIndex
    }

    internal override var endIndex: Int {
        _base.endIndex
    }

    internal override func index(after i: Int) -> Int {
        _base.index(after: i)
    }

    internal override func index(before i: Int) -> Int {
        _base.index(before: i)
    }

    internal override func set(_ field: Element) {
        _base.set(field)
    }

    internal var _base: Base
    internal init(_ base: Base) {
        self._base = base
    }

}

public final class AnyEntry: Entry {

    public subscript(position: Int) -> Field {
        _box[position]
    }

    public var startIndex: Int {
        _box.startIndex
    }

    public var endIndex: Int {
        _box.endIndex
    }

    public func index(after i: Int) -> Int {
        _box.index(after: i)
    }

    public func index(before i: Int) -> Int {
        _box.index(before: i)
    }

    public func set(_ field: Field) {
        _box.set(field)
    }

    internal let _box: _AnyEntryBoxBase
    internal init<T>(_ base: T) where T: Entry {
        _box = _AnyEntryBox(base)
    }

}
