import D2MessageIO
import Logging
import D2Permissions
import Utils

private let log = Logger(label: "D2Commands.BFCommand")

public class BFInterpretCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Interprets BF code",
        longDescription: "Asynchronously invokes a Brainf&*k interpreter",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let maxExecutionSeconds: Int
    @Synchronized private var running = false

    public init(maxExecutionSeconds: Int = 3) {
        self.maxExecutionSeconds = maxExecutionSeconds
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !running else {
            await output.append(errorText: "Whoa, not so fast. Wait for the program to finish!")
            return
        }

        running = true

        let task = Task {
            var interpreter = BFInterpreter()
            var response: String

            if let program = (try? bfCodePattern.firstMatch(in: input)).map({ String($0.code) }) {
                do {
                    let output = try interpreter.interpret(program: program)

                    response = "```\n\(output.content)\n```"
                    if output.tooLong {
                        response += "\nYour program's output was too long to display!"
                    }
                } catch BFError.parenthesesMismatch(let msg) {
                    response = "Parentheses mismatch error: `\(msg)`"
                } catch BFError.multiplicationOverflow(let a, let b) {
                    response = "Overflow while multiplying \(a) with \(b)"
                } catch BFError.incrementOverflow(let x) {
                    response = "Overflow while incrementing \(x)"
                } catch BFError.decrementOverflow(let x) {
                    response = "Overflow while decrementing \(x)"
                } catch BFError.addressOverflow(let address) {
                    response = "Overflow while dereferencing address \(address)"
                } catch {
                    response = "Error while executing code: \(error)"
                }
            } else {
                response = "Syntax error"
            }

            if Task.isCancelled {
                log.debug("Cancelled BF task finished running")
                await output.append(errorText: "Your program took longer than \(self.maxExecutionSeconds) seconds. The output was:\n\(response)")
            } else {
                log.debug("BF task finished running")
                await output.append(response)
            }

            running = false
        }

        do {
            try await Task.sleep(for: .seconds(maxExecutionSeconds))
            task.cancel()
        } catch {
            await output.append(error, errorText: "Error while sleeping")
        }
    }
}
