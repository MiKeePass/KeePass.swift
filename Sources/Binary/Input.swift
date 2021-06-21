// Input.swift
// This file is part of MiKee.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// MiKee is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MiKee is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MiKee. If not, see <https://www.gnu.org/licenses/>.

import Foundation

public class Input {

    public let bytes: Bytes

    public private(set) var offset = 0

    public var remaining: Bytes { bytes.suffix(from: offset) }

    public var hasBytesAvailable: Bool { stream.hasBytesAvailable }

    private let stream: InputStream

    public init(bytes: Bytes) {
        self.bytes = bytes

        let data = Data(bytes.rawValue)
        stream = InputStream(data: data)
        stream.open()
    }

    deinit {
        stream.close()
    }

    public func read(lenght: Int) throws -> Bytes {
        var out = Bytes(lenght: lenght)
        let count = stream.read(&out.rawValue, maxLength: lenght)
        if let error = stream.streamError { throw error }
        offset += count
        return out.prefix(count)
    }

    public func read<T>(lenght: Int) throws -> T where T: BytesRepresentable {
        let bytes = try read(lenght: lenght)
        return try T(bytes)
    }

    public func read<T>() throws -> T where T: Readable {
        return try T(from: self)
    }

    public func read<T>(maxLenght: Int) throws -> [T] where T: Readable {
        var array = [T]()

        var count = 0
        while count < maxLenght {
            array.append(try read() as T)
            count += 1
        }

        return array
    }
}
