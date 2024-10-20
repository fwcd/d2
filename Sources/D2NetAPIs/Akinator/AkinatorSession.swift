import Foundation
import RegexBuilder
import Utils
import Logging

// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/master/Akinator.Api.Net/Akinatorsink.cs
// MIT-licensed, Copyright (c) 2019 Jannik

private let jQuerySignature = "jQuery331023608747682107778"
private let headers = [
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

nonisolated(unsafe) private let sessionPattern = #/var uid_ext_session = '([^']*)'\;\s*.*var frontaddr = '([^']*)'\;/#
nonisolated(unsafe) private let startGamePattern = Regex {
    #/^/#
    jQuerySignature
    #/_\d+\(/#
    Capture { #/.+/# }
    #/\)$/#
}

private let log = Logger(label: "D2NetAPIs.AkinatorSession")

public struct AkinatorSession: Sendable {
    private let session: String
    private let signature: String
    private let serverUrl: URL
    // FIXME: Make this thread-safe
    @UncheckedSendable @Box private var step: Int = 0

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

    public static func create() async throws -> (AkinatorSession, AkinatorQuestion) {
        let time = Int64(Date().timeIntervalSince1970 * 1000) + 1

        // Query servers
        let servers = try await AkinatorServersQuery().perform()
        guard let url = servers.parameters.instance.first?.urlBaseWs else { throw AkinatorError.noServersFound }
        let key = try await getApiKey()

        // Create session
        let sessionRequest = try HTTPRequest(
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
        )
        let raw = try await sessionRequest.fetchUTF8()
        guard let parsed = try? startGamePattern.firstMatch(in: raw) else { throw AkinatorError.startGamePatternNotFound(raw) }
        guard let data = parsed.1.data(using: .utf8) else { throw AkinatorError.invalidStartGameString(String(parsed.1)) }
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

    public func answer(with answer: AkinatorAnswer) async throws -> AkinatorQuestion {
        let request = try HTTPRequest(host: serverUrl.host!, port: serverUrl.port, path: "\(serverUrl.path)/answer", query: [
            "session": session,
            "signature": signature,
            "step": "\(step)",
            "answer": "\(answer.value)"
        ], headers: headers)

        let stepInfo = try await request.fetchJSON(as: AkinatorResponse.StepInformation.self)
        guard let step = Int(stepInfo.parameters.step) else { throw AkinatorError.invalidStep(stepInfo.parameters.step) }
        self.step = step

        return try stepInfo.parameters.asQuestion()
    }

    public func guess() async throws -> [AkinatorGuess] {
        let request = try HTTPRequest(host: serverUrl.host!, port: serverUrl.port, path: "\(serverUrl.path)/list", query: [
            "session": session,
            "signature": signature,
            "step": "\(step)"
        ], headers: headers)

        let guess = try await request.fetchJSON(as: AkinatorResponse.Guess.self)
        return try guess.parameters.characters.map { try $0.asGuess() }
    }

    private static func getApiKey() async throws -> ApiKey {
        let request = try HTTPRequest(host: "en.akinator.com", path: "/game", headers: headers)
        let response = try await request.fetchUTF8()
        guard let parsed = try? sessionPattern.firstMatch(in: response) else { throw AkinatorError.sessionPatternNotFound }
        let key = ApiKey(uidExtSession: String(parsed.1), frontaddr: String(parsed.2))
        log.info("Got \(key)")
        return key
    }
}
