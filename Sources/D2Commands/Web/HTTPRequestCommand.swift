import Utils
import Foundation

public class HTTPRequestCommand: Command {
    public let info: CommandInfo
    public let inputValueType: RichValueType = .urls
    public let outputValueType: RichValueType = .code
    private let method: String

    public init(method: String) {
        info = CommandInfo(
            category: .web,
            shortDescription: "Performs an HTTP \(method) request",
            helpText: "Syntax: [url] [body]?",
            requiredPermissionLevel: .admin
        )
        self.method = method
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let url = (input.asUrls?.first).flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
            await output.append(errorText: "Please enter a valid URL!")
            return
        }
        guard let scheme = url.scheme else {
            await output.append(errorText: "Your URL misses a scheme")
            return
        }
        guard let host = url.host else {
            await output.append(errorText: "Your URL misses a host")
            return
        }
        let port = url.port
        let path = url.path
        let query = Dictionary(uniqueKeysWithValues: url.queryItems?.map { ($0.name, $0.value ?? "") } ?? [])
        let body = (input.asText?.split(separator: " ")[safely: 1]).map(String.init)

        do {
            let request = try HTTPRequest(
                scheme: scheme,
                host: host,
                port: port,
                path: path,
                method: method,
                query: query,
                body: body
            )
            let response = try await request.fetchUTF8().truncated(to: 1500, appending: "...")
            await output.append(.code(response, language: nil))
        } catch {
            await output.append(error, errorText: "Error while constructing or performing request")
        }
    }
}
