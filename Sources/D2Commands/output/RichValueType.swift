public enum RichValueType {
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
    case unknown
    case any
}
