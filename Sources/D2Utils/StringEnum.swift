public protocol StringEnum: CaseIterable, Hashable {
    var rawValue: String { get }

    init?(rawValue: String)
}
