import D2Utils

/// Parses a token in UG's markup.
///
/// 1. group: Whether it's a closing 'tag'
/// 1. group: A 'tag' in square parentheses
/// 2. group: Anything else
fileprivate let tokenPattern = try! Regex(from: "(?:(\\/?)\\[([^\\]]+)\\])|([^\\r\\n]+)")

fileprivate enum Token: Equatable {
    case tag(String)
    case closingTag(String)
    case content(String)
}

/// Parses UG's tab markup.
public struct UltimateGuitarTabParser {
    public init() {}

    public func parse(tabMarkup: String) throws -> GuitarTabDocument {
        try parseTabDocument(from: tokenize(tabMarkup: tabMarkup))
    }

    private func tokenize(tabMarkup: String) -> TokenIterator<Token> {
        TokenIterator(tokenPattern.allGroups(in: tabMarkup).compactMap {
            let isOpeningTag = $0[1].isEmpty
            if let tag = $0[2].nilIfEmpty {
                return isOpeningTag ? Token.tag(tag) : Token.closingTag(tag)
            } else {
                return Token.content($0[3])
            }
        })
    }

    private func skipWhitespace(in tokens: TokenIterator<Token>) {
        while case let .content(content) = tokens.peek() {
            if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tokens.next()
            } else {
                break
            }
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
        guard case let .tag(title) = tokens.peek() else { throw UltimateGuitarTabParserError.tagMismatch("Expected section header tag") }
        tokens.next()
        skipWhitespace(in: tokens)
        while let node = try parseNode(from: tokens) {
            nodes.append(node)
            skipWhitespace(in: tokens)
        }
        return .init(title: title, nodes: nodes)
    }

    private func parseNode(from tokens: TokenIterator<Token>) throws -> GuitarTabDocument.Section.Node? {
        switch tokens.peek() {
            case let .tag(tag)?:
                return .tag(tag, try parseTagContents(tag, from: tokens))
            case let .content(content)?:
                tokens.next()
                return .text(content)
            default:
                return nil
        }
    }

    private func parseTagContents(_ tag: String, from tokens: TokenIterator<Token>) throws -> [GuitarTabDocument.Section.Node] {
        guard tokens.peek() == .tag(tag) else { throw UltimateGuitarTabParserError.tagMismatch("Expected tag '\(tag)', but got \(tokens.peek().map { "\($0)" } ?? "?")") }
        tokens.next()
        var nodes = [GuitarTabDocument.Section.Node]()
        while let node = try parseNode(from: tokens) {
            nodes.append(node)
        }
        guard tokens.peek() == .closingTag(tag) else { throw UltimateGuitarTabParserError.tagMismatch("Expected closing tag '\(tag)', but got \(tokens.peek().map { "\($0)" } ?? "?")") }
        tokens.next()
        return nodes
    }
}
