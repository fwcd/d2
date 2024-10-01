public enum RichValueType: CustomStringConvertible, Hashable {
    case none
    case text
    case image
    case table
    case gif
    case component
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
            case .none: return "none"
            case .text: return "text"
            case .image: return "image"
            case .table: return "table"
            case .gif: return "gif"
            case .component: return "component"
            case .domNode: return "domNode"
            case .urls: return "urls"
            case .code: return "code"
            case .embed: return "embed"
            case .geoCoordinates: return "geoCoordinates"
            case .mentions: return "mentions"
            case .roleMentions: return "roleMentions"
            case .ndArrays: return "ndArrays"
            case .error: return "error"
            case .files: return "files"
            case .attachments: return "attachments"
            case .compound(let values): return "(\(values.map(\.description).joined(separator: " & ")))"
            case .either(let values): return "(\(values.map(\.description).joined(separator: " | ")))"
            case .unknown: return "?"
            case .any: return "any"
        }
    }
}
