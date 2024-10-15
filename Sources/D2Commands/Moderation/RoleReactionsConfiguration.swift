import Foundation
import D2MessageIO
import Utils

public struct RoleReactionsConfiguration: Sendable, Codable {
    /// The messages that can be used to auto-assign roles via reactions.
    public var roleMessages: [MessageID: Mappings] = [:]

    public init() {}

    public struct Mappings: Codable, Sequence {
        /// Maps emojis to role ids. Standard emojis are stored in the usual
        /// unicode format and custom emojis are represented using 'name:id'
        /// syntax.
        public var roleMappings: [String: RoleID]

        public init(roleMappings: [String: RoleID] = [:]) {
            self.roleMappings = roleMappings
        }

        public func makeIterator() -> Dictionary<String, RoleID>.Iterator {
            roleMappings.makeIterator()
        }

        /// Fetches the role ID for an emoji. This subscript handles the case
        /// where a custom emoji is looked up without its id (i.e. with the
        /// syntax 'name' instead of 'name:id').
        public subscript(emoji: String) -> RoleID? {
            print("\(emoji) vs \(roleMappings)")
            return roleMappings[emoji] ?? roleMappings.first { $0.key.starts(with: "\(emoji):") }?.value
        }
    }
}
