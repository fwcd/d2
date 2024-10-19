import Testing
import Utils
@testable import D2Commands

struct QuadraticEquationTests {
    @Test func parsing() throws {
        #expect(try QuadraticEquation(parsing: "x^2 = 0") == .init(a: 1, b: 0, c: 0))
        #expect(try QuadraticEquation(parsing: "x = 0") == .init(a: 0, b: 1, c: 0))
        #expect(try QuadraticEquation(parsing: "x^2 + x = 0") == .init(a: 1, b: 1, c: 0))
        #expect(try QuadraticEquation(parsing: "x^2 - x = 0") == .init(a: 1, b: -1, c: 0))
        #expect(try QuadraticEquation(parsing: "4 x^2 - x = 0") == .init(a: 4, b: -1, c: 0))
        #expect(try QuadraticEquation(parsing: "4 x^2 - 3/2 x = 0") == .init(a: 4, b: -Rational(3, 2), c: 0))
        #expect(try QuadraticEquation(parsing: "4x^2 - 9 x +  1 = 0") == .init(a: 4, b: -9, c: 1))
        #expect(try QuadraticEquation(parsing: "3 = x") == .init(a: 0, b: -1, c: 3))
        #expect(try QuadraticEquation(parsing: "3 = x - x^2") == .init(a: 1, b: -1, c: 3))
        #expect(try QuadraticEquation(parsing: "4 x^2 - 3/2 x = 4") == .init(a: 4, b: -Rational(3, 2), c: -4))
        #expect(try QuadraticEquation(parsing: "4 x^2 - 3/2 x = -4") == .init(a: 4, b: -Rational(3, 2), c: 4))
        #expect(try QuadraticEquation(parsing: "x^2  +  9 x =  - 8 x + 1 - 3 + 9 x^2") == .init(a: -8, b: 17, c: 2))
    }
}
