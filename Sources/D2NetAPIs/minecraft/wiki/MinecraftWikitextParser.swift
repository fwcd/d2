import Logging
import D2Utils

fileprivate let log = Logger(label: "MinecraftWikitextParser")
fileprivate let tokenPattern = try! Regex(from: "\\s*([\\w\\s\\.]+|=+|\\[+|\\]+|\\{+|\\}+|\\|+)\\s*")

/// A basic recursive-descent parser for a subset of wikitext.
public struct MinecraftWikitextParser {
    public init() {}
    
    public func parse(raw: String) throws -> MinecraftWikitextDocument {
        try parseWikitext(from: TokenIterator(tokenize(raw: raw)))
    }
    
    private func tokenize(raw: String) -> [String] {
        tokenPattern.allGroups(in: raw).map { $0[1] }
    }

    private func parseWikitext(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument {
        log.trace("Parsing wikitext")
        var sections = [MinecraftWikitextDocument.Section]()
        while let section = try parseSection(from: tokens) {
            sections.append(section)
        }
        return MinecraftWikitextDocument(sections: sections)
    }
    
    private func parseSection(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section? {
        log.trace("Parsing section")
        let title = try parseTitle(from: tokens)
        let nodes = try parseNodes(from: tokens)
        guard title != nil || !nodes.isEmpty else { return nil }
        return .init(title: title, content: nodes)
    }
    
    private func parseNodes(from tokens: TokenIterator<String>) throws -> [MinecraftWikitextDocument.Section.Node] {
        log.trace("Parsing nodes")
        var nodes = [MinecraftWikitextDocument.Section.Node]()
        while let node = try parseNode(from: tokens) {
            nodes.append(node)
        }
        return nodes
    }
    
    private func parseNode(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section.Node? {
        log.trace("Parsing node")
        guard let token = tokens.peek() else { return nil }
        if token == "[[" {
            return try parseLink(from: tokens)
        } else if token == "{{" {
            return try parseTemplate(from: tokens)
        } else if token.first.map({ $0.isLetter || $0.isNumber }) ?? false {
            return try parseText(from: tokens)
        } else {
            return nil
        }
    }
    
    private func parseLink(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section.Node {
        log.trace("Parsing link")
        guard let opening = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected opening [[") } 
        guard opening == "[[" else { throw MinecraftWikitextParseError.unexpectedToken("Expected opening [[, but got \(opening)") }
        guard let link = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected link") }
        guard let closing = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected closing ]]") }
        guard closing == "]]" else { throw MinecraftWikitextParseError.unexpectedToken("Expected closing ]], but got \(closing)") }
        return .link(link)
    }
    
    private func parseTemplate(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section.Node {
        log.trace("Parsing template")
        guard let opening = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected opening {{") } 
        guard opening == "{{" else { throw MinecraftWikitextParseError.unexpectedToken("Expected opening {{, but got \(opening)") }
        guard let name = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected template title") }
        var params = [MinecraftWikitextDocument.Section.Node.TemplateParameter]()
        while tokens.peek() == "|" {
            tokens.next()
            params.append(try parseTemplateParameter(from: tokens))
        }
        guard let closing = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected closing }}") }
        guard closing == "}}" else { throw MinecraftWikitextParseError.unexpectedToken("Expected closing }}, but got \(closing)") }
        return .template(name, params)
    }
    
    private func parseTemplateParameter(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section.Node.TemplateParameter {
        log.trace("Parsing template parameter")
        if let key = parseTemplateParameterKey(from: tokens) {
            return .keyValue(key, try parseNodes(from: tokens))
        } else {
            return .value(try parseNodes(from: tokens))
        }
    }
    
    private func parseTemplateParameterKey(from tokens: TokenIterator<String>) -> String? {
        log.trace("Parsing template parameter key")
        guard let key = tokens.peek(), key.first.map({ $0.isLetter || $0.isNumber }) ?? false else { return nil }
        guard tokens.peek(2) == "=" else { return nil }
        tokens.next()
        tokens.next()
        return key
    }
    
    private func parseText(from tokens: TokenIterator<String>) throws -> MinecraftWikitextDocument.Section.Node {
        log.trace("Parsing text")
        guard let text = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected text") }
        return .text(text)
    }
    
    private func parseTitle(from tokens: TokenIterator<String>) throws -> String? {
        log.trace("Parsing title")
        guard let opening = tokens.peek(), opening.starts(with: "=") else { return nil }
        tokens.next()
        guard let title = tokens.next() else { throw MinecraftWikitextParseError.noMoreTokens("Expected title") }
        guard tokens.next() == opening else { throw MinecraftWikitextParseError.unexpectedToken("Closing =s do not match opening =s (\(opening))") }
        return title
    }
}
