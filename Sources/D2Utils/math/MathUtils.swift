import Logging

fileprivate let log = Logger(label: "D2Utils.MathUtils")

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

infix operator %%: MultiplicationPrecedence

/// Computes the floor modulus. Useful for cyclic indexing.
public func %%(lhs: Int, rhs: Int) -> Int {
	(lhs % rhs + rhs) % rhs
}

public func leastCommonMultiple<I>(_ lhs: I, _ rhs: I) -> I where I: ExpressibleByIntegerLiteral & Multipliable & Equatable & Divisible & Remainderable {
	(lhs * rhs) / greatestCommonDivisor(lhs, rhs)
}

public func greatestCommonDivisor<I>(_ lhs: I, _ rhs: I) -> I where I: ExpressibleByIntegerLiteral & Equatable & Remainderable {
	rhs == 0 ? lhs : greatestCommonDivisor(rhs, lhs % rhs)
}

/// Computes the distance metric without risking over/underflow.
private func distance<I>(_ x: I, _ y: I) -> I.Magnitude where I: Comparable & Subtractable & Magnitudable {
	x < y ? (y - x).magnitude : (x - y).magnitude
}

/// Deterministically checks whether a number is prime.
public func isPrime<I>(_ n: I) -> Bool where I: ExpressibleByIntegerLiteral & Remainderable & Divisible & Comparable & Strideable, I.Stride: SignedInteger {
	// TODO: Use a better algorithm than trial division
	guard n != 2, n != 3 else { return true }
	for i in (2..<(n / 2)).reversed() {
		guard n % i != 0 else { return false }
	}
	return true
}

/// Finds a nontrivial factor of the given number.
public func integerFactor<I>(_ n: I, _ c: I = 1) -> I? where I: ExpressibleByIntegerLiteral & Addable & Multipliable & Subtractable & Divisible & Comparable & Remainderable & Magnitudable & Strideable, I.Magnitude == I, I.Stride: SignedInteger {
	func g(_ x: I) -> I {
		return (x * x + c) % n
	}

	// Pollard's rho algorithm
	var x: I = 2
	var y: I = 2
	var d: I = 1

	while d == 1 {
		x = g(x)
		y = g(g(y))
		d = greatestCommonDivisor(distance(x, y), n)
	}

	return d == n ? (isPrime(n) ? nil : integerFactor(n, c + 1)) : d
}

/// Finds the prime factorization of the given integer.
public func primeFactorization<I>(_ n: I) -> [I] where I: ExpressibleByIntegerLiteral & Addable & Multipliable & Subtractable & Divisible & Equatable & Comparable & Remainderable & Magnitudable & Strideable, I.Magnitude == I, I.Stride: SignedInteger {
	log.trace("Factoring \(n)...")
	if let factor = integerFactor(n) {
		return primeFactorization(factor) + primeFactorization(n / factor)
	} else {
		return [n]
	}
}
