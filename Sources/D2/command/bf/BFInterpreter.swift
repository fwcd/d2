/** Dynamically interprets programs written in BF. */
struct BFInterpreter {
	private var ptr: Int = 0
	private var memory = [Int]()
	private(set) var cancelled = false
	
	/** The number in the cell currently pointing to. */
	private var current: Int {
		mutating get {
			let i = index(of: ptr)
			expand(to: i)
			return memory[i]
		}
	}
	private var currentASCII: String {
		mutating get {
			return (current < 0) ? "?" : String(UnicodeScalar(current) ?? "?")
		}
	}
	
	mutating func interpret(program: String) throws -> String {
		var i: String.Index = program.startIndex // The character index in the program
		var output: String = ""
		
		while i >= program.startIndex && i < program.endIndex && !cancelled {
			var c = program[i] // The character at the current index
			switch c {
				case ">": forward()
				case "<": backward()
				case "+": increment()
				case "-": decrement()
				case ".": output += currentASCII
				case ",": break // TODO: Read from some input source
				case "/": multiply(by: 2)
				case "[":
					let startIndex = i
					if current == 0 {
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
					if current != 0 {
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
		
		return output
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
	
	private mutating func increment() {
		expand(to: ptr)
		memory[index(of: ptr)] += 1
	}
	
	private mutating func decrement() {
		expand(to: ptr)
		memory[index(of: ptr)] -= 1
	}
	
	private mutating func multiply(by factor: Int) {
		expand(to: ptr)
		memory[index(of: ptr)] *= factor
	}
	
	private mutating func expand(to address: Int) {
		let i = index(of: address)
		while memory.count <= i {
			memory.append(0)
		}
	}
	
	private func index(of address: Int) -> Int {
		if address >= 0 {
			return address * 2
		} else {
			return (address * -2) - 1
		}
	}
}
