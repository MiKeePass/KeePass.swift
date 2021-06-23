/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2020
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

import XCTest
@testable import XML

class XMLTests: XCTestCase {

    // MARK: - Properties

    var exampleDocument = Document()
    var plantsDocument = Document()

    // MARK: - Helpers

    func URLForResource(fileName: String, withExtension ext: String) -> URL {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: ext) else {
            fatalError("can't find resource named: '\(fileName)'")
        }
        return url
    }

    func xmlDocumentFromURL(url: URL) -> Document {
        var xmlDocument = Document()

        do {
            let data = try Data(contentsOf: url)
            xmlDocument = try Document(xml: data)
        } catch {
            print(error)
        }

        return xmlDocument
    }

    func readXMLFromFile(filename: String) -> Document {
        let url = URLForResource(fileName: filename, withExtension: "xml")
        return xmlDocumentFromURL(url: url)
    }

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        // create some sample xml documents
        exampleDocument = readXMLFromFile(filename: "example")
        plantsDocument = readXMLFromFile(filename: "plant_catalog")
    }

    override func tearDown() {
        // reset sample xml document
        exampleDocument = Document()
        plantsDocument = Document()

        super.tearDown()
    }

    // MARK: - XML Document

    func testXMLDocumentManualDataLoading() {
        do {
            let url = URLForResource(fileName: "example", withExtension: "xml")
            let data = try Data(contentsOf: url)

            let testDocument = Document()
            try testDocument.load(data)
            XCTAssertEqual(testDocument.root.name, "animals", "Should be able to find root element.")
        } catch {
            XCTFail("Should be able to load XML Document with given Data.")
        }
    }

    func testXMLDocumentInitFromString() {
        do {
            let testDocument = try Document(xml: exampleDocument.xml)
            XCTAssertEqual(testDocument.xml, exampleDocument.xml)
        } catch {
            XCTFail("Should be able to initialize XML Document from XML String.")
        }
    }

    func testXMLOptions() {
        do {
            var options = Options()
            options.documentHeader.version = 2.0
            options.documentHeader.encoding = "utf-16"
            options.documentHeader.standalone = "yes"

            let testDocument = try Document(xml: "<foo><bar>hello</bar></foo>", options: options)
            XCTAssertEqual(
                testDocument.xml,
                "<?xml version=\"2.0\" encoding=\"utf-16\" standalone=\"yes\"?>\n<foo>\n\t<bar>hello</bar>\n</foo>"
            )
            XCTAssertEqual(try testDocument.root.bar.first?.get(), "hello")
        } catch {
            XCTFail("Should be able to initialize XML Document with custom Options.")
        }
    }

    func testXMLParser() {
        do {
            let testDocument = Document()
            let url = URLForResource(fileName: "example", withExtension: "xml")
            let data = try Data(contentsOf: url)

            let parser = Parser(document: testDocument, data: data)
            try parser.parse()

            XCTAssertEqual(testDocument.root.name, "animals", "Should be able to find root element.")
        } catch {
            XCTFail("Should be able to parse XML Data into XML Document without throwing error.")
        }
    }

    func testXMLParserTrimsWhitespace() {
        let result = whitespaceResult(shouldTrimWhitespace: true)
        XCTAssertEqual(result, "Hello,")
    }

    func testXMLParserWithoutTrimmingWhitespace() {
        let result = whitespaceResult(shouldTrimWhitespace: false)
        XCTAssertEqual(result, "Hello, ")
    }

    private func whitespaceResult(shouldTrimWhitespace: Bool) -> String? {
        do {
            var options = Options()
            options.parserSettings.shouldTrimWhitespace = shouldTrimWhitespace

            let testDocument = Document(options: options)
            let url = URLForResource(fileName: "whitespace_examples", withExtension: "xml")
            let data = try Data(contentsOf: url)

            let parser = Parser(document: testDocument, data: data)
            try parser.parse()

            return testDocument.root.text.first?.value
        } catch {
            XCTFail("Should be able to parse XML without throwing an error")
        }
        return nil
    }

    func testXMLParserError() {
        do {
            let testDocument = Document()
            let testData = Data()
            let parser = Parser(document: testDocument, data: testData)
            try parser.parse()
        } catch {
            XCTAssertEqual(error.localizedDescription, XMLError.parsingFailed.localizedDescription)
        }
    }

    // MARK: - XML Read

    func testRootElement() {
        XCTAssertEqual(exampleDocument.root.name, "animals", "Should be able to find root element.")

        let documentWithoutRootElement = Document()
        let rootElement = documentWithoutRootElement.root
        XCTAssertEqual(rootElement.error, XMLError.rootElementMissing, "Should have RootElementMissing error.")
    }

    func testParentElement() {
        XCTAssertEqual(exampleDocument.root.cats.parent?.name, "animals", "Should be able to find parent element.")
    }

    func testChildrenElements() {
        var count = 0
        for _ in exampleDocument.root.cats.children {
            count += 1
        }
        XCTAssertEqual(count, 4, "Should be able to iterate children elements")
    }

    func testName() {
        let secondChildElementName = exampleDocument.root.children[1].name
        XCTAssertEqual(secondChildElementName, "dogs", "Should be able to return element name.")
    }

    func testAttributes() {
        let firstCatAttributes = exampleDocument.root.cats.cat.attributes
        XCTAssertEqual(firstCatAttributes["breed"], "Siberian", "Should be able to return attribute value.")
    }

    func testValue() {
        let firstPlant = plantsDocument.root.PLANT
        XCTAssertEqual(firstPlant.COMMON, "Bloodroot", "Should be able to return element value as optional string.")
        XCTAssertNil(firstPlant.ELEMENTWITHOUTVALUE.value, "Should be able to have nil value.")
        XCTAssertNil(firstPlant.EMPTYELEMENT.value, "Should be able to have nil value.")
    }

    func testStringValue() {
        let firstPlant = plantsDocument.root.PLANT
        XCTAssertEqual(firstPlant.COMMON.value, "Bloodroot", "Should be able to return element value as string.")
        XCTAssertNil(firstPlant.ELEMENTWITHOUTVALUE.value, "Should be able to return nil if element has no value.")
        XCTAssertNil(firstPlant.EMPTYELEMENT.value, "Should be able to return nil if element has no value.")
    }

    func testBoolValue() {
        XCTAssertEqual(plantsDocument.root.PLANT.TRUESTRING, true, "Should be able to cast element value as Bool.")
        XCTAssertEqual(plantsDocument.root.PLANT.FALSESTRING, false, "Should be able to cast element value as Bool.")
//        XCTAssertEqual(plantsDocument.root.PLANT.TRUESTRING2, true, "Should be able to cast element value as Bool.")
//        XCTAssertEqual(plantsDocument.root.PLANT.FALSESTRING2, false, "Should be able to cast element value as Bool.")
//        XCTAssertEqual(plantsDocument.root.PLANT.TRUEINT, true, "Should be able to cast element value as Bool.")
//        XCTAssertEqual(plantsDocument.root.PLANT.FALSEINT, false, "Should be able to cast element value as Bool.")
        XCTAssertNil(
            plantsDocument.root.ELEMENTWITHOUTVALUE as Bool?,
            "Should be able to return nil if value can't be represented as Bool."
        )
    }

    func testIntValue() throws {
        XCTAssertEqual(plantsDocument.root.PLANT.ZONE, 4, "Should be able to cast element value as Integer.")
        XCTAssertNil(
            plantsDocument.root.PLANT.ELEMENTWITHOUTVALUE as Int?,
            "Should be able to return nil if value can't be represented as Integer."
        )
    }

    func testDoubleValue() throws {
        XCTAssertEqual(plantsDocument.root.PLANT.PRICE, 2.44, "Should be able to cast element value as Double.")
        XCTAssertNil(
            plantsDocument.root.PLANT.ELEMENTWITHOUTVALUE as Double?,
            "Should be able to return nil if value can't be represented as Double."
        )
    }

    func testNotExistingElement() throws {
        // non-optional
        XCTAssertNotNil(
            exampleDocument.root.ducks.duck.error,
            "Should contain error inside element which does not exist."
        )
        XCTAssertEqual(
            exampleDocument.root.ducks.duck.error,
            XMLError.elementNotFound,
            "Should have ElementNotFound error."
        )
        XCTAssertNil(exampleDocument.root.ducks.duck.value, "Should have empty value.")
        XCTAssertNil(exampleDocument.root.ducks.duck.first, "Should not be able to find ducks here.")
    }

    func testAllElements() {
        var count = 0
        if let cats = exampleDocument.root.cats.cat.all {
            for cat in cats {
                XCTAssertNotNil(cat.parent, "Each child element should have its parent element.")
                count += 1
            }
        }
        XCTAssertEqual(count, 4, "Should be able to iterate all elements")
    }

    func testFirstElement() throws {
        let catElement = exampleDocument.root.cats.cat
        let firstCatExpectedValue = "Tinna"

        // non-optional
        XCTAssertEqual(
            try catElement.get(),
            firstCatExpectedValue,
            "Should be able to find the first element as non-optional."
        )

        // optional
        if let cat = catElement.first {
            XCTAssertEqual(
                try cat.get(),
                firstCatExpectedValue,
                "Should be able to find the first element as optional."
            )
        } else {
            XCTFail("Should be able to find the first element.")
        }
    }

    func testLastElement() throws {
        if let dog = exampleDocument.root.dogs.dog.last {
            XCTAssertEqual(try dog.get(), "Kika", "Should be able to find the last element.")
        } else {
            XCTFail("Should be able to find the last element.")
        }
    }

    func testCountElements() {
        let dogsCount = exampleDocument.root.dogs.dog.count
        XCTAssertEqual(dogsCount, 4, "Should be able to count elements.")
    }

    func testAllWithValue() {
        let cats = exampleDocument.root.cats
        cats.addChild(name: "cat", value: "Tinna")

        var count = 0
        if let tinnas = cats["cat"].all(withValue: "Tinna") {
            for _ in tinnas {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given value.")
    }

    func testAllWithAttributes() {
        var count = 0
        if let bulls = exampleDocument.root.dogs.dog.all(withAttributes: ["color": "white"]) {
            for _ in bulls {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given attributes.")
    }

    func testAllContainingAttributes() {
        var count = 0
        if let bulls = exampleDocument.root.dogs.dog.all(containingAttributeKeys: ["gender"]) {
            for _ in bulls {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given attribute keys.")
    }

    func testAllDescendantsWherePredicate() {
        let children = exampleDocument.allDescendants { $0.attributes["color"] == "yellow" }

        XCTAssertEqual(children.count, 2, "Should be able to return elements matching predicate.")
    }

    func testFirstDescendantWherePredicate() {
        let descendant = plantsDocument.root
            .firstDescendant { $0.hasDescendant { $0.name == "LIGHT" && $0.value == "Sunny" } }
        let plantName = descendant?["COMMON"].value

        XCTAssertEqual(plantName, "Black-Eyed Susan", "Should be able to find first child satisfying predicate.")
    }

    func testHasDescendantWherePredicate() throws {
        let hasDescendant = plantsDocument.hasDescendant { $0.name == "AVAILABILITY" && $0.value == "030699" }
        XCTAssert(hasDescendant, "Should be able to determine that document has a child satisfying predicate.")
    }

    func testSpecialCharacterTrimRead() {
        let expected =
            "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<elements>\n\t<string name=\"this_and_that\">This &amp; that</string>\n</elements>"

        let readerDocument = try! Document(xml: expected)
        let readerXml = readerDocument.xml
        XCTAssertEqual(readerXml, expected, "Should be able to print XML formatted string.")
    }

    // MARK: - XML Write

    func testAddChild() throws {
        let ducks = exampleDocument.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", value: "Donald")
        ducks.addChild(name: "duck", value: "Daisy")
        ducks.addChild(name: "duck", value: "Scrooge")

        let animalsCount = exampleDocument.root.children.count
        XCTAssertEqual(animalsCount, 3, "Should be able to add child elements to an element.")
        XCTAssertEqual(
            try exampleDocument.root["ducks"]["duck"].last?.get(),
            "Scrooge",
            "Should be able to iterate ducks now."
        )
    }

    func testAddChildWithAttributes() throws {
        let cats = exampleDocument.root.cats
        let dogs = exampleDocument.root.dogs

        cats.addChild(name: "cat", value: "Garfield", attributes: ["breed": "tabby", "color": "orange"])
        dogs.addChild(name: "dog", value: "Snoopy", attributes: ["breed": "beagle", "color": "white"])

        let catsCount = cats["cat"].count
        let dogsCount = dogs["dog"].count

        let lastCat = cats["cat"].last!
        let penultDog = dogs.children[3]

        XCTAssertEqual(catsCount, 5, "Should be able to add child element with attributes to an element.")
        XCTAssertEqual(dogsCount, 5, "Should be able to add child element with attributes to an element.")

        XCTAssertEqual(
            lastCat.attributes["color"],
            "orange",
            "Should be able to get attribute value from added element."
        )
        XCTAssertEqual(
            try penultDog.get(),
            "Kika",
            "Should be able to add child with attributes without overwrites existing elements. (Github Issue #28)"
        )
    }

    func testAddChildren() {
        let animals: [Element] = [
            Element(name: "dinosaurs"),
            Element(name: "birds"),
            Element(name: "bugs"),
        ]
        exampleDocument.root.addChildren(animals)

        let animalsCount = exampleDocument.root.children.count
        XCTAssertEqual(animalsCount, 5, "Should be able to add children elements to an element.")
    }

    func testAddAttributes() {
        let firstCat = exampleDocument.root.cats.cat

        firstCat.attributes["funny"] = "true"
        firstCat.attributes["speed"] = "fast"
        firstCat.attributes["years"] = "7"

        XCTAssertEqual(firstCat.attributes.count, 5, "Should be able to add attributes to an element.")
        XCTAssertEqual(Int(firstCat.attributes["years"]!), 7, "Should be able to get any attribute value now.")
    }

    func testRemoveChild() throws {
        let cats = exampleDocument.root.cats
        let lastCat = cats["cat"].last!
        let duplicateCat = cats.addChild(
            name: "cat",
            value: "Tinna",
            attributes: ["breed": "Siberian", "color": "lightgray"]
        )

        lastCat.removeFromParent()
        duplicateCat.removeFromParent()

        let catsCount = cats["cat"].count
        let firstCat = cats["cat"]
        XCTAssertEqual(catsCount, 3, "Should be able to remove element from parent.")
        XCTAssertEqual(try firstCat.get(), "Tinna", "Should be able to remove the exact element from parent.")
    }

    func testXMLEscapedString() {
        let string = "&<>'\""
        let escapedString = string.xmlEscaped
        XCTAssertEqual(escapedString, "&amp;&lt;&gt;&apos;&quot;")
    }

    func testXMLString() {
        let testDocument = Document()
        let children = testDocument.addChild(name: "children")
        children.addChild(name: "child", value: "value", attributes: ["attribute": "attributeValue<&>"])
        children.addChild(name: "child")
        children.addChild(name: "child", value: "&<>'\"")

        XCTAssertEqual(
            testDocument.xml,
            "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n\t<child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n\t<child />\n\t<child>&amp;&lt;&gt;&apos;&quot;</child>\n</children>",
            "Should be able to print XML formatted string."
        )

        XCTAssertEqual(
            testDocument.xmlCompact,
            "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><children><child attribute=\"attributeValue&lt;&amp;&gt;\">value</child><child /><child>&amp;&lt;&gt;&apos;&quot;</child></children>",
            "Should be able to print compact XML string."
        )

        XCTAssertEqual(
            testDocument.xmlSpaces,
            "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n    <child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n    <child />\n    <child>&amp;&lt;&gt;&apos;&quot;</child>\n</children>",
            "Should be able to print XML formatted string."
        )
    }

    // MARK: - XML Parse Performance

    func testReadXMLPerformance() {
        self.measure {
            _ = self.readXMLFromFile(filename: "plant_catalog")
        }
    }

    func testWriteXMLPerformance() {
        self.measure {
            _ = self.plantsDocument.xml
        }
    }
}
