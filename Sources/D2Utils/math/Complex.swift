/// A complex number, i.e. an element of the algebraic
/// closure of the real numbers.
public struct Complex: SignedNumeric, Addable, Subtractable, Multipliable, Divisible, Negatable, Absolutable, Hashable, ExpressibleByFloatLiteral, CustomStringConvertible {
	public static let i = Complex(0, i: 1)
	public var real: Double
	public var imag: Double
	public var description: String { return "\(real) + \(imag)i" }
	public var magnitudeSquared: Double { return (real * real) + (imag * imag) }
	public var magnitude: Double { return magnitudeSquared.squareRoot() }
	public var absolute: Double { return magnitude }
	public var squared: Complex { return self * self }
	
	public init(_ real: Double = 0, i imag: Double = 0) {
		self.real = real
		self.imag = imag
	}
	
	public init<T: BinaryInteger>(exactly value: T) {
		self.init(Double(value))
	}
	
	public init(integerLiteral value: Int) {
		self.init(Double(value))
	}
	
	public init(floatLiteral value: Double) {
		self.init(value)
	}
	
	public static func +(lhs: Complex, rhs: Complex) -> Complex {
		return Complex(lhs.real + rhs.real, i: lhs.imag + rhs.imag)
	}
	
	public static func -(lhs: Complex, rhs: Complex) -> Complex {
		return Complex(lhs.real - rhs.real, i: lhs.imag - rhs.imag)
	}
	
	public static func +=(lhs: inout Complex, rhs: Complex) {
		lhs.real += rhs.real
		lhs.imag += rhs.imag
	}
	
	public static func -=(lhs: inout Complex, rhs: Complex) {
		lhs.real -= rhs.real
		lhs.imag -= rhs.imag
	}
	
	public static func *=(lhs: inout Complex, rhs: Complex) {
		let newReal = (lhs.real * rhs.real) - (lhs.imag * rhs.imag)
		let newImag = (lhs.real * rhs.imag) + (lhs.imag * rhs.real)
		lhs.real = newReal
		lhs.imag = newImag
	}
	
	public static func /=(lhs: inout Complex, rhs: Complex) {
		let denominator = (rhs.real * rhs.real) + (rhs.imag * rhs.imag)
		let newReal = ((lhs.real * rhs.real) + (lhs.imag * rhs.imag)) / denominator
		let newImag = ((lhs.imag * rhs.real) - (lhs.real * rhs.imag)) / denominator
		lhs.real = newReal
		lhs.imag = newImag
	}
	
	public static func *(lhs: Complex, rhs: Double) -> Complex {
		return Complex(lhs.real * rhs, i: lhs.imag * rhs)
	}
	
	public static func *(lhs: Complex, rhs: Int) -> Complex {
		return lhs * Double(rhs)
	}
	
	public static func /(lhs: Complex, rhs: Double) -> Complex {
		return Complex(lhs.real / rhs, i: lhs.imag / rhs)
	}
	
	public static func /(lhs: Complex, rhs: Int) -> Complex {
		return lhs / Double(rhs)
	}
	
	public static func *(lhs: Complex, rhs: Complex) -> Complex {
		var result = lhs
		result *= rhs
		return result
	}
	
	public static func /(lhs: Complex, rhs: Complex) -> Complex {
		var result = lhs
		result /= rhs
		return result
	}
	
	public mutating func negate() {
		real.negate()
		imag.negate()
	}
	
	public prefix static func -(operand: Complex) -> Complex {
		return Complex(-operand.real, i: -operand.imag)
	}
	
	public func equals(_ rhs: Complex, accuracy: Double) -> Bool {
		return (real - rhs.real).magnitude < accuracy
			&& (imag - rhs.imag).magnitude < accuracy
	}
}
