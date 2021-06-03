// Database0.swift
// This file is part of KeePass.
//
// Copyright © 2019 ___ORGANIZATIONNAME___. All rights reserved.
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

import Foundation
import Binary
import XML

class Database0: Database {

    let document: Document

    required init(from input: Input) throws {
        var options = XML.Options()
        options.parserSettings.shouldTrimWhitespace = false
        document = try XML.Document(xml: input.bytes.data, options: options)
    }

    func write(to output: Output, compositeKey: CompositeKey) throws {
        try output.write(document.xml)
    }
}
