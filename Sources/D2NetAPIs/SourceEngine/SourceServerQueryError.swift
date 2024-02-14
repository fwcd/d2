public enum SourceServerQueryError: Error {
    case noResponse
    case invalidHeader
    case couldNotDecodePacket
    case invalidAddress(String, Int32)
}
