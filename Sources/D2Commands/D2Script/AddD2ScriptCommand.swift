import Logging
import D2MessageIO
import D2Permissions
import Utils
import D2Script

fileprivate let log = Logger(label: "D2Commands.AddD2ScriptCommand")
fileprivate let codePattern = #/(?:`(?:``(?:\w*\n)?)?)?(?<code>[^`]+)`*/#

// TODO: Use code command instead of StringCommand

public class AddD2ScriptCommand: StringCommand {
    public let info = CommandInfo(
        category: .d2script,
        shortDescription: "Adds a D2 command written in D2Script",
        longDescription: "Dynamically adds a D2Script-based command to the command registry at runtime",
        requiredPermissionLevel: .admin
    )
    private let parser = D2ScriptParser()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let code = try? codePattern.firstMatch(in: input)?.code {
            do {
                let command = try D2ScriptCommand(script: try parser.parse(String(code)))
                let name = command.name
                guard !name.contains(" ") else {
                    await output.append(errorText: "Command name '\(name)' may not contain spaces")
                    return
                }

                let registry = context.registry
                registry[name] = command
                await output.append(":ballot_box_with_check: Added/updated command `\(name)`")
            } catch D2ScriptCommandError.noCommandDefined(let msg) {
                await output.append(errorText: "No command defined: \(msg)")
            } catch D2ScriptCommandError.multipleCommandsDefined(let msg) {
                await output.append(errorText: "Multiple commands defined: \(msg)")
            } catch {
                await output.append(error, errorText: "Could not parse code.")
            }
        } else {
            await output.append(errorText: "Did not recognize code. \(info.helpText!)")
        }
    }
}
