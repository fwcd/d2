import Utils

func latexOf(ndArrays: [NDArray<Rational>]) -> String {
    ndArrays.map { latexOf(ndArray: $0) }.joined(separator: " ")
}

func latexOf(ndArray: NDArray<Rational>) -> String {
    if let scalar = ndArray.asScalar {
        return latexOf(rational: scalar)
    } else if let matrix = ndArray.asMatrix {
        return "\\begin{pmatrix}\(matrix.asArray.map { $0.map { latexOf(rational: $0) }.joined(separator: " & ") }.joined(separator: " \\\\\\\\ "))\\end{pmatrix}"
    } else {
        return "\\begin{pmatrix}\(try! ndArray.split().map { latexOf(ndArray: $0) }.joined(separator: " & "))\\end{pmatrix}"
    }
}

func latexOf(rational: Rational) -> String {
    let sign = rational.signum()
    let frac: String
    if rational.isPrecise {
        let absReduced = abs(rational.reduced())
        frac = absReduced.denominator == 1 ? String(absReduced.numerator) : "\\frac{\(absReduced.numerator)}{\(absReduced.denominator)}"
    } else {
        frac = String(format: "%.4f", rational.asDouble.magnitude)
    }
    return "\(sign < 0 ? "-" : "\\phantom{-}")\(frac)"
}
