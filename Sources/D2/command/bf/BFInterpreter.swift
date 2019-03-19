fileprivate let maxStringLength = 700

/** Dynamically interprets programs written in BF. */
struct BFInterpreter {
	private var ptr: Int32 = 0
	private var memory = [Int32]()
	private(set) var cancelled = false
	
	mutating func interpret(program: String) throws -> BFOutput {
		var i: String.Index = program.startIndex // The character index in the program
		var output: String = ""
		
		while i >= program.startIndex && i < program.endIndex && !cancelled {
			var c = program[i] // The character at the current index
			switch c {
				case ">": forward()
				case "<": backward()
				case "+": try increment()
				case "-": try decrement()
				case ".":
					output += try currentASCII()
					if output.count > maxStringLength {
						return BFOutput(content: "\(output)...", tooLong: true)
					}
				case ",": break // TODO: Read from some input source
				case "/": try multiply(by: 2)
				case "[":
					let startIndex = i
					if try current() == 0 {
						// Seek to the first index AFTER the closing parenthesis
						var stack = 0
						repeat {
							switch c {
								case "[": stack += 1
								case "]": stack -= 1
								default: break
							}
							
							if i >= program.endIndex {
								throw BFError.parenthesesMismatch("Out of bounds while searching for closing parenthesis to [ at \(program.distance(from: program.startIndex, to: startIndex))")
							}
							
							i = program.index(after: i)
							
							if i < program.endIndex {
								c = program[i]
							}
						} while stack > 0 && !cancelled
					}
				case "]":
					let startIndex = i
					if try current() != 0 {
						// Seek to the last index BEFORE the closing parenthesis
						var stack = 0
						repeat {
							switch c {
								case "[": stack -= 1
								case "]": stack += 1
								default: break
							}
							
							if i <= program.startIndex {
								throw BFError.parenthesesMismatch("Out of bounds while searching for opening parenthesis to ] at \(startIndex)")
							}
							
							i = program.index(before: i)
							
							if i >= program.startIndex {
								c = program[i]
							}
						} while stack > 0 && !cancelled
					}
				default: break
			}
			
			if i < program.endIndex {
				i = program.index(after: i)
			}
		}
		
		return BFOutput(content: output, tooLong: false)
	}
	
	mutating func cancel() {
		cancelled = true
	}
	
	private mutating func forward() {
		ptr += 1
	}
	
	private mutating func backward() {
		ptr -= 1
	}
	
	private mutating func increment() throws {
		try expand(to: ptr)
		let value = try current()
		let (successor, didOverflow) = value.addingReportingOverflow(1)
		
		if didOverflow {
			throw BFError.incrementOverflow(value)
		} else {
			memory[try index(of: ptr)] = successor
		}
	}
	
	private mutating func decrement() throws {
		try expand(to: ptr)
		let value = try current()
		let (predecessor, didOverflow) = value.subtractingReportingOverflow(1)
		
		if didOverflow {
			throw BFError.decrementOverflow(value)
		} else {
			memory[try index(of: ptr)] = predecessor
		}
	}
	
	private mutating func multiply(by factor: Int32) throws {
		try expand(to: ptr)
		let value = try current()
		let (product, didOverflow) = value.multipliedReportingOverflow(by: factor)
		
		if didOverflow {
			throw BFError.multiplicationOverflow(value, factor)
		} else {
			memory[try index(of: ptr)] = product
		}
	}
	
	/** The number in the cell currently pointing to. */
	private mutating func current() throws -> Int32 {
		try expand(to: ptr)
		return memory[try index(of: ptr)]
	}
	
	private mutating func currentASCII() throws -> String {
		let value = try current()
		return (value < 0) ? "?" : String(UnicodeScalar(Int(value)) ?? "?")
	}
	
	private mutating func expand(to address: Int32) throws {
		let i = try index(of: address)
		while memory.count <= i {
			memory.append(0)
		}
	}
	
	private func index(of address: Int32) throws -> Int {
		var result: (Int32, Bool)
		
		if address >= 0 {
			result = address.multipliedReportingOverflow(by: 2)
		} else {
			result = address.multipliedReportingOverflow(by: -2)
			
			if !result.1 { // If it did not overflow
				result = result.0.subtractingReportingOverflow(1)
			}
		}
		
		let (i, didOverflow) = result
		
		if didOverflow {
			throw BFError.addressOverflow(address)
		} else {
			return Int(i)
		}
	}
}
