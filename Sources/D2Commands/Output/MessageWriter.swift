import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.MessageWriter")

/// Writes rich values into MessageIO messages (e.g. for use with Discord).
public struct MessageWriter {
    private let latexRenderer = LatexRenderer()

    public init() {}

    public func write(value: RichValue) -> Promise<Message, any Error> {
        switch value {
            case .none:
                return Promise(Message(content: ""))
            case let .text(txt):
                if txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return Promise(.failure(MessageWriterError.emptyMessage))
                }
                return Promise(Message(content: txt))
            case let .mentions(users):
                return Promise(Message(content: users.map { "<@\($0.id)>" }.joined(separator: " ")))
            case let .roleMentions(roles):
                return Promise(Message(content: roles.map { "<@\($0)>" }.joined(separator: " ")))
            case let .image(img):
                return Promise.catching { try Message(fromImage: img) }
            case let .table(rows):
                return Promise(Message(content: """
                    ```
                    \(rows.map { "(\($0.joined(separator: ", ")))" }.joined(separator: "\n"))
                    ```
                    """))
            case let .urls(urls):
                return Promise(Message(content: urls.map(\.absoluteString).joined(separator: " ")))
            case let .gif(gif):
                return Promise.catching { try Message(fromGif: gif) }
            case let .component(component):
                return Promise(Message(components: [.actionRow(.init(components: [component]))]))
            case let .domNode(node):
                return Promise.catching { .code(try node.outerHtml(), language: "html") }.then(write(value:))
            case let .code(code, language: lang):
                return Promise(Message(content: """
                    ```\(lang ?? "")
                    \(code)
                    ```
                    """))
            case let .embed(embed):
                return Promise(Message(embed: embed))
            case let .geoCoordinates(geo):
                return Promise(Message(content: "Latitude: \(geo.latitude), Longitude: \(geo.longitude)"))
            case let .ndArrays(ndArrays):
                if ndArrays.contains(where: { !$0.isScalar }) {
                    return latexRenderer.renderImage(from: latexOf(ndArrays: ndArrays))
                        .mapCatching { try Message(fromImage: $0) }
                } else {
                    return Promise(Message(content: ndArrays.map { "\($0)" }.joined(separator: ", ")))
                }
            case let .error(error, errorText: text):
                return Promise(Message(embed: Embed(
                    description: ":warning: \(error.map { "\(type(of: $0)): " } ?? "")\(text)",
                    footer: Embed.Footer(text: "Check the logs for more details!")
                )))
            case let .files(files):
                return Promise(Message(files: files))
            case .attachments(_):
                // TODO: Download attachments and re-attach them as fileuploads
                return write(value: .error(nil, errorText: "Cannot write attachments yet!"))
            case let .lazy(wrapper):
                return write(value: wrapper.wrappedValue)
            case let .compound(components):
                return all(promises: components.map { write(value: $0) }).map { encoded in
                    let childComponents = encoded.flatMap { $0.components.flatMap(\.primitiveChildren) }
                    return Message(
                        content: encoded.compactMap(\.content.nilIfEmpty).joined(separator: "\n"),
                        embeds: encoded.flatMap(\.embeds),
                        files: encoded.flatMap(\.files),
                        tts: false,
                        components: childComponents.isEmpty ? [] : [.actionRow(.init(
                            components: childComponents
                        ))]
                    )
                }
        }
    }
}
