import Foundation
@preconcurrency import GraphViz
@preconcurrency import CairoGraphics
import D2MessageIO
import Utils

public class MessageDatabaseVisualizeCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Visualizes a statistic using the message database",
        requiredPermissionLevel: .vip
    )
    private let subcommands: [String: (CommandOutput, GuildID) async -> Void]

    public init(messageDB: MessageDatabase) {
        subcommands = [
            "membersInChannels": { output, guildId in
                do {
                    var graph = Graph(directed: false)
                    var userNodes = [String: Node]()
                    var channelNodes = [String: Node]()
                    let results = try messageDB.queryMessagesPerMemberInChannels(on: guildId)
                    let maxCount = min(500, results.map(\.count).max() ?? 1)

                    graph.springConstant = 4
                    graph.maximumNumberOfLayoutIterations = 2_000

                    for (channelName, userName, count) in results where count > min(200, maxCount / 2) {
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
                        edge.exteriorLabel = String(count)
                        edge.weight = Double(count)
                        let shade = count == 0 ? 0 : UInt8(min((255 * count) / maxCount, 255))
                        let color = GraphViz.Color.rgb(red: 255 - shade, green: 255 - shade, blue: 255 - shade)
                        edge.strokeColor = color
                        edge.textColor = color
                        edge.strokeWidth = max(1, (2 * Double(count) / Double(maxCount)))
                        graph.append(edge)
                    }

                    do {
                        let data = try await withCheckedThrowingContinuation { continuation in
                            graph.render(using: .fdp, to: .png) {
                                continuation.resume(with: $0)
                            }
                        }
                        try await output.append(CairoImage(pngData: data))
                    } catch {
                        await output.append(error, errorText: "Could not render people-in-channels graph.")
                    }
                } catch {
                    await output.append(error, errorText: "Could not query people-in-channels statistic.")
                }
            }
        ]
        info.helpText = """
            Syntax: [subcommand]

            Available subcommands: \(subcommands.keys.joined(separator: ", "))
            """
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guildId = await context.guild?.id else {
            await output.append(errorText: "Not on a guild!")
            return
        }

        guard !input.isEmpty else {
            await output.append(errorText: "Please specify a subcommand: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        guard let subcommand = subcommands[input] else {
            await output.append(errorText: "Unrecognized subcommand `\(input)`. Try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        await subcommand(output, guildId)
    }
}
