import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging

private let log = Logger(label: "D2NetAPIs.WolframAlphaParserDelegate")

class WolframAlphaParserDelegate: NSObject, XMLParserDelegate {
    let continuation: CheckedContinuation<WolframAlphaOutput, any Error>

    // Current parser state
    private var result = WolframAlphaOutput()
    private var pod = WolframAlphaPod()
    private var subpod = WolframAlphaSubpod()
    private var state = WolframAlphaState()
    private var image = WolframAlphaImage()
    private var link = WolframAlphaLink()
    private var info = WolframAlphaInfo()
    private var parsingInfo = false

    private var currentCharacters = ""
    private var hasErrored = false

    init(continuation: CheckedContinuation<WolframAlphaOutput, any Error>) {
        self.continuation = continuation
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        log.trace("Entering \(elementName): \(attributeDict)")
        switch elementName {
            case "queryresult":
                result = WolframAlphaOutput()
                result.success = attributeDict["success"].flatMap { parseBool(from: $0) }
                result.error = attributeDict["error"].flatMap { parseBool(from: $0) }
                result.numpods = attributeDict["numpods"].flatMap { Int($0) }
                result.timing = attributeDict["timing"].flatMap { Double($0) }
            case "pod":
                pod = WolframAlphaPod()
                pod.title = attributeDict["title"]
                pod.scanner = attributeDict["scanner"]
                pod.id = attributeDict["id"]
                pod.position = attributeDict["position"].flatMap { Int($0) }
                pod.error = attributeDict["error"].flatMap { parseBool(from: $0) }
                pod.numsubpods = attributeDict["numsubpods"].flatMap { Int($0) }
            case "subpod":
                subpod = WolframAlphaSubpod()
                subpod.title = attributeDict["title"]
            case "state":
                state = WolframAlphaState()
                state.name = attributeDict["name"]
                state.input = attributeDict["input"]
            case "img":
                image = WolframAlphaImage()
                image.src = attributeDict["src"]
                image.alt = attributeDict["alt"]
                image.title = attributeDict["title"]
                image.width = attributeDict["width"].flatMap { Int($0) }
                image.height = attributeDict["height"].flatMap { Int($0) }
            case "link":
                link = WolframAlphaLink()
                link.url = attributeDict["url"]
                link.text = attributeDict["text"]
                link.title = attributeDict["title"]
                parsingInfo = true
            case "info":
                info = WolframAlphaInfo()
                info.text = attributeDict["text"]
            default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.trace("Exiting \(elementName)")
        if elementName == "queryresult" {
            log.trace("Ending parsing")
            continuation.resume(with: .success(result))
        } else {
            switch elementName {
                case "pod": result.pods.append(pod)
                case "subpod": pod.subpods.append(subpod)
                case "state": pod.states.append(state)
                case "plaintext": subpod.plaintext = currentCharacters
                case "info":
                    pod.infos.append(info)
                    parsingInfo = false
                case "link":
                    if parsingInfo {
                        info.links.append(link)
                    }
                case "img":
                    if parsingInfo {
                        info.img = image
                    } else {
                        subpod.img = image
                    }
                default: break
            }
        }

        currentCharacters = ""
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        log.warning("\(parseError)")
        if !hasErrored {
            continuation.resume(with: .failure(parseError))
            hasErrored = true
        }
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: any Error) {
        log.warning("\(validationError)")
        if !hasErrored {
            continuation.resume(with: .failure(validationError))
            hasErrored = true
        }
    }

    private func parseBool(from str: String) -> Bool? {
        switch str.lowercased() {
            case "true": true
            case "false": false
            default: nil
        }
    }
}
