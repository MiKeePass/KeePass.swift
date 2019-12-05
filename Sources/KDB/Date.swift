// Date.swift
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

extension Database {

    public static let distantFuture: Date = {
        DateComponents(calendar: Calendar(identifier: .iso8601),
                       year: 2999,
                       month: 12,
                       day: 28,
                       hour: 23,
                       minute: 59,
                       second: 59,
                       nanosecond: 0).date!
    }()

    public static func date(from bytes: Bytes) -> Date? {
        guard bytes.count > 4 else { return nil }

        let year    = ( Int(bytes[0]) << 6) | (Int(bytes[1]) >> 2)
        let month   = ((Int(bytes[1]) & 0x00000003) << 2) | (Int(bytes[2]) >> 6)
        let day     = ( Int(bytes[2]) >> 1) & 0x0000001F
        let hour    = ((Int(bytes[2]) & 0x00000001) << 4) | (Int(bytes[3]) >> 4)
        let minute  = ((Int(bytes[3]) & 0x0000000F) << 2) | (Int(bytes[4]) >> 6)
        let second  =   Int(bytes[4]) & 0x0000003F

        return DateComponents(calendar: Calendar(identifier: .iso8601),
                              year: year,
                              month: month,
                              day: day,
                              hour: hour,
                              minute: minute,
                              second: second,
                              nanosecond: 0).date

    }

    public static func bytes(from date: Date) -> Bytes {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let year   = components.year!
        let month  = UInt8(components.month!)
        let day    = UInt8(components.day!)
        let hour   = UInt8(components.hour!)
        let minute = UInt8(components.minute!)
        let second = UInt8(components.second!)

        var bytes = Bytes(lenght: 5)
        bytes[0] = UInt8(year >> 6) & 0x3F
        bytes[1] = (UInt8(year & 0x3F) << 2) | ((month >> 2) & 0x03)
        bytes[2] = ((month & 0x03) << 6) | ((day & 0x1F) << 1) | ((hour >> 4) & 0x01)
        bytes[3] = (hour & 0x0F) << 4 | ((minute >> 2) & 0x0F)
        bytes[4] = ((minute & 0x03) << 6) | (second & 0x3F)
        return bytes

    }
}
