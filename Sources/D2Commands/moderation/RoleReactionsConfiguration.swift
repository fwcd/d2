import Foundation
import D2MessageIO
import Utils

public struct RoleReactionsConfiguration: Codable {
    /// The messages that can be used to auto-assign roles via reactions.
    public var roleMessages: [MessageID: Mappings] = [:]

    public init() {}

    public struct Mappings: Codable, Sequence {
        /// Maps emojis to role ids.
        public var roleMappings: [String: RoleID]

        public init(roleMappings: [String: RoleID] = [:]) {
            self.roleMappings = roleMappings
        }

        public func makeIterator() -> Dictionary<String, RoleID>.Iterator {
            roleMappings.makeIterator()
        }
    }
}
