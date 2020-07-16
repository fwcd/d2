import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.RegexGenerateCommand")
fileprivate let regexTokens = ["+", "*", "?", "(", ")", "[", "]", "|"]
fileprivate let escapedTokens = regexTokens.map { "\\\($0)" }
fileprivate let regexTokenPattern = try! Regex(from: "\((escapedTokens + ["[^\(escapedTokens.joined())]+"]).joined(separator: "|"))")

fileprivate enum RegexParseError: Error {
    case missingParenthesis(String)
    case invalidCharacterSet
    case missingChoiceBranch(String)
}

fileprivate indirect enum RegexNode: CustomStringConvertible {
    case literal(String)
    case sequence([RegexNode])
    case choice([RegexNode])
    case repeating(RegexNode)
    case option(RegexNode)

    var description: String {
        switch self {
            case .literal(let s): return s
            case .sequence(let s): return "seq(\(s.map(\.description).joined(separator: ", ")))"
            case .choice(let c): return "cho(\(c.map(\.description).joined(separator: ", ")))"
            case .repeating(let r): return "rep(\(r))"
            case .option(let r): return "opt(\(r))"
        }
    }

    static func parse(from s: String) throws -> RegexNode? {
        let tokens = regexTokenPattern.allGroups(in: s).map { $0[0] }
        return try parseChoice(from: TokenIterator(tokens))
    }

    private static func parseChoice(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parseChoice")
        guard let value = try parseSequence(from: tokens) else { return nil }
        var childs = [value]
        while tokens.peek() == "|" {
            tokens.next()
            guard let value = try parseSequence(from: tokens) else { throw RegexParseError.missingChoiceBranch("Missing choice branch after |") }
            childs.append(value)
        }
        return .choice(childs)
    }

    private static func parseSequence(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parseSequence")
        var childs = [RegexNode]()
        while let value = try parsePrimary(from: tokens) {
            childs.append(value)
        }
        return .sequence(childs)
    }

    private static func parsePrimary(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parsePrimary")
        switch tokens.peek() {
            case "(": return try parseParenthesized(from: tokens)
            case "[": return try parseCharacterSet(from: tokens)
            default:
                guard var node = try parseLiteral(from: tokens) else { return nil }
                postfixLoop: while true {
                    switch tokens.peek() {
                        case "*":
                            node = .repeating(node)
                            tokens.next()
                        case "+":
                            node = .sequence([node, .repeating(node)])
                            tokens.next()
                        case "?":
                            node = .option(node)
                            tokens.next()
                        default: break postfixLoop
                    }
                }
                return node
        }
    }

    private static func parseParenthesized(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parseParenthesized")
        guard tokens.peek() == "(" else { return nil }
        tokens.next()
        let inner = try parseChoice(from: tokens) ?? .literal("")
        guard tokens.next() == ")" else { throw RegexParseError.missingParenthesis("Missing ) parenthesis") }
        return inner
    }

    private static func parseCharacterSet(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parseCharacterSet")
        guard tokens.peek() == "[" else { return nil }
        tokens.next()
        guard case let .literal(s)? = try parseChoice(from: tokens) else { throw RegexParseError.invalidCharacterSet }
        guard tokens.next() == "]" else { throw RegexParseError.missingParenthesis("Missing ] parenthesis") }
        return .choice(s.map { .literal(String($0)) })
    }

    private static func parseLiteral(from tokens: TokenIterator<String>) throws -> RegexNode? {
        log.trace("parseLiteral")
        guard !Set(regexTokens).contains(tokens.peek()) else { return nil }
        return tokens.next().map { .literal($0) }
    }
}

public class RegexGenerateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Generates a (somewhat) random string from a regex",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            output.append("\(try RegexNode.parse(from: input))")
        } catch {
            output.append(error, errorText: "Could not parse regex!")
        }
    }
}
