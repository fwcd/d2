public enum QuadraticEquationParseError: Error {
    case expectedRational(Substring?)
    case expectedOperator(Substring?)
    case expectedPower(Substring?)
    case expectedEquals(Substring?)
    case expectedMonomial(Substring?)
    case rhsIsNotAFraction
    case noCoefficients
    case degreeGreaterThan2
}
