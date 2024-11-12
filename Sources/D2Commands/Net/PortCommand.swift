import D2Datasets
import D2MessageIO

public class PortCommand: StringCommand {
    public let info = CommandInfo(
        category: .net,
        shortDescription: "Looks up a standard TCP/UDP port assignment",
        helpText: "Syntax: [port number]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let port = Int(input) else {
            await output.append(errorText: "Not a port number: \(input)")
            return
        }
        guard let services = Ports.values[port], !services.isEmpty else {
            await output.append(errorText: "Unknown port \(input)")
            return
        }

        await output.append(Embed(
            title: "Port \(port)",
            fields: services.map { service in
                Embed.Field(
                    name: "\(service.port)/\([service.tcp ? "tcp" : nil, service.udp ? "udp" : nil].compactMap { $0 }.joined(separator: ","))",
                    value: service.description
                )
            }
        ))
    }
}
