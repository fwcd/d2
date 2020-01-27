public struct Rational: SignedNumeric, Addable, Subtractable, Multipliable, Divisible, Negatable, ExpressibleByIntegerLiteral, Hashable, Comparable, CustomStringConvertible {
    public var numerator: Int
    public var denominator: Int // Always positive

    public var description: String { denominator == 1 ? String(numerator) : "\(numerator)/\(denominator)" }
    public var asDouble: Double { Double(numerator) / Double(denominator) }
    public var reduced: Rational { reduced(by: greatestCommonDivisor(numerator, denominator)) }
    public var magnitude: Rational { Rational(abs(numerator), denominator) }
    
    public init<T>(exactly value: T) where T: BinaryInteger {
        self.init(integerLiteral: Int(value))
    }
    
    public init(integerLiteral value: Int) {
        numerator = value
        denominator = 1
    }
    
    public init(_ numerator: Int, _ denominator: Int) {
        let sign = numerator.signum() * denominator.signum()
        self.numerator = sign * abs(numerator)
        self.denominator = abs(denominator)
    }
    
    public static func +(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator, lhs.denominator * rhs.denominator)
    }
    
    public static func +=(lhs: inout Rational, rhs: Rational) {
        let newDenominator = lhs.denominator * rhs.denominator
        lhs.numerator = lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator
        lhs.denominator = newDenominator
    }
    
    public static func -(lhs: Rational, rhs: Rational) -> Rational {
        lhs + (-rhs)
    }
    
    public static func -=(lhs: inout Rational, rhs: Rational) {
        lhs += (-rhs)
    }
    
    public static func *(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator)
    }
    
    public static func *=(lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.numerator
        lhs.denominator *= rhs.denominator
    }
    
    public static func /(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
    }
    
    public static func /=(lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.denominator
        lhs.denominator *= rhs.numerator
    }
    
    public static prefix func -(operand: Rational) -> Rational {
        Rational(-operand.numerator, operand.denominator)
    }
    
    public static func <(lhs: Rational, rhs: Rational) -> Bool {
        if lhs.denominator == rhs.denominator {
            return lhs.numerator < rhs.numerator
        } else {
            return lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
        }
    }
    
    public mutating func negate() {
        numerator.negate()
        denominator.negate()
    }
    
    public func expandd(by factor: Int) -> Rational {
        Rational(numerator * factor, denominator * factor)
    }
    
    public func reduced(by factor: Int) -> Rational {
        Rational(numerator / factor, denominator / factor)
    }
}
