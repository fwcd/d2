/** A single-layered perceptron with a single output neuron. */
struct SingleLayerPerceptron {
	private var bias: Double
	private var weights: [Double]
	private var lastInputs: [Double]? = nil
	private var lastOutput: Double? = nil
	var formula: String {
		let weightsStr = weights.enumerated().map { "\($0.1)x\($0.0)" }.joined(separator: " + ")
		return "Θ(\(weightsStr) + \(bias))\(lastOutput.map { "= \($0)" } ?? "")"
	}
	
	/** Creates a new single-layered Perceptron with randomly initialized weights. */
	init(inputCount: Int) {
		bias = Double.random(in: 0.0..<1.0)
		weights = (0..<inputCount).map { _ in Double.random(in: 0.0..<1.0) }
	}
	
	@discardableResult
	mutating func compute(_ inputs: [Double]) throws -> Double {
		guard inputs.count == weights.count else {
			throw MLError.sizeMismatch("Input count (\(inputs.count)) should match dimensions (\(weights.count))")
		}
		
		let output = heaviside(zip(inputs, weights).map(*).reduce(0, +))
		lastInputs = inputs
		lastOutput = output
		
		return output
	}
	
	mutating func learn(expected: Double, rate: Double) throws {
		guard let inputs = lastInputs, let output = lastOutput else {
			throw MLError.illegalState("Can not update the weights without a forward pass")
		}
		
		bias += (expected - output) * rate
		weights = weights.enumerated().map { $0.1 + (inputs[$0.0] * (expected - output) * rate) }
	}
}
