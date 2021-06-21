/**
 *  https://github.com/tadija/AEXML
 *  Copyright (c) Marko Tadić 2014-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/**
 This class is inherited from `Element` and has a few addons to represent ** Document**.

 XML Parsing is also done with this object.
 */
open class Document: Element {

    // MARK: - Properties

    /// Root (the first child element) element of XML Document **(Empty element with error if not exists)**.
    open var root: Element {
        guard let rootElement = children.first else {
            let errorElement = Element(name: "Error")
            errorElement.error = XMLError.rootElementMissing
            return errorElement
        }
        return rootElement
    }

    public let options: Options

    // MARK: - Lifecycle

    /**
         Designated initializer - Creates and returns new XML Document object.

         - parameter root: Root XML element for XML Document (defaults to `nil`).
         - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).

         - returns: Initialized XML Document object.
     */
    public init(root: Element? = nil, options: Options = Options()) {
        self.options = options

        let documentName = String(describing: Document.self)
        super.init(name: documentName)

        // document has no parent element
        parent = nil

        // add root element to document (if any)
        if let rootElement = root {
            addChild(rootElement)
        }
    }

    /**
         Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).

         - parameter xmlData: XML data to parse.
         - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).

         - returns: Initialized XML Document object containing parsed data. Throws error if data could not be parsed.
     */
    public convenience init(xml: Data, options: Options = Options()) throws {
        self.init(options: options)
        try load(xml)
    }

    /**
         Convenience initializer - used for parsing XML string (by calling `init(xmlData:options:)` internally).

         - parameter xmlString: XML string to parse.
         - parameter encoding: String encoding for creating `Data` from `xmlString` (defaults to `String.Encoding.utf8`)
         - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).

         - returns: Initialized XML Document object containing parsed data. Throws error if data could not be parsed.
     */
    public convenience init(xml: String,
                            encoding: String.Encoding = String.Encoding.utf8,
                            options: Options = Options()) throws {
        guard let data = xml.data(using: encoding) else { throw XMLError.parsingFailed }
        try self.init(xml: data, options: options)
    }

    // MARK: - Parse XML

    /**
         Creates instance of `Parser` (private class which is simple wrapper around `Parser`)
         and starts parsing the given XML data. Throws error if data could not be parsed.

         - parameter data: XML which should be parsed.
     */
    open func load(_ data: Data) throws {
        children.removeAll(keepingCapacity: false)
        let xmlParser = Parser(document: self, data: data)
        try xmlParser.parse()
    }

    // MARK: - Override

    /// Override of `xml` property of `Element` - it just inserts XML Document header at the beginning.
    override open var xml: String {
        var xml = "\(options.documentHeader.xmlString)\n"
        xml += root.xml
        return xml
    }
}
