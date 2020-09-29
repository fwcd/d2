import Foundation
import D2MessageIO
import Graphics
import Utils
import GIF
import SwiftSoup

/**
 * A value of a common format that
 * can be sent to an output.
 */
public enum RichValue: Addable {
    case none
    case text(String)
    case image(Image)
    case table([[String]])
    case gif(AnimatedGIF)
    case urls([URL])
    case domNode(Element)
    case code(String, language: String?)
    case embed(Embed?)
    case mentions([User])
    case roleMentions([RoleID])
    case ndArrays([NDArray<Rational>])
    case error(Error?, errorText: String)
    case files([Message.FileUpload])
    case attachments([Message.Attachment])
    case compound([RichValue])

    public var asText: String? {
        extract { if case let .text(text) = $0 { return text } else { return nil } }.nilIfEmpty?.joined(separator: " ")
    }
    public var asCode: String? {
        extract { if case let .code(code, language: _) = $0 { return code } else { return nil } }.first
    }
    public var asTable: [[String]]? {
        extract { if case let .table(table) = $0 { return table } else { return nil } }.first
    }
    public var asMentions: [User]? {
        extract { r -> [User]? in if case let .mentions(mentions) = r { return mentions } else { return nil } }.flatMap { $0 }
    }
    public var asRoleMentions: [RoleID]? {
        extract { r -> [RoleID]? in if case let .roleMentions(mentions) = r { return mentions } else { return nil } }.flatMap { $0 }
    }
    public var asImage: Image? {
        extract { if case let .image(image) = $0 { return image } else { return nil } }.first
    }
    public var asDomNode: Element? {
        extract { if case let .domNode(node) = $0 { return node } else { return nil } }.first
    }
    public var asGif: AnimatedGIF? {
        extract { if case let .gif(gif) = $0 { return gif } else { return nil } }.first
    }
    public var asUrls: [URL]? {
        extract { r -> [URL]? in if case let .urls(urls) = r { return urls } else { return nil } }.flatMap { $0 }
    }
    public var asNDArrays: [NDArray<Rational>]? {
        extract { r -> [NDArray<Rational>]? in if case let .ndArrays(ndArrays) = r { return ndArrays } else { return nil } }.flatMap { $0 }
    }
    public var asFiles: [Message.FileUpload]? {
        extract { r -> [Message.FileUpload]? in if case let .files(files) = r { return files } else { return nil } }.flatMap { $0 }
    }
    public var asAttachments: [Message.Attachment]? {
        extract { r -> [Message.Attachment]? in if case let .attachments(attachments) = r { return attachments } else { return nil } }.first
    }
    public var isNone: Bool {
        switch self {
            case .none: return true
            default: return false
        }
    }
    public var values: [RichValue] {
        switch self {
            case .none: return []
            case let .compound(values): return values
            default: return [self]
        }
    }

    private func extract<T>(using extractor: (RichValue) -> T?) -> [T] {
        if let extracted = extractor(self) {
            return [extracted]
        } else if case let .compound(values) = self {
            return values.flatMap { $0.extract(using: extractor) }
        } else {
            return []
        }
    }

    public static func of(values: [RichValue]) -> RichValue {
        switch values.count {
            case 0: return .none
            case 1: return values.first!
            default: return .compound(values)
        }
    }

    public static func +(lhs: RichValue, rhs: RichValue) -> RichValue {
        if lhs.isNone {
            return rhs
        } else if rhs.isNone {
            return lhs
        } else {
            return .of(values: lhs.values + rhs.values)
        }
    }

    public static func +=(lhs: inout RichValue, rhs: RichValue) {
        lhs = lhs + rhs
    }
}
