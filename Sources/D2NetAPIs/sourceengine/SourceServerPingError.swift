public enum SourceServerPingError: Error {
    case couldNotDecodePacket
    case invalidAddress(String, Int32)
}
