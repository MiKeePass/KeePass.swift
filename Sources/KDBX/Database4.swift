// Database4.swift
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
import XML

class Database4: Database {

    struct Header {
        let fields: [TLV<OuterHeader, UInt32>]
        let data: Bytes
    }

    let header: Header

    let document: Document

    required init(from input: Input, compositeKey: CompositeKey) throws {
        header = try input.read()

        var key = try header.masterKey(from: compositeKey)
        let hmacKey = SHA512.hash( UInt64.max.bytes + SHA512.hash( key + 1 ) )
        key = SHA256.hash( key )

        let data = try input.read() as Bytes
        let stream = Input(bytes: data)

        guard
            try stream.read(lenght: SHA256.Lenght) == SHA256.hash( header.data ),
            try stream.read(lenght: SHA256.Lenght) == HMACSHA256.authenticate(header.data, key: hmacKey)
        else { throw KDBXError.corruptedDatabase }

        let cipher = try header.cipher(key: key)
        let hash = try cipher.decrypt(data: data)

        fatalError()
    }

}

extension Database4: Writable {

    func write(to output: Output) throws {
        try output.write(header)
        fatalError()
    }

}

extension Database4.Header: Streamable {

    init(from input: Input) throws {
        var fields = [TLV<OuterHeader, UInt32>]()

        while true {
            let field: TLV<OuterHeader, UInt32> = try input.read()
            fields.append(field)
            if field.type == .end { break }
        }

        self.fields = fields
        self.data = input.bytes.prefix(input.offset)
    }

    func write(to output: Output) throws {
        try output.write(fields)
    }

}

extension Database4.Header: Header {

    subscript(_ field: OuterHeader) -> Bytes? {
        return fields.first(where: { $0.type == field })?.value
    }
}
