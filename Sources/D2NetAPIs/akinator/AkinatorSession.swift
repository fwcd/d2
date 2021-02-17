import Utils

// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/master/Akinator.Api.Net/AkinatorClient.cs
// MIT-licensed, Copyright (c) 2019 Jannik

fileprivate let sessionPattern = try! Regex(from: "var uid_ext_session = '([^']*)'\\;\\s*.*var frontaddr = '(.*)'\\;")

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

    private enum ApiError: Error {
        case sessionPatternNotFound
    }



    private static func getApiKey() -> Promise<ApiKey, Error> {
        Promise.catching { try HTTPRequest(host: "en.akinator.com", path: "/game") }
            .then { $0.fetchUTF8Async() }
            .mapCatching {
                guard let parsed = sessionPattern.firstGroups(in: $0) else { throw ApiError.sessionPatternNotFound }
                return ApiKey(uidExtSession: parsed[1], frontaddr: parsed[2])
            }
    }
}
