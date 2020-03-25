import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging
import D2Utils

fileprivate let log = Logger(label: "D2NetAPIs.FTBModpacksXMLParserDelegate")
fileprivate let baseURL = "https://ftb.forgecdn.net/FTB2"

class FTBModpacksXMLParserDelegate: NSObject, XMLParserDelegate {
    private let then: (Result<[FTBModpack], Error>) -> Void
    private var packs: [FTBModpack] = []
    
    init(then: @escaping (Result<[FTBModpack], Error>) -> Void) {
        self.then = then
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        log.trace("Started \(elementName)")
        if elementName == "modpack" {
            let packUrl = attributeDict["dir"].flatMap { dir in 
                          attributeDict["repoVersion"].map { repoVersion in "\(baseURL)/modpacks/\(dir)/\(repoVersion)" } }
            packs.append(FTBModpack(
                author: attributeDict["author"],
                curseProjectId: attributeDict["curseProjectId"].flatMap { Int($0) },
                description: attributeDict["description"],
                downloadUrl: attributeDict["url"].flatMap { path in packUrl.map { "\($0)/\(path)" } },
                imageUrl: attributeDict["image"].map { path in "\(baseURL)/static/\(path)" },
                logoUrl: attributeDict["logo"].map { path in "\(baseURL)/static/\(path)" },
                mcVersion: attributeDict["mcVersion"],
                minJRE: attributeDict["minJRE"],
                name: attributeDict["name"],
                oldVersions: attributeDict["oldVersions"].map { $0.split(separator: ";").map { String($0) } },
                serverDownloadUrl: attributeDict["serverPack"].flatMap { path in packUrl.map { "\($0)/\(path)" } },
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
