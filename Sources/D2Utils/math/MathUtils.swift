extension Int {
	public func clockModulo(_ rhs: Int) -> Int {
		return (self % rhs + rhs) % rhs
	}
}

extension UnsignedInteger {
	public var leadingZeros: Int {
		let maxIndex = bitWidth - 1
		for i in 0..<bitWidth {
			if (self >> (maxIndex - i)) & 1 != 0 {
				return i
			}
		}
		return bitWidth
	}

	public func log2Floor() -> Int {
		return (bitWidth - 1) - leadingZeros
	}
}

infix operator **: MultiplicationPrecedence

public func **(lhs: Int, rhs: Int) -> Int {
	assert(rhs >= 0)
	var result = 1
	for _ in 0..<rhs {
		result *= lhs
	}
	return result
}

public func leastCommonMultiple<I>(_ lhs: I, _ rhs: I) -> I where I: ExpressibleByIntegerLiteral & Multipliable & Equatable & Divisible & Remainderable {
	(lhs * rhs) / greatestCommonDivisor(lhs, rhs)
}

public func greatestCommonDivisor<I>(_ lhs: I, _ rhs: I) -> I where I: ExpressibleByIntegerLiteral & Equatable & Remainderable {
	rhs == 0 ? lhs : greatestCommonDivisor(rhs, lhs % rhs)
}
