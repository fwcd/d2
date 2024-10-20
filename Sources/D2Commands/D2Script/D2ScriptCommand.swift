import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
import D2MessageIO
import Utils
import D2Permissions
import D2Script

private let log = Logger(label: "D2Commands.D2ScriptCommand")

public class D2ScriptCommand: StringCommand {
    public let info: CommandInfo
    public let name: String
    private let script: D2Script
    private var running = false

    public init(script: D2Script) async throws {
        self.script = script

        let executor = D2ScriptExecutor()
        await executor.run(script)

        let commandNames = executor.topLevelStorage.commandNames
        guard let name = commandNames.first else { throw D2ScriptCommandError.noCommandDefined("Script defines no 'command { ... }' blocks") }
        guard commandNames.count == 1 else { throw D2ScriptCommandError.multipleCommandsDefined("Currently only one command declaration per script is supported") }

        self.name = name
        info = CommandInfo(
            category: .d2script,
            shortDescription: executor.topLevelStorage[string: "description"] ?? "Anonymous D2Script",
            longDescription: "A dynamic D2 script",
            requiredPermissionLevel: executor.topLevelStorage[string: "requiredPermissionLevel"].flatMap { PermissionLevel.of($0) } ?? .vip
        )
    }

    private func addBuiltInFunctions(storage: D2ScriptStorage, input: String, output: any CommandOutput) async {
        // Output to Discord
        storage[function: "output"] = {
            guard let value = $0.first else {
                await output.append(errorText: "output(...) received no arguments")
                return nil
            }
            switch value {
                case let .string(str)?:
                    await output.append(str)
                case let .number(num)?:
                    await output.append(String(num))
                default:
                    await output.append(String(describing: value))
            }
            return nil
        }

        // Print something to the console
        storage[function: "print"] = {
            log.info("\($0.first.flatMap { $0 } ?? .string(""))")
            return nil
        }

        // Perform a synchronous GET request
        storage[function: "httpGet"] = {
            guard case let .string(rawUrl)?? = $0.first else {
                await output.append(errorText: "httpGet(...) received no arguments")
                return nil
            }
            guard let url = URL(string: rawUrl) else {
                await output.append(errorText: "Invalid URL: \(rawUrl)")
                return nil
            }

            do {
                let request = HTTPRequest(url: url)
                return .string(try await request.fetchUTF8().truncated(to: 1000))
            } catch {
                await output.append(error, errorText: "Could not perform HTTP request")
                return nil
            }
        }
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !running else {
            await output.append(errorText: "This command is already running, wait for it to finish")
            return
        }

        running = true

        let executor = D2ScriptExecutor()
        await executor.run(script)
        await addBuiltInFunctions(storage: executor.topLevelStorage, input: input, output: output)

        let task = Task {
            await executor.call(command: self.name)
        }

        do {
            try await Task.sleep(for: .seconds(15))
        } catch {
            log.warning("Could not sleep while executing D2Script: \(error)")
        }

        task.cancel()
        _ = await task.value
        running = false
    }
}
