import Utils

/// A quadratic equation of the form ax^2 + bx + c = 0
public struct QuadraticEquation: Hashable {
    public let a: Rational
    public let b: Rational
    public let c: Rational

    private var underTheRoot: Rational {
        b * b - 4 * a * c
    }

    private var root: Rational? {
        underTheRoot.asDouble >= 0
            ? Rational(approximately: underTheRoot.asDouble.squareRoot())
            : nil
    }

    public var solutions: Set<Rational> {
        root.map { root -> Set<Rational> in
            [
                -(b + root) / (2 * a),
                -(b - root) / (2 * a)
            ]
        } ?? []
    }
}
