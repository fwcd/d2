fileprivate let decimalPattern = try! Regex(from: "(-?)(\\d+)(?:\\.(\\d+))?")
fileprivate let fractionPattern = try! Regex(from: "(-?\\d+)\\s*/\\s*(-?\\d+)")

fileprivate let reduceThreshold = 1000

/// A numeric type supporting precise division.
public struct Rational: SignedNumeric, Addable, Subtractable, Multipliable, Divisible, Negatable, Absolutable, ExpressibleByIntegerLiteral, Hashable, Comparable, CustomStringConvertible {
    public var numerator: Int
    public var denominator: Int

    public var directDescription: String { denominator == 1 ? String(numerator) : "\(numerator)/\(denominator)" }
    public var description: String { reduced().directDescription }
    public var asDouble: Double { Double(numerator) / Double(denominator) }
    public var magnitude: Rational { Rational(abs(numerator), denominator) }
    public var absolute: Double { magnitude.asDouble }
    
    public init?(_ string: String) {
        if let parsedFraction = fractionPattern.firstGroups(in: string) {
            self.init(Int(parsedFraction[1])!, Int(parsedFraction[2])!)
        } else if let parsedDecimal = decimalPattern.firstGroups(in: string) {
            let rawSign = parsedDecimal[1]
            let rawCharacteristic = parsedDecimal[2]
            let rawMantissa = parsedDecimal[3]
            let sign = rawSign == "-" ? -1 : 1
            let factor = 10 ** rawMantissa.count
            let characteristic = Int(rawCharacteristic)!
            let mantissa = Int(rawMantissa) ?? 0
            self.init(sign * (characteristic * factor + mantissa), factor)
            reduce()
        } else {
            return nil
        }
    }
    
    public init<T>(exactly value: T) where T: BinaryInteger {
        self.init(integerLiteral: Int(value))
    }
    
    public init(integerLiteral value: Int) {
        numerator = value
        denominator = 1
    }
    
    public init(_ numerator: Int, _ denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
        normalizeSign()
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
        // Auto-reduce fraction if the denom gets too large
        if lhs.denominator > reduceThreshold {
            lhs.reduce()
        }
    }
    
    public static func /(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
    }
    
    public static func /=(lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.denominator
        lhs.denominator *= rhs.numerator
        // Auto-reduce fraction if the denom gets too large
        if lhs.denominator > reduceThreshold {
            lhs.reduce()
        }
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

    public static func ==(lhs: Rational, rhs: Rational) -> Bool {
        let lr = lhs.reduced()
        let rr = rhs.reduced()
        return lr.numerator == rr.numerator && lr.denominator == rr.denominator
    }

    public func hash(into hasher: inout Hasher) {
        let r = reduced()
        hasher.combine(r.numerator)
        hasher.combine(r.denominator)
    }
    
    public func signum() -> Int {
        numerator.signum() * denominator.signum()
    }
    
    public mutating func negate() {
        numerator.negate()
        denominator.negate()
    }
    
    public func expanded(by factor: Int) -> Rational {
        Rational(numerator * factor, denominator * factor)
    }
    
    public mutating func expand(by factor: Int) {
        numerator *= factor
        denominator *= factor
    }
    
    public func reduced(by factor: Int) -> Rational {
        Rational(numerator / factor, denominator / factor).normalizedSign()
    }
    
    public func reduced() -> Rational {
        reduced(by: greatestCommonDivisor(numerator, denominator))
    }
    
    public mutating func reduce(by factor: Int) {
        numerator /= factor
        denominator /= factor
        normalizeSign()
    }
    
    public mutating func reduce() {
        reduce(by: greatestCommonDivisor(numerator, denominator))
    }
    
    private mutating func normalizeSign() {
        let sign = signum()
        numerator = sign * abs(numerator)
        denominator = abs(denominator)
    }
    
    private func normalizedSign() -> Rational {
        var res = self
        res.normalizeSign()
        return res
    }
}
