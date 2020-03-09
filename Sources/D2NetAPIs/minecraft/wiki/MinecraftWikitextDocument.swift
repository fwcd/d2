import D2Utils

fileprivate let sectionTitlePattern = try! Regex(from: "=+\\s*([^=\\s]+)\\s*=+")

public struct MinecraftWikitextDocument {
    public let sections: [Section]

    public init?(from raw: String) {
        // Parses the sections from raw wikitext

        var sections = [Section]()
        var currentSection: Section? = nil

        for line in raw.split(separator: "\n").map({ String($0) }) {
            if line.starts(with: "=") {
                if let section = currentSection {
                    sections.append(section)
                }

                guard let parsedTitle = sectionTitlePattern.firstGroups(in: line) else { return nil }
                currentSection = Section(title: parsedTitle[1], contentLines: [])
            } else {
                currentSection?.contentLines.append(line)
            }
        }
        
        if let section = currentSection {
            sections.append(section)
        }
        
        self.sections = sections
    }
    
    public struct Section {
        public let title: String
        public fileprivate(set) var contentLines: [String]
    }
}
