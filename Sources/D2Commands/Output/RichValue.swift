import Foundation
import Geodesy
import D2MessageIO
@preconcurrency import CairoGraphics
import Utils
@preconcurrency import GIF
@preconcurrency import SwiftSoup

/// A value of a common format that
/// can be sent to an output.
public enum RichValue: Addable, Sendable {
    case none
    case text(String)
    case image(CairoImage)
    case table([[String]])
    case gif(GIF)
    case components([Message.Component])
    case urls([URL])
    case domNode(Element)
    case code(String, language: String?)
    case embed(Embed?)
    case geoCoordinates(Coordinates)
    case mentions([User])
    case roleMentions([RoleID])
    case ndArrays([NDArray<Rational>])
    case error(Error?, errorText: String)
    case files([Message.FileUpload])
    case attachments([Message.Attachment])
    // TODO: Find a better solution to this, maybe by just passing the closure?
    case lazy(UncheckedSendable<Lazy<RichValue>>)
    case compound([RichValue])

    public var asText: String? {
        extract { if case let .text(text) = $0 { text } else { nil } }.nilIfEmpty?.joined(separator: " ")
    }
    public var asCode: (code: String, language: String?)? {
        extract { if case let .code(code, language: language) = $0 { (code: code, language: language) } else { nil } }.first
    }
    public var asEmbed: Embed? {
        extract { if case let .embed(embed) = $0 { embed } else { nil } }.first
    }
    public var asTable: [[String]]? {
        extract { if case let .table(table) = $0 { table } else { nil } }.first
    }
    public var asMentions: [User]? {
        extract { r -> [User]? in if case let .mentions(mentions) = r { mentions } else { nil } }.flatMap { $0 }
    }
    public var asRoleMentions: [RoleID]? {
        extract { r -> [RoleID]? in if case let .roleMentions(mentions) = r { mentions } else { nil } }.flatMap { $0 }
    }
    public var asImage: CairoImage? {
        extract { if case let .image(image) = $0 { image } else { nil } }.first
    }
    public var asDomNode: Element? {
        extract { if case let .domNode(node) = $0 { node } else { nil } }.first
    }
    public var asGif: GIF? {
        extract { if case let .gif(gif) = $0 { gif } else { nil } }.first
    }
    public var asGeoCoordinates: Coordinates? {
        extract { if case let .geoCoordinates(geoCoordinates) = $0 { geoCoordinates } else { nil } }.first
    }
    public var asUrls: [URL]? {
        extract { r -> [URL]? in if case let .urls(urls) = r { urls } else { nil } }.flatMap { $0 }
    }
    public var asNDArrays: [NDArray<Rational>]? {
        extract { r -> [NDArray<Rational>]? in if case let .ndArrays(ndArrays) = r { ndArrays } else { nil } }.flatMap { $0 }
    }
    public var asFiles: [Message.FileUpload]? {
        extract { r -> [Message.FileUpload]? in if case let .files(files) = r { files } else { nil } }.flatMap { $0 }
    }
    public var asAttachments: [Message.Attachment]? {
        extract { r -> [Message.Attachment]? in if case let .attachments(attachments) = r { attachments } else { nil } }.first
    }

    public var isNone: Bool {
        switch self {
            case .none: true
            default: false
        }
    }

    public var type: RichValueType {
        switch self {
            case .none: .none
            case .text: .text
            case .image: .image
            case .table: .table
            case .gif: .gif
            case .components: .components
            case .urls: .urls
            case .domNode: .domNode
            case .code: .code
            case .embed: .embed
            case .geoCoordinates: .geoCoordinates
            case .mentions: .mentions
            case .roleMentions: .roleMentions
            case .ndArrays: .ndArrays
            case .error: .error
            case .files: .files
            case .attachments: .attachments
            case .lazy(let value): value.wrappedValue.wrappedValue.type
            case .compound(let values): .compound(values.map(\.type))
        }
    }

    public var values: [RichValue] {
        switch self {
            case .none: []
            case let .compound(values): values
            case let .lazy(wrapper): [wrapper.wrappedValue.wrappedValue]
            default: [self]
        }
    }

    private func extract<T>(using extractor: (RichValue) -> T?) -> [T] {
        if let extracted = extractor(self) {
            [extracted]
        } else if case let .compound(values) = self {
            values.flatMap { $0.extract(using: extractor) }
        } else if case let .lazy(wrapper) = self {
            wrapper.wrappedValue.wrappedValue.extract(using: extractor)
        } else {
            []
        }
    }

    public static func of(values: [RichValue]) -> RichValue {
        switch values.count {
            case 0: .none
            case 1: values.first!
            default: .compound(values)
        }
    }

    public static func +(lhs: RichValue, rhs: RichValue) -> RichValue {
        if lhs.isNone {
            rhs
        } else if rhs.isNone {
            lhs
        } else {
            .of(values: lhs.values + rhs.values)
        }
    }

    public static func +=(lhs: inout RichValue, rhs: RichValue) {
        lhs = lhs + rhs
    }
}
