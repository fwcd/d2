import Foundation
import D2MessageIO

public struct Button {
    public var customId: String = UUID().uuidString
    public var label: String? = nil
    public var emoji: Emoji? = nil
}
