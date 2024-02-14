/// This struct reflects the JSON format required
/// by  https://integral-calculator.com/int.php
public struct DefaultIntegralQueryParams: IntegralQueryParams {
    public static let endpoint: String = "/int.php"
    public var secondsSinceFirstQuery: Int = 0
    public var expression: String
    public var expressionCanonical: String
    public var intVar: String
    public var lowerBound: String = ""
    public var upperBound: String = ""
    public var numericalOnly: Bool = false
    public var simplifyExpressions: Bool = false
    public var simplifyAllRoots: Bool = false
    public var complexMode: Bool = false
    public var keepDecimals: Bool = false
    public var alternatives: [String: String] = [:]
    public var lowerBoundCanonical: String = ""
    public var upperBoundCanonical: String = ""

    public init(expression: String, expressionCanonical: String, intVar: String) {
        self.expression = expression
        self.expressionCanonical = expressionCanonical
        self.intVar = intVar
    }
}
