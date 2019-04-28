/**
 * This struct reflects the JSON format required
 * by POST requests to https://integral-calculator.com/manualint.php
 */
public struct IntegralQueryParams: Codable {
	public var secondsSinceFirstQuery: Int = 0
	public var expression: String
	public var expressionCanonical: String
	public var intVar: String
	public var complexMode: Bool = false
	public var keepDecimals: Bool = false
	public var f: String = "F"
	public var maximaFoundElementaryAntiderivative: Bool = false
	
	public init(expression: String, expressionCanonical: String, intVar: String) {
		self.expression = expression
		self.expressionCanonical = expressionCanonical
		self.intVar = intVar
	}
}
