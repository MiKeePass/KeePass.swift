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

    public private(set) var root: Group!

    public required init(from input: Input, compositeKey: CompositeKey) throws {
        header = try input.read()

        let data = try input.read() as Bytes
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
        self.root = try tree(from: stream)
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

}

extension Database: Writable {

    public func write(to output: Output) throws {
        try output.write(header)
        fatalError()
    }

}

extension Database {

    private func tree(from input: Input) throws -> Group {

        let groups: [Group] = try input.read(maxLenght: Int(header.groups))
        let entries: [Entry] = try input.read(maxLenght: Int(header.entries))

        let root = Group()

        for (i, group) in groups.enumerated() {

            guard let level1: UInt16 = group[.groupLevel] else { throw KDBError.corruptedDatabase }

            if level1 == 0 {
                root.childs.append(group)
                continue
            }

            for (j, parent) in groups[0..<i].enumerated().reversed() {
                guard let level2: UInt16 = parent[.groupLevel] else { throw KDBError.corruptedDatabase }

                if level2 < level1 {
                    guard (level1 - level2) == 1 else { throw KDBError.corruptedDatabase }
                    parent.childs.append(group)
                    break
                }

                guard j > 0 else { throw KDBError.corruptedDatabase }
            }

        }

        for entry in entries {
            guard let groupID: UInt32 = entry[.groupID] else { throw KDBError.corruptedDatabase }

            let group = try groups.first(where: .groupID, { $0 == groupID }) ?? root
            group.entries.append(entry)
        }

        return root
    }

}
