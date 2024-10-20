import Testing
@testable import D2Script

struct D2ScriptStorageTests {
    @Test func storage() throws {
        let base = D2ScriptStorage(name: "base storage")
        base["A"] = .number(1)
        base["B"] = .number(2)

        expect(storage: base, contains: "A")
        expect(storage: base, contains: "B")
        expect(storage: base, notContains: "C")
        #expect(base.count == 2)

        let scope1 = D2ScriptStorage(name: "scope 1", parent: base)
        #expect(scope1.count == 2)
        #expect(scope1["A"] == D2ScriptValue.number(1))

        scope1["C"] = .string("Demo")
        expect(storage: scope1, contains: "C")
        expect(storage: base, notContains: "C")
        #expect(scope1.count == 3)

        let shadowingScope = D2ScriptStorage(name: "shadowing scope", parent: base)
        shadowingScope["D"] = .number(42)
        base["D"] = .number(98)
        #expect(shadowingScope["D"] == D2ScriptValue.number(42))
        #expect(scope1["D"] == D2ScriptValue.number(98))
        #expect(base["D"] == D2ScriptValue.number(98))

        shadowingScope["D"] = .number(23)
        #expect(shadowingScope["D"] == D2ScriptValue.number(23))
        #expect(base["D"] == D2ScriptValue.number(98))

        let deepScope = D2ScriptStorage(name: "deep scope", parent: scope1)
        #expect(deepScope.count == 4)
        #expect(deepScope["D"] == D2ScriptValue.number(98))
        #expect(deepScope["C"] == D2ScriptValue.string("Demo"))
    }

    private func expect(storage: D2ScriptStorage, contains expected: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(storage.contains(expected), "Storage '\(storage.name)' should contain \(expected)", sourceLocation: sourceLocation)
    }

    private func expect(storage: D2ScriptStorage, notContains expected: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(!storage.contains(expected), "Storage '\(storage.name)' should contain not \(expected)", sourceLocation: sourceLocation)
    }
}
