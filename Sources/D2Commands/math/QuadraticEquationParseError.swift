public enum QuadraticEquationParseError: Error {
    case notAnEquation
    case rhsIsNotAFraction
    case noCoefficients
    case degreeGreaterThan2
}
