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

    let outerHeader: Header<OuterHeader, UInt32>

    let innerHeader: Header<InnerHeader, UInt32>

    let document: Document

    required init(from input: Input, compositeKey: CompositeKey) throws {
        outerHeader = try input.read()

        let masterKey = try outerHeader.masterKey(from: compositeKey)

        // Get outer header bytes to verify the hash
        let header = input.bytes.prefix(input.offset)
        var content = try Unhash(header: header,
                                 data: try input.read(),
                                 key: masterKey)

        let key = SHA256.hash( masterKey )
        let cipher = try outerHeader.cipher(key: key)
        content = try cipher.decrypt(data: content)

        if outerHeader[.compressionFlags] == Compression.gzip {
            content = try content.gunzipped()
        }

        let stream = Input(bytes: content)
        innerHeader = try stream.read()

        var options = XML.Options()
        options.parserSettings.shouldTrimWhitespace = false

        document = try XML.Document(xml: stream.remaining.data, options: options)
    }

    func write(to output: Output, compositeKey: CompositeKey) throws {
        fatalError()
    }
}

private func Unhash(header: Bytes, data: Bytes, key: Bytes) throws -> Bytes {
    let stream = Input(bytes: data)

    let key = SHA512.hash( key + 1 )
    let hmacKey = HmacKey(block: .max, key: key)

    guard
        try stream.read(lenght: SHA256.Lenght) == SHA256.hash( header ),
        try stream.read(lenght: HMACSHA256.Lenght) == HMACSHA256.authenticate(header, key: hmacKey)
    else { throw KDBXError.invalidCompositeKey }

    var index: UInt64 = 0
    var content = Bytes()

    while stream.hasBytesAvailable {

        let hmac = try stream.read(lenght: HMACSHA256.Lenght)
        let size = try CFSwapInt32LittleToHost(stream.read())
        let block = try stream.read(lenght: Int(size))

        let hmacKey = HmacKey(block: index, key: key)
        let hash = HMACSHA256(key: hmacKey)
        hash.update(CFSwapInt64HostToLittle(index).bytes)
        hash.update(CFSwapInt32HostToLittle(size).bytes)
        hash.update(block)

        guard hash.final == hmac else { throw KDBXError.corruptedDatabase }
        content += block
        index += 1
    }

    return content
}

func HmacKey(block index: UInt64, key: Bytes) -> Bytes {
    // Ensure endianess
    let index = CFSwapInt64LittleToHost(index)
    let hash = SHA512()
    hash.update(index.bytes)
    hash.update(key)
    return hash.final
}
