import Logging
import D2MessageIO
import D2Permissions
import D2Utils
import Dispatch

fileprivate let log = Logger(label: "D2Commands.MaximaCommand")
fileprivate let maxExecutionSeconds = 5
fileprivate let clearedInputChars = try! Regex(from: "\\|&,;")
fileprivate let maximaOutputPattern = try! Regex(from: "\\(%i1\\)\\s*([\\s\\S]+)\\(%i2\\)")

public class MaximaCommand: StringCommand {
	public let info = CommandInfo(
		category: .math,
		shortDescription: "Transforms and solves math expressions using Maxima",
		longDescription: "Runs a command with Maxima and outputs the result using a LaTeX renderer",
		requiredPermissionLevel: .admin
	)
	public let outputValueType: RichValueType = .image
	private let latexRenderer: LatexRenderer?
	private var running = false

	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.error("Could not initialize latex renderer for MaximaCommand: \(error)")
		}
	}

	public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
		guard !running else {
			output.append(errorText: "Wait for the Maxima command to finish")
			return
		}

		let processedInput: String = clearedInputChars.replace(in: input, with: "")
		let maximaInput: String = (latexRenderer == nil) ? "\(processedInput);" : "tex(\(processedInput))$"

		running = true
		let semaphore = DispatchSemaphore(value: 0)
		let queue = DispatchQueue(label: "Maxima runner")
		let shell = Shell()
		let (pipe, process) = shell.newProcess("maxima", args: ["-q", "-r", maximaInput], withPipedOutput: true)

		let task = DispatchWorkItem {
			do {
				try shell.execute(process: process)
				process.waitUntilExit()

				guard let result = String(data: pipe!.fileHandleForReading.availableData, encoding: .utf8) else {
					output.append(errorText: "No output was generated by Maxima")
					return
				}

				if let renderer = self.latexRenderer, let maximaOutput = maximaOutputPattern.firstGroups(in: result) {
					// Parse and render TeX output
					let tex = maximaOutput[1]
					// output.append("`\(tex)`")
					renderLatexImage(with: renderer, from: tex, to: output).listenOrLogError {
						self.running = false
						semaphore.signal()
					}
				} else {
					// Render text output directly instead
					output.append(.code(result, language: nil))
					self.running = false
					semaphore.signal()
				}
			} catch {
				log.warning("An error occurred in MaximaCommand: \(error)")
				self.running = false
				semaphore.signal()
			}
		}

		let timeout = DispatchTime.now() + .seconds(maxExecutionSeconds)
		queue.async(execute: task)

		DispatchQueue.global(qos: .userInitiated).async {
			let result = semaphore.wait(timeout: timeout)

			if result == .timedOut && process.isRunning {
				output.append(errorText: "Maxima took longer than \(maxExecutionSeconds) seconds")
				process.terminate()
			}

			self.running = false

			// Wait one additional second for the process and then kill it if it has not terminated yet
			DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1), execute: {
				if process.isRunning {
					do {
						try shell.outputSync(for: "kill", args: ["-9", String(process.processIdentifier)])
						log.debug("Killed maxima process")
					} catch {
						log.error("Killing maxima process failed, try to manually kill the process: kill -9 \(process.processIdentifier)")
					}
				}
			})
		}
	}
}
