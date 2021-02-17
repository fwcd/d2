// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/b7ac6f6d8cff525b27128b4b134a45a78600c6bb/Akinator.Api.Net/Enumerations/AnswerOptions.cs
// MIT-licensed, Copyright (c) 2019 Jannik

public enum AkinatorAnswer: String, CaseIterable {
    case unknown = "unknown"
    case yes = "yes"
    case no = "no"
    case dontKnow = "don't know"
    case probably = "probably"
    case probablyNot = "probably not"

    public var value: Int {
        switch self {
            case .unknown: return -1
            case .yes: return 0
            case .no: return 1
            case .dontKnow: return 2
            case .probably: return 3
            case .probablyNot: return 4
        }
    }
}
