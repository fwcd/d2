import Foundation

public struct Shell {
	public init() {}
	
	public func run(_ executable: String, in directory: URL, args: [String], then: @escaping (Process) -> Void) throws {
		let process = Process()
		let path = findPath(of: executable)
		
		print("Running \(path) in \(directory) with \(args)")
		setExecutable(for: process, toPath: path)
		setCurrentDirectory(for: process, toURL: directory)
		process.arguments = args
		process.terminationHandler = then
		
		try execute(process: process)
	}
	
	private func findPath(of executable: String) -> String {
		if executable.contains("/") {
			return executable
		} else {
			let pipe = Pipe()
			
			let process = Process()
			setExecutable(for: process, toPath: "/usr/bin/which")
			process.arguments = [executable]
			process.standardOutput = pipe
			
			do {
				try execute(process: process)
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
	
	private func setExecutable(for process: Process, toPath filePath: String) {
		if #available(macOS 10.13, *) {
			process.executableURL = URL(fileURLWithPath: filePath)
		} else {
			process.launchPath = filePath
		}
	}
	
	private func setCurrentDirectory(for process: Process, toURL url: URL) {
		if #available(macOS 10.13, *) {
			process.currentDirectoryURL = url
		} else {
			process.currentDirectoryPath = url.path
		}
	}
	
	private func execute(process: Process) throws {
		if #available(macOS 10.13, *) {
			try process.run()
		} else {
			process.launch()
		}
	}
}
