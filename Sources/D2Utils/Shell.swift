import Foundation

fileprivate let whichURL = URL(fileURLWithPath: "/usr/bin/which")

public struct Shell {
	public init() {}
	
	public func run(_ executable: String, in directory: URL, args: [String], then: @escaping (Process) -> Void) throws {
		let process = Process()
		let path = findPath(of: executable)
		print("Running \(path) in \(directory) with \(args)")
		process.executableURL = URL(fileURLWithPath: path)
		process.currentDirectoryURL = directory
		process.arguments = args
		process.terminationHandler = then
		try process.run()
	}
	
	private func findPath(of executable: String) -> String {
		if executable.contains("/") {
			return executable
		} else {
			let pipe = Pipe()
			
			let process = Process()
			process.executableURL = whichURL
			process.arguments = [executable]
			process.standardOutput = pipe
			
			do {
				try process.run()
				process.waitUntilExit()
			} catch {
				print("Warning: Shell.findPath could launch 'which' to find \(executable)")
				return executable
			}
			
			if let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
				return output.trimmingCharacters(in: .whitespacesAndNewlines)
			} else {
				print("Warning: Shell.findPath could not read 'which' output to find \(executable)")
				return executable
			}
		}
	}
}
