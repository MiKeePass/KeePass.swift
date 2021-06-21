// Output.swift
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

public class Output {

    public var bytes: Bytes? {
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else { return nil }
        return Bytes(data: data)
    }

    public private(set) var lenght = 0

    private let stream: OutputStream

    public init() {
        stream = OutputStream.toMemory()
        stream.open()
    }

    public init?(url: URL, append: Bool = false) {
        guard let stream = OutputStream(url: url, append: append) else { return nil }
        self.stream = stream
        self.stream.open()
    }

    deinit {
        stream.close()
    }

    public func write(_ bytes: Bytes) throws {
        let count = stream.write(bytes.rawValue, maxLength: bytes.lenght)
        if let error = stream.streamError { throw error }
        lenght += count
    }

    public func write<T>(_ value: T) throws where T: Writable {
        try value.write(to: self)
    }
}
