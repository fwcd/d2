import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Utils

// Matches the contents of an HTML paragraph
fileprivate let htmlParagraphPattern = try! Regex(from: "(?:<[pP]>)?\\s*([\\s\\S]*)\\s*(?:</[pP]>)")

class MDBXMLParserDelegate: NSObject, XMLParserDelegate {
    private let then: (Result<[MDBModule], any Error>) -> Void

    private var modules = [MDBModule]()

    private var parsingName = false
    private var parsingStudyPrograms = false
    private var parsingCategories = false

    private var stackHeight = 0
    private var currentKey: String? = nil
    private var currentModule: MDBModule? = nil
    private var currentCharacters = ""
    private var hasErrored = false

    public init(then: @escaping (Result<[MDBModule], any Error>) -> Void) {
        self.then = then
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        stackHeight += 1
        switch elementName {
            case "modul": currentModule = MDBModule()
            case "modulname": parsingName = true
            case "studiengaenge": parsingStudyPrograms = true
            case "kategorien": parsingCategories = true
            case "kategorie": currentKey = attributeDict["key"]
            case "studiengang": currentKey = attributeDict["key"]
            default: break
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters += string
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let str = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)

        if currentModule != nil {
            if parsingName {
                switch elementName {
                    case "modulname": parsingName = false
                    case "deutsch": currentModule!.nameGerman = str
                    case "englisch": currentModule!.nameEnglish = str
                    default: break
                }
            } else if parsingStudyPrograms {
                switch elementName {
                    case "studiengaenge": parsingStudyPrograms = false
                    case "studiengang": currentModule!.studyPrograms.append(MDBStudyProgram(key: currentKey, name: str))
                    default: break
                }
            } else if parsingCategories {
                switch elementName {
                    case "kategorien": parsingCategories = false
                    case "kategorie": currentModule!.categories.append(MDBCategory(key: currentKey, name: str))
                    default: break
                }
            } else {
                switch elementName {
                    case "code": currentModule!.code = str
                    case "modulcode": currentModule!.code = str
                    case "url": currentModule!.url = str
                    case "verantwortlich": currentModule!.person = str
                    case "ectspunkte": currentModule!.ects = UInt(str)
                    case "workload": currentModule!.workload = str
                    case "lehrsprache": currentModule!.teachingLanguage = str
                    case "kurzfassung":
                        if let contents = (htmlParagraphPattern.firstGroups(in: str).flatMap { $0[safely: 1] }) {
                            currentModule!.summary = contents
                        } else {
                            currentModule!.summary = str
                        }
                    case "lernziele": currentModule!.objectives = str
                    case "lehrinhalte": currentModule!.contents = str
                    case "voraussetzungen": currentModule!.prerequisites = str
                    case "pruefungsleistung": currentModule!.exam = str
                    case "lehrmethoden": currentModule!.methods = str
                    case "literatur": currentModule!.literature = str
                    case "verweise": currentModule!.references = str
                    case "kommentar": currentModule!.comment = str
                    case "praesenz": currentModule!.presence = str
                    case "dauer": currentModule!.duration = UInt(str)
                    case "turnus": currentModule!.cycle = str
                    case "modul":
                        modules.append(currentModule!)
                        currentModule = nil
                    default: break
                }
            }
        }

        currentCharacters = ""
        stackHeight -= 1

        if stackHeight <= 0 {
            then(.success(modules))
        }
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        if !hasErrored {
            then(.failure(parseError))
            hasErrored = true
        }
    }

    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: any Error) {
        if !hasErrored {
            then(.failure(validationError))
            hasErrored = true
        }
    }
}
