import XCTest
@testable import D2Script

final class D2ScriptStorageTests: XCTestCase {
	static var allTests = [
		("testStorage", testStorage)
	]
	
	func testStorage() throws {
		let base = D2ScriptStorage(name: "base storage")
		base["A"] = .number(1)
		base["B"] = .number(2)
		
		assertThat(storage: base, contains: "A")
		assertThat(storage: base, contains: "B")
		assertThat(storage: base, notContains: "C")
		XCTAssertEqual(base.count, 2)
		
		let scope1 = D2ScriptStorage(name: "scope 1", parent: base)
		XCTAssertEqual(scope1.count, 2)
		XCTAssertEqual(scope1["A"], D2ScriptValue.number(1))
		
		scope1["C"] = .string("Demo")
		assertThat(storage: scope1, contains: "C")
		assertThat(storage: base, notContains: "C")
		XCTAssertEqual(scope1.count, 3)
		
		let shadowingScope = D2ScriptStorage(name: "shadowing scope", parent: base)
		shadowingScope["D"] = .number(42)
		base["D"] = .number(98)
		XCTAssertEqual(shadowingScope["D"], D2ScriptValue.number(42))
		XCTAssertEqual(scope1["D"], D2ScriptValue.number(98))
		XCTAssertEqual(base["D"], D2ScriptValue.number(98))
		
		shadowingScope["D"] = .number(23)
		XCTAssertEqual(shadowingScope["D"], D2ScriptValue.number(23))
		XCTAssertEqual(base["D"], D2ScriptValue.number(98))
		
		let deepScope = D2ScriptStorage(name: "deep scope", parent: scope1)
		XCTAssertEqual(deepScope.count, 4)
		XCTAssertEqual(deepScope["D"], D2ScriptValue.number(98))
		XCTAssertEqual(deepScope["C"], D2ScriptValue.string("Demo"))
	}
	
	private func assertThat(storage: D2ScriptStorage, contains expected: String) {
		XCTAssert(storage.contains(expected), "Storage '\(storage.name)' should contain \(expected)")
	}
	
	private func assertThat(storage: D2ScriptStorage, notContains expected: String) {
		XCTAssert(!storage.contains(expected), "Storage '\(storage.name)' should contain not \(expected)")
	}
}
