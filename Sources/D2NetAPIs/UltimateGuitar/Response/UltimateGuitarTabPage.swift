public struct UltimateGuitarTabPage: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case tab
        case tabView = "tab_view"
    }

    public let tab: UltimateGuitarTab
    public let tabView: UltimateGuitarTabView
}
