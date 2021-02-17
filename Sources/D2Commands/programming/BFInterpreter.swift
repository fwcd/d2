fileprivate let maxStringLength = 700

/// Dynamically interprets programs written in BF.
struct BFInterpreter {
    private var ptr: Int32 = 0
    private var memory = [Int32]()
    private(set) var cancelled = false

    /// Runs a BF program.
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
                        // Seek to the closing parenthesis
                        var stack = 0
                        while stack >= 0 && !cancelled {
                            i = program.index(after: i)

                            if i >= program.endIndex {
                                throw BFError.parenthesesMismatch("Out of bounds while searching for closing parenthesis to [ at \(program.distance(from: program.startIndex, to: startIndex))")
                            }

                            c = program[i]

                            switch c {
                                case "[": stack += 1
                                case "]": stack -= 1
                                default: break
                            }
                        }
                    }
                case "]":
                    let startIndex = i
                    if try current() != 0 {
                        // Seek to the last index BEFORE the closing parenthesis
                        var stack = 0
                        while stack >= 0 && !cancelled {
                            i = program.index(before: i)

                            if i < program.startIndex {
                                throw BFError.parenthesesMismatch("Out of bounds while searching for opening parenthesis to ] at \(program.distance(from: program.startIndex, to: startIndex))")
                            }

                            c = program[i]

                            switch c {
                                case "[": stack -= 1
                                case "]": stack += 1
                                default: break
                            }
                        }
                    }
                default: break
            }

            if i < program.endIndex {
                i = program.index(after: i)
            }
        }

        return BFOutput(content: output, tooLong: false)
    }

    /// Requests cancellation.
    mutating func cancel() {
        cancelled = true
    }

    /// Increments the pointer.
    private mutating func forward() {
        ptr += 1
    }

    /// Decrements the pointer.
    private mutating func backward() {
        ptr -= 1
    }

    /// Increments the current cell.
    private mutating func increment() throws {
        try expand(to: ptr)
        let value = try current()
        let (successor, didOverflow) = value.addingReportingOverflow(1)

        guard !didOverflow else { throw BFError.incrementOverflow(value) }
        try write(successor)
    }

    /// Decrements the current cell.
    private mutating func decrement() throws {
        try expand(to: ptr)
        let value = try current()
        let (predecessor, didOverflow) = value.subtractingReportingOverflow(1)

        guard !didOverflow else { throw BFError.decrementOverflow(value) }
        try write(predecessor)
    }

    /// Multiplies the current cell by a factor.
    private mutating func multiply(by factor: Int32) throws {
        try expand(to: ptr)
        let value = try current()
        let (product, didOverflow) = value.multipliedReportingOverflow(by: factor)

        guard !didOverflow else { throw BFError.multiplicationOverflow(value, factor) }
        try write(product)
    }

    /// Writes a value to the current cell.
    private mutating func write(_ value: Int32) throws {
        memory[try index(of: ptr)] = value
    }

    /// The number in the cell currently pointing to.
    private mutating func current() throws -> Int32 {
        try expand(to: ptr)
        return memory[try index(of: ptr)]
    }

    /// Reads the current cell, interpreting it as a character.
    private mutating func currentASCII() throws -> String {
        let value = try current()
        return (value < 0) ? "?" : String(Unicode.Scalar(Int(value)) ?? "?")
    }

    /// Ensures that the memory is large enough to contain the given address.
    private mutating func expand(to address: Int32) throws {
        let i = try index(of: address)
        while memory.count <= i {
            memory.append(0)
        }
    }

    /// Converts the (possibly negative) address to a not-negative memory array index.
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
