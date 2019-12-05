/**
 *  https://github.com/tadija/AEXML
 *  Copyright (c) Marko Tadić 2014-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Simple wrapper around `Foundation.XMLParser`.
internal class Parser: NSObject, XMLParserDelegate {
    
    // MARK: - Properties
    
    let document: Document
    let data: Data
    
    var currentParent: Element?
    var currentElement: Element?
    var currentValue = String()
    
    var parseError: Error?

    private lazy var parserSettings: Options.ParserSettings = {
        return document.options.parserSettings
    }()
    
    // MARK: - Lifecycle
    
    init(document: Document, data: Data) {
        self.document = document
        self.data = data
        currentParent = document
        
        super.init()
    }
    
    // MARK: - API
    
    func parse() throws {
        let parser = Foundation.XMLParser(data: data)
        parser.delegate = self

        parser.shouldProcessNamespaces = parserSettings.shouldProcessNamespaces
        parser.shouldReportNamespacePrefixes = parserSettings.shouldReportNamespacePrefixes
        parser.shouldResolveExternalEntities = parserSettings.shouldResolveExternalEntities
        
        let success = parser.parse()
        
        if !success {
            guard let error = parseError else { throw XMLError.parsingFailed }
            throw error
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String]) {
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        currentValue.append(string)
        currentElement?.value = currentValue.isEmpty ? nil : currentValue
    }
    
    func parser(_ parser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if parserSettings.shouldTrimWhitespace {
            currentElement?.value = currentElement?.value?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    func parser(_ parser: Foundation.XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
}
