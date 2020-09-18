fileprivate let decimalPattern = try! Regex(from: "(-?)\\s*(\\d+)(?:\\.(\\d+))?")
fileprivate let fractionPattern = try! Regex(from: "(-?\\s*\\d+)\\s*/\\s*(-?\\s*\\d+)")

fileprivate let reduceThreshold = 1000

/// A numeric type supporting precise division.
public struct Rational: SignedNumeric, Addable, Subtractable, Multipliable, Divisible, Negatable, Absolutable, ExpressibleByIntegerLiteral, Hashable, Comparable, CustomStringConvertible {
    public var numerator: Int
    public var denominator: Int
    public var isPrecise: Bool

    public var asDouble: Double { Double(numerator) / Double(denominator) }
    public var magnitude: Rational { Rational(abs(numerator), denominator) }
    public var absolute: Double { magnitude.asDouble }

    public var isDisplayedAsFraction: Bool { isPrecise && denominator != 1 }
    public var directDescription: String { isPrecise ? (denominator == 1 ? String(numerator) : "\(numerator)/\(denominator)") : "\(asDouble)" }
    public var description: String { reduced().directDescription }

    public init?(_ string: String) {
        if let parsedFraction = fractionPattern.firstGroups(in: string) {
            guard let numerator = Int(parsedFraction[1]),
                let denominator = Int(parsedFraction[2]),
                denominator != 0 else { return nil }
            self.init(numerator, denominator)
        } else if let parsedDecimal = decimalPattern.firstGroups(in: string) {
            let rawSign = parsedDecimal[1]
            let rawCharacteristic = parsedDecimal[2]
            let rawMantissa = parsedDecimal[3]
            let sign = rawSign == "-" ? -1 : 1
            let factor = 10 ** rawMantissa.count
            guard let characteristic = Int(rawCharacteristic), factor != 0 else { return nil }
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
        isPrecise = true
    }

    public init(approximately value: Double, accuracy: Int = 10_000) {
        self.init(Int((value * Double(accuracy)).rounded()), accuracy, isPrecise: false)
        reduce()
    }

    public init(_ numerator: Int, _ denominator: Int, isPrecise: Bool = true) {
        guard denominator != 0 else { fatalError("Cannot create a rational with denominator == 0: \(numerator)/\(denominator)") }
        self.numerator = numerator
        self.denominator = denominator
        self.isPrecise = isPrecise
        normalizeSign()
    }

    public static func +(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator, lhs.denominator * rhs.denominator, isPrecise: lhs.isPrecise && rhs.isPrecise).autoReduced()
    }

    public static func +=(lhs: inout Rational, rhs: Rational) {
        let newDenominator = lhs.denominator * rhs.denominator
        lhs.numerator = lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator
        lhs.denominator = newDenominator
        lhs.isPrecise = lhs.isPrecise && rhs.isPrecise
        lhs.autoReduce()
    }

    public static func -(lhs: Rational, rhs: Rational) -> Rational {
        lhs + (-rhs)
    }

    public static func -=(lhs: inout Rational, rhs: Rational) {
        lhs += (-rhs)
    }

    public static func *(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator, isPrecise: lhs.isPrecise && rhs.isPrecise).autoReduced()
    }

    public static func *=(lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.numerator
        lhs.denominator *= rhs.denominator
        lhs.isPrecise = lhs.isPrecise && rhs.isPrecise
        lhs.autoReduce()
    }

    public static func /(lhs: Rational, rhs: Rational) -> Rational {
        Rational(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator, isPrecise: lhs.isPrecise && rhs.isPrecise).autoReduced()
    }

    public static func /=(lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.denominator
        lhs.denominator *= rhs.numerator
        lhs.isPrecise = lhs.isPrecise && rhs.isPrecise
        lhs.autoReduce()
    }

    public static prefix func -(operand: Rational) -> Rational {
        Rational(-operand.numerator, operand.denominator, isPrecise: operand.isPrecise)
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
        Rational(numerator * factor, denominator * factor, isPrecise: isPrecise)
    }

    public mutating func expand(by factor: Int) {
        numerator *= factor
        denominator *= factor
    }

    public func reduced(by factor: Int) -> Rational {
        Rational(numerator / factor, denominator / factor, isPrecise: isPrecise).normalizedSign()
    }

    public func reduced() -> Rational {
        reduced(by: greatestCommonDivisor(numerator, denominator))
    }

    public func autoReduced() -> Rational {
        var r = self
        r.autoReduce()
        return r
    }

    public mutating func reduce(by factor: Int) {
        numerator /= factor
        denominator /= factor
        normalizeSign()
    }

    public mutating func reduce() {
        reduce(by: greatestCommonDivisor(numerator, denominator))
    }

    public mutating func autoReduce() {
        // Auto-reduce fraction if the denom gets too large
        if denominator > reduceThreshold {
            reduce()
        }
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
