/** A single-layered perceptron with a single output neuron. */
struct SingleLayerPerceptron {
	private var bias: Double
	private var weights: [Double]
	private var lastOutput: Double? = nil
	private(set) var inputHistory: [[Double]] = []
	
	var dimensions: Int { return weights.count }
	var formula: String {
		let weightsStr = weights.enumerated().map { String(format: "%.03f x%d", $0.1, $0.0 + 1) }.joined(separator: " + ")
		let biasStr = String(format: "%.03f", bias)
		return "Θ(\(weightsStr) + \(biasStr))\(lastOutput.map { String(format: " = %.3f", $0) } ?? "")"
	}
	
	/** Creates a new single-layered Perceptron with randomly initialized weights. */
	init(inputCount: Int) {
		bias = Double.random(in: 0.0..<1.0)
		weights = (0..<inputCount).map { _ in Double.random(in: 0.0..<1.0) }
	}
	
	@discardableResult
	mutating func compute(_ inputs: [Double]) throws -> Double {
		guard inputs.count == weights.count else {
			throw MLError.sizeMismatch("Input count of \(inputs) (\(inputs.count)) should match dimensions (\(weights.count))")
		}
		
		let output = heaviside(zip(inputs, weights).map(*).reduce(0, +))
		inputHistory.append(inputs)
		lastOutput = output
		
		return output
	}
	
	mutating func learn(expected: Double, rate: Double) throws {
		guard let inputs = inputHistory.last, let output = lastOutput else {
			throw MLError.illegalState("Can not update the weights without a forward pass")
		}
		
		bias += (expected - output) * rate
		weights = weights.enumerated().map { $0.1 + (inputs[$0.0] * (expected - output) * rate) }
	}
	
	/**
	 * Returns the y coordinate of the separation line boundary in two-dimensions
	 * (if the dimension is != 2, an error is thrown)
	 */
	func boundaryY(atX x: Double) throws -> Double {
		guard dimensions == 2 else { throw MLError.sizeMismatch("Can not fetch the y-coordinate of a Perceptron in \(dimensions) dimensions (requires 2 dimensions)") }
		let y = -weights[0] * x - bias
		return y
	}
}
