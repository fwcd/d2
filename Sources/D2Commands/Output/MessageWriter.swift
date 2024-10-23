import Logging
import StaticMap
import D2MessageIO
import Utils

private let log = Logger(label: "D2Commands.MessageWriter")

/// Writes rich values into MessageIO messages (e.g. for use with Discord).
@CommandActor
public struct MessageWriter: Sendable {
    private let latexRenderer = LatexRenderer()
    private let postprocessors: [any MessagePostprocessor] = [
        WhisperPostprocessor()
    ]

    public init() {}

    public func write(value: RichValue, context: CommandContext? = nil) async throws -> Message {
        var message = try await encode(value: value)

        if let context {
            for postprocessor in postprocessors {
                message = try await postprocessor.postprocess(message: message, context: context)
            }
        }

        return message
    }

    private func encode(value: RichValue) async throws -> Message {
        switch value {
            case .none:
                return Message(content: "")
            case let .text(txt):
                if txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw MessageWriterError.emptyMessage
                }
                return Message(content: txt)
            case let .mentions(users):
                return Message(content: users.map { "<@\($0.id)>" }.joined(separator: " "))
            case let .roleMentions(roles):
                return Message(content: roles.map { "<@\($0)>" }.joined(separator: " "))
            case let .image(img):
                return try Message(fromImage: img)
            case let .table(rows):
                return Message(content: """
                    ```
                    \(rows.map { "(\($0.joined(separator: ", ")))" }.joined(separator: "\n"))
                    ```
                    """)
            case let .urls(urls):
                return Message(content: urls.map(\.absoluteString).joined(separator: " "))
            case let .gif(gif):
                return try Message(fromGif: gif)
            case let .components(components):
                return Message(components: components)
            case let .domNode(node):
                return try await write(value: .code(try node.outerHtml(), language: "html"))
            case let .code(code, language: lang):
                return Message(content: """
                    ```\(lang ?? "")
                    \(code)
                    ```
                    """)
            case let .embed(embed):
                return Message(embed: embed)
            case let .geoCoordinates(coords):
                let mapImage = try await StaticMap(
                    center: coords,
                    annotations: [.pin(coords: coords)]
                ).render()
                return try await write(value: .compound([
                    .image(mapImage),
                    .text("\(coords)"),
                ]))
            case let .ndArrays(ndArrays):
                if ndArrays.contains(where: { !$0.isScalar }) {
                    let image = try await latexRenderer.renderImage(from: latexOf(ndArrays: ndArrays))
                    return try Message(fromImage: image)
                } else {
                    return Message(content: ndArrays.map { "\($0)" }.joined(separator: ", "))
                }
            case let .error(error, errorText: text):
                return Message(embed: Embed(
                    description: ":warning: \(error.map { "\(type(of: $0)): " } ?? "")\(text)",
                    footer: "Check the logs for more details!"
                ))
            case let .files(files):
                return Message(files: files)
            case .attachments(_):
                // TODO: Download attachments and re-attach them as fileuploads
                return try await write(value: .error(nil, errorText: "Cannot write attachments yet!"))
            case let .lazy(wrapper):
                return try await write(value: wrapper.wrappedValue.wrappedValue)
            case let .compound(components):
                return try await withThrowingTaskGroup(of: Message.self) { group in
                    for component in components {
                        group.addTask {
                            try await write(value: component)
                        }
                    }

                    var encoded: [Message] = []
                    for try await message in group {
                        encoded.append(message)
                    }

                    let childComponents = encoded.flatMap(\.components)

                    return Message(
                        content: encoded.compactMap(\.content.nilIfEmpty).joined(separator: "\n"),
                        embeds: encoded.flatMap(\.embeds),
                        files: encoded.flatMap(\.files),
                        tts: false,
                        components: childComponents
                    )
                }
        }
    }
}
