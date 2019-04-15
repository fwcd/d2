import Foundation

/** A wrapper that simplifies the creation of subprocesses. */
public struct Shell {
	public init() {}
	
	public func newProcess(_ executable: String, in directory: URL? = nil, args: [String]? = nil, withPipedOutput: Bool = false, then: ((Process) -> Void)? = nil) -> (Pipe?, Process) {
		var pipe: Pipe? = nil
		let process = Process()
		let path = findPath(of: executable)
		
		setExecutable(for: process, toPath: path)
		
		if let dirURL = directory {
			setCurrentDirectory(for: process, toURL: dirURL)
		}
		
		process.arguments = args
		process.terminationHandler = then
		
		if withPipedOutput {
			pipe = Pipe()
			process.standardOutput = pipe
		}
		
		return (pipe, process)
	}
	
	/** Synchronously runs the executable and returns the standard output. */
	@discardableResult
	public func runSync(_ executable: String, in directory: URL? = nil, args: [String]? = nil, then: ((Process) -> Void)? = nil) throws -> String? {
		let (pipe, process) = newProcess(executable, in: directory, args: args, withPipedOutput: true, then: then)
		
		try execute(process: process)
		process.waitUntilExit()
		
		return String(data: pipe!.fileHandleForReading.availableData, encoding: .utf8)
	}
	
	public func run(_ executable: String, in directory: URL? = nil, args: [String]? = nil, then: ((Process) -> Void)? = nil) throws {
		try execute(process: newProcess(executable, in: directory, args: args, then: then).1)
	}
	
	private func findPath(of executable: String) -> String {
		if executable.contains("/") {
			return executable
		} else {
			// Find executable using 'which'. This code fragment explicitly
			// does not invoke 'runSync' to avoid infinite recursion.
			
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
	
	public func execute(process: Process) throws {
		if #available(macOS 10.13, *) {
			try process.run()
		} else {
			process.launch()
		}
	}
}
