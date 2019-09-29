public enum RichValueType {
    case none
    case text
    case image
    case gif
    case code
    case embed
    case files
    case compound([RichValueType])
    case unknown
}
