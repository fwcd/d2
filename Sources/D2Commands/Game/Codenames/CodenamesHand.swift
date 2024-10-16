import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.CodenamesHand")

public struct CodenamesHand: RichValueConvertible, Sendable {
    private let model: CodenamesBoardModel

    public var asRichValue: RichValue {
        do {
            return try .image(CodenamesBoardView(model: model, allUncovered: true).image)
        } catch {
            log.warning("Could not create CodenamesBoardView: \(error)")
            return .none
        }
    }

    public init(model: CodenamesBoardModel) {
        self.model = model
    }
}
