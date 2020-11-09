import D2MessageIO

public struct RoleReactionsConfiguration: Codable {
    /// The messages that can be used to auto-assign roles via reactions.
    public var roleMessages: [MessageID: RoleMessage] = [:]

    public init() {}

    public struct RoleMessage: Codable {
        /// Maps emojis to role ids.
        public var roleMappings: [String: RoleID] = [:]
    }
}
