public enum RichValueType: CustomStringConvertible, Hashable, Sendable {
    case none
    case text
    case image
    case table
    case gif
    case components
    case domNode
    case urls
    case code
    case embed
    case geoCoordinates
    case mentions
    case roleMentions
    case ndArrays
    case error
    case files
    case attachments
    case compound([RichValueType])
    case either([RichValueType])
    case unknown
    case any

    public var description: String {
        switch self {
            case .none: "none"
            case .text: "text"
            case .image: "image"
            case .table: "table"
            case .gif: "gif"
            case .components: "components"
            case .domNode: "domNode"
            case .urls: "urls"
            case .code: "code"
            case .embed: "embed"
            case .geoCoordinates: "geoCoordinates"
            case .mentions: "mentions"
            case .roleMentions: "roleMentions"
            case .ndArrays: "ndArrays"
            case .error: "error"
            case .files: "files"
            case .attachments: "attachments"
            case .compound(let values): "(\(values.map(\.description).joined(separator: " & ")))"
            case .either(let values): "(\(values.map(\.description).joined(separator: " | ")))"
            case .unknown: "?"
            case .any: "any"
        }
    }
}
