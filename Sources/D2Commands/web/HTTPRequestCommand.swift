import D2Utils
import Foundation

public class HTTPRequestCommand: StringCommand {
    public let info: CommandInfo
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

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let split = input.split(separator: " ").map { String($0) }
        guard let url = URLComponents(string: split[0]) else {
            output.append(errorText: "Please enter a valid URL!")
            return
        }
        guard let scheme = url.scheme else {
            output.append(errorText: "Your URL misses a scheme")
            return
        }
        guard let host = url.host else {
            output.append(errorText: "Your URL misses a host")
            return
        }
        let port = url.port
        let path = url.path
        let query = Dictionary(uniqueKeysWithValues: url.queryItems?.map { ($0.name, $0.value ?? "") } ?? [])
        let body = split[safely: 1]

        do {
            try HTTPRequest(
                scheme: scheme,
                host: host,
                port: port,
                path: path,
                method: method,
                query: query,
                body: body
            ).fetchUTF8Async {
                do {
                    let response = try $0.get().truncate(1500, appending: "...")
                    output.append(.code(response, language: nil))
                } catch {
                    output.append(error, errorText: "Error while performing request")
                }
            }
        } catch {
            output.append(error, errorText: "Could not create request")
        }
    }
}
