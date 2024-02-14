import D2MessageIO
import Utils

public class ReactionLeaderboardCommand: Command {
    public private(set) var info = CommandInfo(
        category: .misc,
        helpText: "Syntax: [users...]?",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .embed

    private let messageDB: MessageDatabase
    private let title: String
    private let name: String
    private let useReactor: Bool
    private let emojiName: String

    public init(title: String, name: String, emojiName: String, useReactor: Bool, messageDB: MessageDatabase) {
        self.title = title
        self.name = name
        self.emojiName = emojiName
        self.useReactor = useReactor // If false, the message's author will be used instead
        self.messageDB = messageDB

        info.shortDescription = "Fetches \(title)"
        info.longDescription = "Fetches the number of \(name) reactions per user"
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        do {
            guard let guild = context.guild else {
                output.append(errorText: "No guild available")
                return
            }
            let users: [User] = input.asMentions ?? guild.members.map { $0.1.user }
            let emojiId = try messageDB.emojiIds(for: emojiName).first
            output.append(Embed(
                title: "\(emojiId.map { "<:\(emojiName):\($0)> " } ?? emojiName)\(title)",
                description: try users
                    .map { (useReactor
                        ? try messageDB.countReactions(reactorId: $0.id, emojiName: emojiName)
                        : try messageDB.countReactions(authorId: $0.id, emojiName: emojiName), $0.username) }
                    .filter { $0.0 > 0 }
                    .sorted(by: descendingComparator { $0.0 })
                    .map { "**\($0.1)**: \($0.0) \(name.pluralized(with: $0.0))" }
                    .prefix(20)
                    .joined(separator: "\n")
                    .nilIfEmpty
            ))
        } catch {
            output.append(error, errorText: "Something went wrong while querying the message db")
        }
    }
}
