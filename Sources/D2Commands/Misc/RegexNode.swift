import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.RegexNode")
fileprivate let regexTokens = ["+", "*", "?", "(", ")", "[", "]", "|"]
fileprivate let escapedTokens = regexTokens.map { "\\\($0)" }
fileprivate let regexTokenPattern = try! Regex("\((escapedTokens + ["[^\(escapedTokens.joined())]+"]).joined(separator: "|"))")

/// A custom AST representation of a regular expression.
indirect enum RegexNode: CustomStringConvertible {
    case literal(String)
    case sequence([RegexNode])
    case choice([RegexNode])
    case repetition(RegexNode)
    case option(RegexNode)

    var description: String {
        switch self {
            case .literal(let s): s
            case .sequence(let s): "seq(\(s.map(\.description).joined(separator: ", ")))"
            case .choice(let c): "cho(\(c.map(\.description).joined(separator: ", ")))"
            case .repetition(let r): "rep(\(r))"
            case .option(let r): "opt(\(r))"
        }
    }

    static func parse(from s: String) throws -> RegexNode? {
        let tokens = s.matches(of: regexTokenPattern).map { String($0[0].substring ?? "") }
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
        var child: RegexNode?
        switch tokens.peek() {
            case "(": child = try parseParenthesized(from: tokens)
            case "[": child = try parseCharacterSet(from: tokens)
            default: child = try parseLiteral(from: tokens)
        }

        guard var node = child else { return nil }

        // Parse postfix operators in a loop since recursive-descent
        // does not work well with left-recursion
        postfixLoop:
        while true {
            var pre: RegexNode? = nil
            var inner: RegexNode = node

            // Operator only applies to the last character
            if case let .literal(l) = node, l.count > 1, let c = l.last {
                pre = .literal(String(l.dropLast()))
                inner = .literal(String(c))
            }

            switch tokens.peek() {
                case "*":
                    inner = .repetition(inner)
                    tokens.next()
                case "+":
                    inner = .sequence([inner, .repetition(inner)])
                    tokens.next()
                case "?":
                    inner = .option(inner)
                    tokens.next()
                default: break postfixLoop
            }

            node = pre.map { .sequence([$0, inner]) } ?? inner
        }
        return node
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
