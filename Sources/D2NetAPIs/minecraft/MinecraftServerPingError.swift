public enum MinecraftServerPingError: Error {
    case couldNotDecodeJson(String, any Error)
}
