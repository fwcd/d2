#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum DiscordMessageClientError: Error {
    case invalidResponse(HTTPURLResponse?)
}
