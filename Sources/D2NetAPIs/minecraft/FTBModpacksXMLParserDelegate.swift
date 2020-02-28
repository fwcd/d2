import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging
import D2Utils

fileprivate let log = Logger(label: "FTBModpacksXMLParserDelegate")

class FTBModpacksXMLParserDelegate: NSObject, XMLParserDelegate, ThenInitializable {
    private let then: (Result<[FTBModpack], Error>) -> Void
    private var packs: [FTBModpack] = []
    
    required init(then: @escaping (Result<[FTBModpack], Error>) -> Void) {
        self.then = then
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        log.trace("Started \(elementName)")
        if elementName == "modpack" {
            packs.append(FTBModpack(
                author: attributeDict["author"],
                curseProjectId: attributeDict["curseProjectId"].flatMap { Int($0) },
                description: attributeDict["description"],
                dir: attributeDict["dir"],
                image: attributeDict["image"],
                logo: attributeDict["logo"],
                mcVersion: attributeDict["mcVersion"],
                minJRE: attributeDict["minJRE"],
                name: attributeDict["name"],
                oldVersions: attributeDict["oldVersions"].map { $0.split(separator: ";").map { String($0) } },
                repoVersion: attributeDict["repoVersion"],
                serverPack: attributeDict["serverPack"],
                url: attributeDict["url"],
                version: attributeDict["version"]
            ))
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.trace("Ended \(elementName)")
        if elementName == "modpacks" {
            log.trace("Finished parsing modpacks")
            then(.success(packs))
        }
    }
}
