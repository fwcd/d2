import D2Utils

/// Parses a token in UG's markup.
///
/// 1. group: Whether it's a closing 'tag'
/// 1. group: A 'tag' in square parentheses
/// 2. group: Newlines
/// 3. group: Anything else
fileprivate let tokenPattern = try! Regex(from: "(?:\\[(\\/?)([^\\]]+)\\])|([\\r\\n]+)|([^\\r\\n\\[]+)")

/// Parses UG's tab markup.
public struct UltimateGuitarTabParser {
    public init() {}

    enum Token: Equatable {
        case tag(String)
        case closingTag(String)
        case newlines
        case content(String)
    }

    public func parse(tabMarkup: String) throws -> GuitarTabDocument {
        try parseTabDocument(from: TokenIterator(tokenize(tabMarkup: tabMarkup)))
    }

    func tokenize(tabMarkup: String) -> [Token] {
        tokenPattern.allGroups(in: tabMarkup).compactMap {
            let isOpeningTag = $0[1].isEmpty
            if let tag = $0[2].nilIfEmpty {
                return isOpeningTag ? Token.tag(tag) : Token.closingTag(tag)
            } else if !$0[3].isEmpty {
                return Token.newlines
            } else {
                return Token.content($0[4])
            }
        }
    }

    private func skipWhitespace(in tokens: TokenIterator<Token>) {
        skipNewlines(in: tokens)
        while case let .content(content) = tokens.peek() {
            if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                break
            }
            tokens.next()
            skipNewlines(in: tokens)
        }
    }

    private func skipNewlines(in tokens: TokenIterator<Token>) {
        while case .newlines = tokens.peek() {
            tokens.next()
        }
    }

    private func parseTabDocument(from tokens: TokenIterator<Token>) throws -> GuitarTabDocument {
        var sections = [GuitarTabDocument.Section]()
        skipWhitespace(in: tokens)
        while let section = try parseSection(from: tokens) {
            sections.append(section)
            skipWhitespace(in: tokens)
        }
        return .init(sections: sections)
    }

    private func parseSection(from tokens: TokenIterator<Token>) throws -> GuitarTabDocument.Section? {
        var nodes = [GuitarTabDocument.Section.Node]()
        skipWhitespace(in: tokens)
        guard tokens.peek() != nil else { return nil }
        var title = ""
        if case let .tag(t) = tokens.peek(), !tokens.contains(where: { $0 == .closingTag(t) }) {
            title = t
            tokens.next()
        }
        skipWhitespace(in: tokens)
        while let node = try parseNode(from: tokens) {
            nodes.append(node)
        }
        nodes = nodes.reversed().drop {
            guard case let .text(t) = $0 else { return false }
            return t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.reversed()
        return .init(title: title, nodes: nodes)
    }

    private func parseNode(from tokens: TokenIterator<Token>) throws -> GuitarTabDocument.Section.Node? {
        switch tokens.peek() {
            case let .tag(tag)?:
                // Disambiguate between closed tags and new sections
                guard tokens.contains(where: { $0 == .closingTag(tag) }) else { return nil }
                return .tag(tag, try parseTagContents(tag, from: tokens))
            case .content(_)?, .newlines:
                return .text(try parseText(from: tokens))
            default:
                return nil
        }
    }

    private func parseText(from tokens: TokenIterator<Token>) throws -> String {
        var text = ""
        loop:
        while true {
            switch tokens.peek() {
                case .content(let s):
                    text += s
                case .newlines:
                    text.append("\n")
                default:
                    break loop
            }
            tokens.next()
        }
        return text
    }

    private func parseTagContents(_ tag: String, from tokens: TokenIterator<Token>) throws -> [GuitarTabDocument.Section.Node] {
        guard tokens.peek() == .tag(tag) else { throw UltimateGuitarTabParserError.tagMismatch("Expected tag '\(tag)', but got \(tokens.peek().map { "\($0)" } ?? "nil")") }
        tokens.next()
        skipNewlines(in: tokens)
        var nodes = [GuitarTabDocument.Section.Node]()
        while let node = try parseNode(from: tokens) {
            nodes.append(node)
        }
        skipNewlines(in: tokens)
        guard tokens.peek() == .closingTag(tag) else { throw UltimateGuitarTabParserError.tagMismatch("Expected closing tag '\(tag)', but got \(tokens.peek().map { "\($0)" } ?? "nil")") }
        tokens.next()
        return nodes
    }
}
