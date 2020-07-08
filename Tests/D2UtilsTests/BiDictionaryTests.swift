import XCTest
@testable import D2Utils

final class BiDictionaryTests: XCTestCase {
    static var allTests = [
        ("testBiDictionary", testBiDictionary)
    ]
    
    func testBiDictionary() throws {
        var bd = BiDictionary<String, Int>()
        XCTAssert(bd.isEmpty)

        bd["a"] = 1
        bd["b"] = 2
        XCTAssert(bd.count == 2)
        XCTAssertEqual(bd.keysToValues, ["a": 1, "b": 2])
        XCTAssertEqual(bd.valuesToKeys, [1: "a", 2: "b"])

        bd["a"] = 3
        XCTAssertEqual(bd.keysToValues, ["a": 3, "b": 2])
        XCTAssertEqual(bd.valuesToKeys, [3: "a", 2: "b"])

        bd[value: 2] = nil
        XCTAssertEqual(bd.keysToValues, ["a": 3])
        XCTAssertEqual(bd.valuesToKeys, [3: "a"])

        let bd2: BiDictionary = ["test": "this"]
        XCTAssertEqual(bd2.keysToValues, ["test": "this"])
        XCTAssertEqual(bd2.valuesToKeys, ["this": "test"])
    }
}
