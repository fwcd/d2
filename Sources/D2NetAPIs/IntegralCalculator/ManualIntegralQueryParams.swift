/// This struct reflects the JSON format required
/// by https://integral-calculator.com/manualint.php
public struct ManualIntegralQueryParams: IntegralQueryParams {
    public static let endpoint: String = "/manualint.php"
    public var secondsSinceFirstQuery: Int = 0
    public var expression: String
    public var expressionCanonical: String
    public var intVar: String
    public var complexMode: Bool = false
    public var keepDecimals: Bool = false
    public var alternatives: [String: String] = [:]
    public var f: String = "F"
    public var shareURL: String = "https://www.integral-calculator.com"
    public var maximaFoundAnElementaryAntiderivative: Bool = false

    public init(expression: String, expressionCanonical: String, intVar: String) {
        self.expression = expression
        self.expressionCanonical = expressionCanonical
        self.intVar = intVar
    }
}
