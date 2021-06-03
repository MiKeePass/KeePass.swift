// Database.swift
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
import Crypto

public let FileSignature: UInt32 = 0x9AA2D903
public let FileFormat: UInt32 = 0xB54BFB65

public class Database {

    let header: Header

    public let root: Group

    public required init(from input: Input, compositeKey: CompositeKey) throws {
        header = try input.read()

        let data: Bytes = try input.read()
        let key = try header.masterKey(from: compositeKey)

        let cipher: Cipher

        if header.cipher.contains(.aes) {
            cipher = try AESCipher(key: key, iv: header.initialVector)
        } else if header.cipher.contains(.twofish) {
            cipher = try Twofish(key: key, iv: header.initialVector)
        } else {
            throw KDBError.unsupportedCipher
        }

        let content = try cipher.decrypt(data: data)

        guard SHA256.hash(content) == header.contentHash else {
            throw KDBError.invalidKey
        }

        let stream = Input(bytes: content)
        self.root = try Root(from: stream, groups: Int(header.groups), entries: Int(header.entries))
    }

    public convenience init(from file: URL, compositeKey: CompositeKey) throws {
        let bytes = try Bytes(contentsOf: file)
        let stream = Input(bytes: bytes)

        guard
            try stream.read() == FileSignature,
            try stream.read() == FileFormat
        else { throw KDBError.invalidFileFormat }

        try self.init(from: stream, compositeKey: compositeKey)
    }

    public func write(to output: Output, compositeKey: CompositeKey) throws {

        func groups(in group: Group) -> UInt32 {
            let count = UInt32(group.childs.count)
            return group.childs.reduce(count) { $0 + groups(in: $1) }
        }

        func entries(in group: Group) -> UInt32 {
            let count = UInt32(group.entries.count)
            return group.childs.reduce(count) { $0 + entries(in: $1) }
        }

        let key = try header.masterKey(from: compositeKey)
        let cipher: Cipher

        if header.cipher.contains(.aes) {
            cipher = try AESCipher(key: key, iv: header.initialVector)
        } else if header.cipher.contains(.twofish) {
            cipher = try Twofish(key: key, iv: header.initialVector)
        } else {
            throw KDBError.unsupportedCipher
        }

        let content = try Data(from: root)

        var header = header
        header.contentHash = SHA256.hash(content)
        header.groups = groups(in: root)
        header.entries = entries(in: root)
        try output.write(header)

        let data = try cipher.encrypt(data: content)
        try output.write(data)
    }

}

private func Root(from input: Input, groups: Int, entries: Int) throws -> Group {

    let groups: [Group] = try input.read(maxLenght: groups)
    let entries: [Entry] = try input.read(maxLenght: entries)

    let root = Group()

    for (i, group) in groups.enumerated() {

        guard let level1: UInt16 = group[.groupLevel] else { throw KDBError.corruptedDatabase }

        if level1 == 0 {
            root.add(group)
            continue
        }

        for (j, parent) in groups[0..<i].enumerated().reversed() {
            guard let level2: UInt16 = parent[.groupLevel] else { throw KDBError.corruptedDatabase }

            if level2 < level1 {
                guard (level1 - level2) == 1 else { throw KDBError.corruptedDatabase }
                parent.add(group)
                break
            }

            guard j > 0 else { throw KDBError.corruptedDatabase }
        }

    }

    for entry in entries {
        guard let groupID: UInt32 = entry[.groupID] else { throw KDBError.corruptedDatabase }
        let group = try groups.first(column: .groupID, where: { $0 == groupID }) ?? root
        group.add(entry)
    }

    return root
}

private func Data(from root: Group) throws -> Bytes {
    fatalError()
}
