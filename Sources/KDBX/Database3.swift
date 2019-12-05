// Database3.swift
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
import Gzip
import XML

class Database3: Database {

    typealias Header = [TLV<OuterHeader, UInt16>]

    let header: Header

    let document: Document

    required init(from input: Input, compositeKey: CompositeKey) throws {
        header = try input.read()

        guard let startBytes = header[.streamStartBytes] else { throw KDBXError.corruptedDatabase }

        let data = try input.read() as Bytes

        var key = try header.masterKey(from: compositeKey)
        key = SHA256.hash( key )

        let cipher = try header.cipher(key: key)

        let hash = try cipher.decrypt(data: data)
        let stream = Input(bytes: hash)

        guard try stream.read(lenght: SHA256.Lenght) == startBytes else { throw KDBXError.invalidCompositeKey }

        var block: UInt32 = 0
        var content = Bytes()

        while true {
            guard try stream.read() == block else { throw KDBXError.corruptedDatabase }
            block += 1

            let hash = try stream.read(lenght: SHA256.Lenght)
            let size: UInt32 = try stream.read()
            guard size > 0 else { break }

            let data = try stream.read(lenght: Int(size))
            guard SHA256.hash( data ) == hash else { throw KDBXError.corruptedDatabase }
            content += data
        }

        if header[.compressionFlags] == Compression.gzip {
            content = try content.gunzipped()
        }

        var options = XML.Options()
        options.parserSettings.shouldTrimWhitespace = false

        document = try XML.Document(xml: content.data, options: options)
    }

}

extension Database3: Writable {

    func write(to output: Output) throws {
        try output.write(header)
        fatalError()
    }
}

extension Database3.Header: Readable {
    
    public init(from input: Input) throws {
        var header = Database3.Header()

        while true {
            let field: TLV<OuterHeader, UInt16> = try input.read()
            header.append(field)
            if field.type == .end { break }
        }

        self = header
    }
    
}

extension Database3.Header: Header {

    subscript(_ type: OuterHeader) -> Bytes? {
        return first(where: { $0.type == type })?.value
    }

}
