import D2Utils

fileprivate let sectionTitlePattern = try! Regex(from: "=+\\s*([^=\\s]+)\\s*=+")

public struct MinecraftWikitextDocument {
    public let sections: [Section]
    public let introductionLines: [String]

    public init?(from raw: String) {
        // Parses the sections from raw wikitext

        var sections = [Section]()
        var introductionLines = [String]()
        var currentSection: Section? = nil

        for line in raw.split(separator: "\n").map({ String($0) }) {
            if let parsedTitle = sectionTitlePattern.firstGroups(in: line) {
                if let section = currentSection {
                    sections.append(section)
                }

                currentSection = Section(title: parsedTitle[1], contentLines: [])
            } else if currentSection != nil {
                currentSection!.contentLines.append(line)
            } else {
                introductionLines.append(line)
            }
        }
        
        if let section = currentSection {
            sections.append(section)
        }
        
        self.introductionLines = introductionLines
        self.sections = sections
    }
    
    public struct Section {
        public let title: String
        public fileprivate(set) var contentLines: [String]
    }
}
