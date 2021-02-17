import Foundation
import Utils

// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/master/Akinator.Api.Net/AkinatorClient.cs
// MIT-licensed, Copyright (c) 2019 Jannik

fileprivate let sessionPattern = try! Regex(from: "var uid_ext_session = '([^']*)'\\;\\s*.*var frontaddr = '(.*)'\\;")
fileprivate let startGamePattern = try! Regex(from: "^jQuery3410014644797238627216_\\d+\\((.+)\\)$")

public struct AkinatorSession {
    private let session: String
    private let signature: String

    private init(session: String, signature: String) {
        self.session = session
        self.signature = signature
    }

    private struct ApiKey {
        let uidExtSession: String
        let frontaddr: String
    }

    public static func create() -> Promise<(AkinatorSession, AkinatorResponse.Question), Error> {
        let time = Int64(Date().timeIntervalSince1970 * 1000)
        return AkinatorServersQuery().perform()
            .thenCatching {
                guard let url = $0.parameters.instance.first?.urlBaseWs else { throw AkinatorError.noServersFound }
                return getApiKey().map { ($0, url) }
            }
            .mapCatching { (key: ApiKey, url: URL) in try HTTPRequest(
                host: "en.akinator.com",
                path: "/new_session",
                query: [
                    "callback": "jQuery3410014644797238627216_\(time)",
                    "urlApiWs": "\(url)",
                    "player": "website-desktop",
                    "partner": "1",
                    "uid_ext_session": key.uidExtSession,
                    "frontaddr": key.frontaddr,
                    "childMod": "",
                    "constraint": "ETAT<>'AV'",
                    "soft_constraint": "",
                    "question_filter": "",
                    "_": "\(time)"
                ]
            ) }
            .then { $0.fetchUTF8Async() }
            .mapCatching {
                guard let parsed = startGamePattern.firstGroups(in: $0) else { throw AkinatorError.startGamePatternNotFound }
                guard let data = parsed[1].data(using: .utf8) else { throw AkinatorError.invalidStartGameString(parsed[1]) }
                let response = try JSONDecoder().decode(AkinatorResponse.NewGame.self, from: data)
                let identification = response.parameters.identification
                let question = response.parameters.stepInformation
                return (
                    AkinatorSession(session: identification.session, signature: identification.signature),
                    question
                )
            }
    }

    private static func getApiKey() -> Promise<ApiKey, Error> {
        Promise.catching { try HTTPRequest(host: "en.akinator.com", path: "/game") }
            .then { $0.fetchUTF8Async() }
            .mapCatching {
                guard let parsed = sessionPattern.firstGroups(in: $0) else { throw AkinatorError.sessionPatternNotFound }
                return ApiKey(uidExtSession: parsed[1], frontaddr: parsed[2])
            }
    }
}
