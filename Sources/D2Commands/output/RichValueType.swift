public enum RichValueType: CustomStringConvertible {
    case none
    case text
    case image
    case table
    case gif
    case domNode
    case urls
    case code
    case embed
    case mentions
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
            case .domNode: return "domNode"
            case .urls: return "urls"
            case .code: return "code"
            case .embed: return "embed"
            case .mentions: return "mentions"
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
