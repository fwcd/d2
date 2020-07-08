@dynamicMemberLookup
public struct UnionStringEnum<R, S>: StringEnum where R: StringEnum, S: StringEnum {
    public static var allCases: [UnionStringEnum<R, S>] { (R.allCases.map { $0.rawValue } + S.allCases.map { $0.rawValue }).compactMap(Self.init(rawValue:)) }
    public let rawValue: String

    public init?(rawValue: String) {
        guard R.init(rawValue: rawValue) != nil || S.init(rawValue: rawValue) != nil else { return nil }
        self.rawValue = rawValue
    }

    public static subscript(dynamicMember rawValue: String) -> UnionStringEnum<R, S> {
        guard let member = UnionStringEnum(rawValue: rawValue) else { fatalError("Not a valid union enum member: \(rawValue)") }
        return member
    }
}
