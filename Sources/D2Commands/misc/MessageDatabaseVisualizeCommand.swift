import GraphViz
import DOT
import D2Graphics
import D2MessageIO
import D2Utils

public class MessageDatabaseVisualizeCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Visualizes a statistic using the message database",
        requiredPermissionLevel: .vip
    )
    private let subcommands: [String: (CommandOutput, GuildID) -> Void]

    public init(messageDB: MessageDatabase) {
        subcommands = [
            "membersInChannels": { output, guildId in
                do {
                    var graph = Graph(directed: false)
                    var userNodes = [String: Node]()
                    var channelNodes = [String: Node]()
                    let results = try messageDB.queryMessagesPerMemberInChannels(on: guildId)

                    for (channelName, userName, count) in results where count > 100 {
                        let userNode = userNodes[userName] ?? {
                            var node = Node(userName)
                            node.fillColor = .named(.gold)
                            graph.append(node)
                            return node
                        }()
                        let channelNode = channelNodes[channelName] ?? {
                            var node = Node(channelName)
                            node.fillColor = .named(.cyan)
                            graph.append(node)
                            return node
                        }()

                        userNodes[userName] = userNode
                        channelNodes[channelName] = channelNode

                        var edge = Edge(from: userNode, to: channelNode)
                        edge.weight = Double(count)
                        graph.append(edge)
                    }

                    let data = try DOTRenderer(using: .sfdp, to: .png).render(graph: graph)
                    try output.append(try Image(fromPng: data))
                } catch {
                    output.append(error, errorText: "Could not query/render people-in-channels statistic.")
                }
            }
        ]
        info.helpText = """
            Syntax: [subcommand]

            Available subcommands: \(subcommands.keys.joined(separator: ", "))
            """
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guildId = context.guild?.id else {
            output.append(errorText: "Not on a guild!")
            return
        }

        guard let subcommand = subcommands[input] else {
            output.append(errorText: "Unrecognized subcommand `\(input)`. Try one of these: \(subcommands.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        subcommand(output, guildId)
    }
}
