public struct University: Codable {
    public enum CodingKeys: String, CodingKey {
        case domains
        case webPages = "web_pages"
        case alphaTwoCode = "alpha_two_code"
        case country
        case name
        case stateProvince = "state-province"
    }

    public let domains: [String]?
    public let webPages: [String]?
    public let alphaTwoCode: String?
    public let country: String?
    public let name: String
    public let stateProvince: String?
}
