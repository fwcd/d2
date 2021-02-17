import Foundation
import Utils
import Logging

// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/master/Akinator.Api.Net/AkinatorClient.cs
// MIT-licensed, Copyright (c) 2019 Jannik

fileprivate let jQuerySignature = "jQuery331023608747682107778"
fileprivate let headers = [
    "Accept": "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01",
    "Accept-Language": "en-US,en;q=0.9,ar;q=0.8",
    "X-Requested-With": "XMLHttpRequest",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "same-origin",
    "Connection": "keep-alive",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.92 Safari/537.36",
    "Referer": "https://en.akinator.com/game"
]

fileprivate let sessionPattern = try! Regex(from: "var uid_ext_session = '([^']*)'\\;\\s*.*var frontaddr = '([^']*)'\\;")
fileprivate let startGamePattern = try! Regex(from: "^\(jQuerySignature)_\\d+\\((.+)\\)$")

fileprivate let log = Logger(label: "D2NetAPIs.AkinatorSession")

public struct AkinatorSession {
    private let session: String
    private let signature: String
    private let serverUrl: URL
    @Box private var step: Int = 0

    private init(session: String, signature: String, serverUrl: URL, step: Int) {
        self.session = session
        self.signature = signature
        self.serverUrl = serverUrl
        self.step = step
    }

    private struct ApiKey {
        let uidExtSession: String
        let frontaddr: String
    }

    public static func create() -> Promise<(AkinatorSession, AkinatorQuestion), Error> {
        let time = Int64(Date().timeIntervalSince1970 * 1000) + 1
        return AkinatorServersQuery().perform()
            .thenCatching {
                guard let url = $0.parameters.instance.first?.urlBaseWs else { throw AkinatorError.noServersFound }
                return getApiKey().map { ($0, url) }
            }
            .thenCatching { (key: ApiKey, url: URL) in
                try HTTPRequest(
                    host: "en.akinator.com",
                    path: "/new_session",
                    query: [
                        "callback": "\(jQuerySignature)_\(time)",
                        "urlApiWs": "\(url)",
                        "player": "website-desktop",
                        "partner": "1",
                        "uid_ext_session": key.uidExtSession,
                        "frontaddr": key.frontaddr,
                        "childMod": "",
                        "constraint": "ETAT<>'AV'",
                        "soft_constraint": "",
                        "question_filter": "",
                        "_": "\(time + 1)"
                    ],
                    headers: headers
                ).fetchUTF8Async().map { ($0, url) }
            }
            .mapCatching { (raw: String, url: URL) in
                guard let parsed = startGamePattern.firstGroups(in: raw) else { throw AkinatorError.startGamePatternNotFound(raw) }
                guard let data = parsed[1].data(using: .utf8) else { throw AkinatorError.invalidStartGameString(parsed[1]) }
                let response = try JSONDecoder().decode(AkinatorResponse.NewGame.self, from: data)
                let identification = response.parameters.identification
                let stepInfo = response.parameters.stepInformation
                guard let step = Int(stepInfo.step) else { throw AkinatorError.invalidStep(stepInfo.step) }
                return (
                    AkinatorSession(
                        session: identification.session,
                        signature: identification.signature,
                        serverUrl: url,
                        step: step
                    ),
                    try stepInfo.asQuestion()
                )
            }
    }

    public func answer(with answer: AkinatorAnswer) -> Promise<AkinatorQuestion, Error> {
        Promise.catching { try HTTPRequest(host: serverUrl.host!, port: serverUrl.port, path: "/answer", query: [
            "session": session,
            "signature": signature,
            "step": "\(step)",
            "answer": "\(answer.value)"
        ], headers: headers) }
            .then { $0.fetchJSONAsync(as: AkinatorResponse.StepInformation.self) }
            .mapCatching {
                guard let step = Int($0.parameters.step) else { throw AkinatorError.invalidStep($0.parameters.step) }
                self.step = step
                return try $0.parameters.asQuestion()
            }

    }

    private static func getApiKey() -> Promise<ApiKey, Error> {
        Promise.catching { try HTTPRequest(host: "en.akinator.com", path: "/game", headers: headers) }
            .then { $0.fetchUTF8Async() }
            .mapCatching {
                guard let parsed = sessionPattern.firstGroups(in: $0) else { throw AkinatorError.sessionPatternNotFound }
                let key = ApiKey(uidExtSession: parsed[1], frontaddr: parsed[2])
                log.info("Got \(key)")
                return key
            }
    }
}
