// Bytes.swift
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

public func lenght<T>(_ bytes: Bytes) -> T where T: BinaryInteger {
    return T(bytes.rawValue.count)
}

public struct Bytes: RawRepresentable {

    public var rawValue: [UInt8]

    public var lenght: Int {
        rawValue.count
    }

    public var data: Data {
        Data(rawValue)
    }

    public var hexa: String {
        rawValue.map { .init(format: "%02x", $0) }.joined()
    }

    public init() {
        rawValue = []
    }

    public init(rawValue: [UInt8]) {
        self.rawValue = [UInt8](rawValue)
    }

    public init(_ buffer: UnsafeRawBufferPointer) {
        rawValue = Array(buffer)
    }

    public init(slice: ArraySlice<UInt8>) {
        self.rawValue = [UInt8](slice)
    }

    public init(lenght: Int) {
        self.init(rawValue: [UInt8](repeating: 0, count: lenght))
    }

    public init(repeating: UInt8, count: Int) {
        self.init(rawValue: [UInt8](repeating: repeating, count: count))
    }

    public init(random lenght: Int) throws {
        self.rawValue = (0..<lenght).map { _ in 
            UInt8.random(in: UInt8.min...UInt8.max)
        }
    }

    public init(data: Data) {
        self.rawValue = data.withUnsafeBytes { Array($0) }
    }

    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data)
    }

    public init?(string: String, using encoding: String.Encoding) {
        guard let data = string.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    public init?(base64Encoded: String) {
        guard let data = Data(base64Encoded: base64Encoded) else { return nil }
        self.init(data: data)
    }

    public init?(hex: String) {
        let utf8 = [UInt8](hex.utf8)
        let offset = hex.hasPrefix("0x") ? 2 : 0
        var array = [UInt8]()

        let start = utf8.startIndex.advanced(by: offset)
        let end = utf8.endIndex
        let step = utf8.startIndex.advanced(by: 2)

        for index in stride(from: start, to: end, by: step) {
            let hex = "\( UnicodeScalar(utf8[index]) )\( UnicodeScalar(utf8[index.advanced(by: 1)]) )"
            guard let byte = UInt8(hex, radix: 16) else { return nil }
            array.append(byte)
        }

        rawValue = array
    }

    public subscript (index: Int) -> UInt8 {
        get { return rawValue[index] }
        set { rawValue[index] = newValue }
    }

    public subscript (range: CountableRange<Int>) -> Bytes {
        return Bytes(slice: rawValue[range])
    }

    public mutating func append(_ byte: UInt8) {
        rawValue.append(byte)
    }

    public mutating func append(_ bytes: Array<UInt8>) {
        rawValue.append(contentsOf: bytes)
    }

    public mutating func append(_ bytes: Bytes) {
        rawValue.append(contentsOf: bytes.rawValue)
    }

    @discardableResult
    public func withBytes<T>(_ body: ([UInt8]) -> T) -> T {
        return body(rawValue)
    }

    @discardableResult
    public mutating func withMutableBytes<T>(_ body: (inout [UInt8]) -> T) -> T {
        return body(&rawValue)
    }

    public func map<T>() -> [T] where T: BinaryInteger {
        return map { T($0) }
    }

    public static func + (lhs: Bytes, rhs: Bytes) -> Bytes {
        return Bytes(rawValue: lhs.rawValue + rhs.rawValue)
    }

    public static func += (lhs: inout Bytes, rhs: Bytes) {
        lhs = Bytes(rawValue: lhs.rawValue + rhs.rawValue)
    }

    public static func + (lhs: Bytes, rhs: UInt8) -> Bytes {
        return Bytes(rawValue: lhs.rawValue + [rhs])
    }

    public static func += (lhs: inout Bytes, rhs: UInt8) {
        lhs.append(rhs)
    }

}

extension Bytes: Sequence {

    /// Returns an iterator over the elements of this sequence.
    public func makeIterator() -> IndexingIterator<[UInt8]> {
        rawValue.makeIterator()
    }

    /// A value less than or equal to the number of elements in the sequence,
    /// calculated nondestructively.
    ///
    /// The default implementation returns 0. If you provide your own
    /// implementation, make sure to compute the value nondestructively.
    ///
    /// - Complexity: O(1), except if the sequence also conforms to `Collection`.
    ///   In this case, see the documentation of `Collection.underestimatedCount`.
    public var underestimatedCount: Int {
        return rawValue.underestimatedCount
    }

    /// Call `body(p)`, where `p` is a pointer to the collection's
    /// contiguous storage.  If no such storage exists, it is
    /// first created.  If the collection does not support an internal
    /// representation in a form of contiguous storage, `body` is not
    /// called and `nil` is returned.
    ///
    /// A `Collection` that provides its own implementation of this method
    /// must also guarantee that an equivalent buffer of its `SubSequence`
    /// can be generated by advancing the pointer by the distance to the
    /// slice's `startIndex`.
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<UInt8>) throws -> R) rethrows -> R? {
        return try rawValue.withContiguousStorageIfAvailable(body)
    }

}

extension Bytes: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: UInt8...) {
        rawValue = elements
    }
}

extension Bytes: ContiguousBytes {

    /// Calls the given closure with the contents of underlying storage.
    ///
    /// - note: Calling `withUnsafeBytes` multiple times does not guarantee that
    ///         the same buffer pointer will be passed in every time.
    /// - warning: The buffer argument to the body should not be stored or used
    ///            outside of the lifetime of the call to the closure.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try rawValue.withUnsafeBytes(body)
    }

    public mutating func withUnsafeMutableBytes<T>(_ body: (UnsafeMutableRawBufferPointer) throws -> T) rethrows -> T {
        return try rawValue.withUnsafeMutableBytes(body)
    }
}

extension Bytes: DataProtocol {

    public var regions: CollectionOfOne<[UInt8]> {
        rawValue.regions
    }

    public var startIndex: Int {
        rawValue.startIndex
    }

    public var endIndex: Int {
        rawValue.endIndex
    }

}

extension Bytes: Hashable {

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

}
