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

import Binary
import Foundation

@inline(never)
func _abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Method must be overridden", file: file, line: line)
}

// MARK: - Database

class _AnyDatabaseBoxBase: Database {
    var root: AnyGroup { _abstract() }
    func write(to output: Output, compositeKey: CompositeKey) throws { _abstract() }
}

final class _AnyDatabaseBox<Base>: _AnyDatabaseBoxBase where Base: Database {
    override var root: AnyGroup { AnyGroup(_base.root) }
    var _base: Base
    init(_ base: Base) { _base = base }
    override func write(to output: Output, compositeKey: CompositeKey) throws {
        try _base.write(to: output, compositeKey: compositeKey)
    }
}

class AnyDatabase: Database {
    var root: AnyGroup { _box.root }
    let _box: _AnyDatabaseBoxBase
    init<T>(_ base: T) where T: Database {
        _box = _AnyDatabaseBox(base)
    }

    func write(to output: Output, compositeKey: CompositeKey) throws {
        try _box.write(to: output, compositeKey: compositeKey)
    }
}

// MARK: - Group

class _AnyGroupBoxBase: Group {

    var title: String {
        get { _abstract() }
        set { _abstract() }
    }

    var icon: Int {
        get { _abstract() }
        set { _abstract() }
    }

    var entries: AnyRandomAccessCollection<AnyEntry> { _abstract() }
    var groups: AnyRandomAccessCollection<AnyGroup> { _abstract() }
}

final class _AnyGroupBox<Base>: _AnyGroupBoxBase where Base: Group {

    override var title: String {
        get { _base.title }
        set { _base.title = newValue }
    }

    override var icon: Int {
        get { _base.icon }
        set { _base.icon = newValue }
    }

    override var entries: AnyRandomAccessCollection<AnyEntry> {
        AnyRandomAccessCollection<AnyEntry>(_base.entries.map { AnyEntry($0) })
    }

    override var groups: AnyRandomAccessCollection<AnyGroup> {
        AnyRandomAccessCollection<AnyGroup>(_base.groups.map { AnyGroup($0) })
    }

    var _base: Base
    init(_ base: Base) { _base = base }
}

class AnyGroup: Group {

    public var title: String {
        get { _box.title }
        set { _box.title = newValue }
    }

    public var icon: Int {
        get { _box.icon }
        set { _box.icon = newValue }
    }

    var entries: AnyRandomAccessCollection<AnyEntry> { _box.entries }
    var groups: AnyRandomAccessCollection<AnyGroup> { _box.groups }

    let _box: _AnyGroupBoxBase
    init<T>(_ base: T) where T: Group {
        _box = _AnyGroupBox(base)
    }
}

// MARK: - Entry

class _AnyEntryBoxBase: Entry {
    var times: Timestamp { _abstract() }
    var fields: AnyRandomAccessCollection<Field> { _abstract() }
    func set(_ field: Field) { _abstract() }
}

final class _AnyEntryBox<Base>: _AnyEntryBoxBase where Base: Entry {
    override var times: Timestamp { _base.times }
    override var fields: AnyRandomAccessCollection<Field> { AnyRandomAccessCollection<Field>(_base.fields) }
    override func set(_ field: Field) { _base.set(field) }
    var _base: Base
    init(_ base: Base) { _base = base }
}

final class AnyEntry: Entry {
    public var times: Timestamp { _box.times }
    public var fields: AnyRandomAccessCollection<Field> { _box.fields }
    public func set(_ field: Field) { _box.set(field) }
    let _box: _AnyEntryBoxBase
    init<T>(_ base: T) where T: Entry {
        _box = _AnyEntryBox(base)
    }
}
