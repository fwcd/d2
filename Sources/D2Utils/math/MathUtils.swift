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

/// Finds a nontrivial factor of the given number.
public func integerFactor<I>(_ n: I) -> I? where I: IntExpressibleAlgebraicField & Remainderable & Magnitudable, I.Magnitude == I {
	func g(_ x: I) -> I {
		return (x * x + 1) % n
	}

	// Pollard's rho algorithm
	var x: I = 2
	var y: I = 2
	var d: I = 1

	while d == 1 {
		d = g(x)
		y = g(g(y))
		d = greatestCommonDivisor((x - y).magnitude, n)
	}

	return d == n ? nil : d
}

/// Finds the prime factorization of the given integer.
public func primeFactorization<I>(_ n: I) -> [I] where I: IntExpressibleAlgebraicField & Remainderable & Magnitudable, I.Magnitude == I {
	var factors = [I]()
	var remaining = n

	while let factor = integerFactor(remaining) {
		factors.append(factor)
		remaining /= factor
	}

	return factors
}
