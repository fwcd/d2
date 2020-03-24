public enum MinecraftServerPingError: Error {
    case couldNotDecodeJson(String, Error)
}
